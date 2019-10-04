# escape=`

# Use a specific tagged image. Tags can be changed, though that is unlikely for most images.
# You could also use the immutable tag @sha256:1a66e2b5f3a5b8b98ac703a8bfd4902ae60d307ed9842978df40dbc04ac86b1b
#ARG FROM_IMAGE=microsoft/dotnet-framework:4.7.1-20180410-windowsservercore-1709
#ARG FROM_IMAGE=mcr.microsoft.com/windows/servercore:ltsc2019
ARG FROM_IMAGE=mcr.microsoft.com/windows/servercore:1803
FROM ${FROM_IMAGE}

ARG WEBRTC_VERSION
ARG WEBRTC_COMMIT

SHELL ["cmd", "/S", "/C"]

# インストールエラーを回収するための準備
COPY Install.cmd C:\TEMP\
ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe

ARG CHANNEL_URL=https://aka.ms/vs/15/release/channel
ADD ${CHANNEL_URL} C:\TEMP\VisualStudio.chman

# 必要なコンポーネントをインストールする
ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
RUN C:\TEMP\Install.cmd C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --includeRecommended `
    --add Microsoft.VisualStudio.Component.VC.ATLMFC

SHELL ["powershell"]

# choco
RUN iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# git
RUN choco install -y git
RUN git config --global core.autocrlf false
RUN git config --global core.filemode false
RUN git config --global branch.autosetuprebase always

# vim
RUN choco install -y vim-console

# WebRTC ビルドに必要な環境変数の設定
RUN setx PYTHONIOENCODING "utf-8"
RUN setx GYP_MSVS_OVERRIDE_PATH "C:\BuildTools"
RUN setx GYP_MSVS_VERSION "2017"
RUN setx DEPOT_TOOLS_WIN_TOOLCHAIN "0"
RUN setx vs2017_install "C:\BuildTools"
RUN setx PYTHONIOENCODING "utf-8"

# depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
RUN setx /M PATH $('C:\depot_tools;' + $Env:PATH)

# dbghelp.dll が無いと怒られてしまうので所定の場所にコピーする
RUN mkdir 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64'
RUN cp 'C:\BuildTools\Common7\IDE\Extensions\TestPlatform\Extensions\Cpp\x64\dbghelp.dll' 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\dbghelp.dll'

# WebRTC のソース取得
RUN mkdir webrtc
RUN cd webrtc; fetch webrtc
RUN cd webrtc\src; git checkout -f $env:WEBRTC_COMMIT
RUN cd webrtc\src; gclient sync

# WebRTC ビルド
RUN cd webrtc\src; gn gen ..\build_debug --args='is_debug=true rtc_include_tests=false rtc_use_h264=false is_component_build=false use_rtti=true'
RUN ninja -C C:\webrtc\build_debug

RUN cd webrtc\src; gn gen ..\build_release --args='is_debug=false rtc_include_tests=false rtc_use_h264=false is_component_build=false use_rtti=true'
RUN ninja -C C:\webrtc\build_release

# WebRTC のヘッダーだけを特定の場所に配置する（コンテナ外からコピーしやすくするため）
# if 以降は、robocopy が変なエラーコードを返すのでその対策
# ref: https://superuser.com/questions/280425/getting-robocopy-to-return-a-proper-exit-code
RUN robocopy C:\webrtc\src C:\webrtc\include *.h *.hpp /E; if ($LastExitCode -le 1) { exit 0 } else { exit $LastExitCode }

SHELL ["cmd", "/C"]

ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&
CMD powershell.exe -NoLogo -ExecutionPolicy Bypass
