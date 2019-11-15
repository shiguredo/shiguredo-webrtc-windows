if (Test-Path vswhere.exe) {
    Remove-Item vswhere.exe -Force
}
if (Test-Path depot_tools) {
    Remove-Item depot_tools -Force -Recurse
}
if (Test-Path webrtc) {
    Remove-Item webrtc -Force -Recurse
}
if (Test-Path package) {
    Remove-Item package -Force -Recurse
}

Invoke-WebRequest -Uri "https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe" -OutFile vswhere.exe

# vsdevcmd.bat の設定を入れる
# https://github.com/microsoft/vswhere/wiki/Find-VC
$path = .\vswhere.exe -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($path) {
    $path = join-path $path 'Common7\Tools\vsdevcmd.bat'
    if (test-path $path) {
        cmd /s /c """$path"" $args && set" | Where-Object { $_ -match '(\w+)=(.*)' } | ForEach-Object {
            $null = new-item -force -path "Env:\$($Matches[1])" -value $Matches[2]
        }
    }
}

$REPO_DIR = Resolve-Path "."
$WEBRTC_DIR = "C:\webrtc"

# WebRTC ビルドに必要な環境変数の設定
$Env:GYP_MSVS_VERSION = "2019"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
$Env:PYTHONIOENCODING = "utf-8"

# depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$Env:PATH = "$REPO_DIR\depot_tools;$Env:PATH"
# Choco へのパスを削除
$Env:PATH = $Env:Path.Replace("C:\ProgramData\Chocolatey\bin;", "");
# dbghelp.dll が無いと怒られてしまうので所定の場所にコピーする
# mkdir 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64'
# cp 'C:\BuildTools\Common7\IDE\Extensions\TestPlatform\Extensions\Cpp\x64\dbghelp.dll' 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\dbghelp.dll'

# WebRTC のソース取得
mkdir $WEBRTC_DIR
Push-Location $WEBRTC_DIR
  fetch webrtc
Pop-Location

Get-PSDrive

Push-Location $WEBRTC_DIR\src
  git checkout -f 0b2302e5e0418b6716fbc0b3927874fd3a842caf
  gclient sync

  # WebRTC ビルド
  gn gen ..\build_debug --args='is_debug=true rtc_include_tests=false rtc_use_h264=false is_component_build=false use_rtti=true use_custom_libcxx=false'
  ninja -C "$WEBRTC_DIR\build_debug"

  gn gen ..\build_release --args='is_debug=false rtc_include_tests=false rtc_use_h264=false is_component_build=false use_rtti=true use_custom_libcxx=false'
  ninja -C "$WEBRTC_DIR\build_release"
Pop-Location

ninja -C "$WEBRTC_DIR\build_debug" audio_device_module_from_input_and_output
ninja -C "$WEBRTC_DIR\build_release" audio_device_module_from_input_and_output

# このままだと webrtc.lib に含まれないファイルがあるので、いくつか追加する
Push-Location $WEBRTC_DIR\build_debug\obj
  lib.exe `
    /out:$WEBRTC_DIR\build_debug\webrtc.lib webrtc.lib `
    api\task_queue\default_task_queue_factory\default_task_queue_factory_win.obj `
    rtc_base\rtc_task_queue_win\task_queue_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_factory.obj `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_module_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_base_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_input_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_output_win.obj `
    modules\audio_device\windows_core_audio_utility\core_audio_utility_win.obj `
    modules\audio_device\audio_device_name\audio_device_name.obj
Pop-Location
Move-Item $WEBRTC_DIR\build_debug\webrtc.lib $WEBRTC_DIR\build_debug\obj\webrtc.lib -Force

Push-Location $WEBRTC_DIR\build_release\obj
  lib.exe `
    /out:$WEBRTC_DIR\build_release\webrtc.lib webrtc.lib `
    api\task_queue\default_task_queue_factory\default_task_queue_factory_win.obj `
    rtc_base\rtc_task_queue_win\task_queue_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_factory.obj `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_module_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_base_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_input_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_output_win.obj `
    modules\audio_device\windows_core_audio_utility\core_audio_utility_win.obj `
    modules\audio_device\audio_device_name\audio_device_name.obj
Pop-Location
Move-Item $WEBRTC_DIR\build_release\webrtc.lib $WEBRTC_DIR\build_release\obj\webrtc.lib -Force

# WebRTC のヘッダーだけをパッケージングする
mkdir $REPO_DIR\package
robocopy "$WEBRTC_DIR\src" "$REPO_DIR\package\include" *.h *.hpp /S
mkdir $REPO_DIR\package\debug
Copy-Item $WEBRTC_DIR\build_debug\obj\webrtc.lib $REPO_DIR\package\debug\
mkdir $REPO_DIR\package\release
Copy-Item $WEBRTC_DIR\build_release\obj\webrtc.lib $REPO_DIR\package\release\
COPY-Item $REPO_DIR\VERSION $REPO_DIR\package\
COPY-Item $REPO_DIR\NOTICE $REPO_DIR\package\