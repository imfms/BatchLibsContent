@echo off
cd /d "%~dp0"

call:DownloadNetFile http://imfms.vicp.net/BFS_FileSearch.Version asdf.ini
pause

goto end

:-----------子程序开始-----------:

REM call:DownloadNetFile 网址 路径及文件名
REM 下载网络文件 版本：20160114
:DownloadNetFile
REM 检查子程序使用规则正确与否
if "%~2"=="" (
	echo=	#[Error %0:参数2]文件路径及文件名为空
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
(
	echo=Set xPost = CreateObject^("Microsoft.XMLHTTP"^)
	echo=xPost.Open "GET",%downloadNetFileUrl%,0
	echo=xPost.Send^(^)
	echo=Set sGet = CreateObject^("ADODB.Stream"^)
	echo=sGet.Mode = 3
	echo=sGet.Type = 1
	echo=sGet.Open^(^)
	echo=sGet.Write^(xPost.responseBody^)
	echo=sGet.SaveToFile "%downloadNetFileFilePath%",2
)>"%downloadNetFileTempPath%"

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