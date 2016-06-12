@echo off
setlocal ENABLEDELAYEDEXPANSION

set project=ProjectTest
set version=20150101
set updateUrl=http://imfms.vicp.net

call:UpdateProjectVersion %project% %version% %updateUrl% "%~0"

echo=over&pause





goto end

:-----------子程序开始-----------:

REM call:UpdateProjectVersion 项目名称 当前版本 更新地址 项目源文件名及路径("%~0")
:更新项目版本 20151106
:UpdateProjectVersion

REM 检查子程序使用基本规则正确与否
if "%~4"=="" (
	echo=	#[错误 %0:参数4]项目源文件名及路径为空
	exit/b 1
) else if "%~3"=="" (
	echo=	#[错误 %0:参数3]更新地址为空
	exit/b 1
) else if "%~2"=="" (
	echo=	#[错误 %0:参数2]当前版本为空
	exit/b 1
) else if "%~1"=="" (
	echo=	#[错误 %0:参数1]项目名称为空
	exit/b 1
)

REM 初始化子程序需求变量
for %%I in (updateVersionName updateVersionPath updateNewVersion updateNewVersionName updateVersionOldVersionPath) do if defined %%I set %%I=
set updateVersionName=%~1.Version
set updateVersionPath=%temp%\%updateVersionName%%random%%ranom%%random%

REM 子程序开始运作
echo=#正在检测更新项目: %~1	当前版本: %~2
call:DownloadNetFile %~3/%updateVersionName% "%updateVersionPath%"
if not "%errorlevel%"=="0" (
	echo=	#更新失败,无法连接到服务器,请检查后重试
	exit/b
)
for /f "usebackq tokens=1,2 delims= " %%I in ("%updateVersionPath%") do (
	if %~2 lss %%I (
		echo=#检测到项目新版本 %%I 正在尝试更新项目...
		set updateNewVersion=%%I
		set updateNewVersionName=%%~J
		call:DownloadNetFile %~3/%%~J "%~dp0\%%~J"
		if "!errorlevel!"=="0" (
			set updateNewVersionPath=%~dp0%%~J
			echo=#项目 %~1 新版本 %%I 下载成功
			goto  UpdateProjectVersion2
		) else (
			echo=	#更新失败,无法从服务器下载更新文件,请稍后再试
			if exist "%updateVersionPath%" del /f /q "%updateVersionPath%"
			exit/b 1
		)
	) else (
		if exist "%updateVersionPath%" del /f /q "%updateVersionPath%"
		echo=#已是最新版本,感谢您的关注
		exit/b 1
	)
)
:UpdateProjectVersion2
if exist "%updateVersionPath%" del /f /q "%updateVersionPath%"

REM 此处为新版本下载成功后要做的动作
REM 	%1	项目名称
REM 	%2	旧版本
REM 	"%~4"	项目旧版本源文件名及路径
REM 	%updateNewVersion%	更新后文件版本
REM 	%updateNewVersionPath%	更新后版本文件路径


REM 删除旧版本，打开新版本
echo=	#即将打开新版本项目 %1 %updateNewVersion%
ping -n 3 127.1>nul 2>nul
set updateVersionOldVersionPath=%~4
if /i "%updateVersionOldVersionPath:~-4%"==".exe" taskkill /f /im "%~nx4">nul 2>nul
(
	copy "%~4" "%~4_updatebak">nul 2>nul
	del /f /q "%~4"
	copy "%updateNewVersionPath%" "%~4">nul 2>nul
	if "!errorlevel!"=="0" (
		start "" "%~4"
		del /f /q "%~4_updatebak"
		del /f /q "%updateNewVersionPath%"
		exit
	) else (
		copy "%~4_updatebak" "%~4">nul 2>nul
		echo=#打开新版本失败，您可手动打开新版本项目 %updateNewVersionPath%
		del /f /q "%~4_updatebak"
		pause
		explorer /select,"%updateNewVersionPath%"
		exit
	)
)
exit/b 0

REM call:DownloadNetFile 网址 路径及文件名
:下载网络文件 20151105
:DownloadNetFile
REM 检查子程序使用规则正确与否
if "%~2"=="" (
	echo=	#[Error %0:参数2]文件路径为空
	exit/b 1
) else if "%~1"=="" (
	echo=	#[Error %0:参数1]网址为空
	exit/b 1
)

REM 初始化子程序需求变量
for %%- in (downloadNetFileTempPath downloadNetFileUrl downloadNetFileCachePath) do if defined %%- set %%-=
set downloadNetFileTempPath=%temp%\downloadNetFileTempPath%random%%random%%random%.vbs
set downloadNetFileUrl="%~1"
set downloadNetFileUrl="%downloadNetFileUrl:"=%"
set downloadNetFileFilePath=%~2

REM 生成动作脚本
echo=Set xPost = CreateObject("Microsoft.XMLHTTP") >"%downloadNetFileTempPath%"
echo=xPost.Open "GET",%downloadNetFileUrl%,0 >>"%downloadNetFileTempPath%"
echo=xPost.Send() >>"%downloadNetFileTempPath%"
echo=Set sGet = CreateObject("ADODB.Stream") >>"%downloadNetFileTempPath%"
echo=sGet.Mode = 3 >>"%downloadNetFileTempPath%"
echo=sGet.Type = 1 >>"%downloadNetFileTempPath%"
echo=sGet.Open() >>"%downloadNetFileTempPath%"
echo=sGet.Write(xPost.responseBody) >>"%downloadNetFileTempPath%"
echo=sGet.SaveToFile "%downloadNetFileFilePath%",2 >>"%downloadNetFileTempPath%"

REM 删除IE关于下载内容的缓存
for /f "tokens=3,* skip=2" %%- in ('reg query "hkcu\software\microsoft\windows\currentversion\explorer\shell folders" /v cache') do if "%%~."=="" (set downloadNetFileCachePath=%%-) else set downloadNetFileCachePath=%%- %%.
for /r "%downloadNetFileCachePath%" %%- in ("%~n1*") do if exist "%%~-" del /f /q "%%~-"

REM 运行脚本
cscript //b "%downloadNetFileTempPath%"

REM 删除临时文件
if exist "%downloadNetFIleTempPath%" del /f /q "%downloadNetFIleTempPath%"

REM 判断脚本运行结果
if exist "%downloadNetFileFilePath%" (exit/b 0) else exit/b 1

:-----------子程序结束-----------:
:end