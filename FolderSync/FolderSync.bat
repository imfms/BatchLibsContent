@echo off
setlocal ENABLEDELAYEDEXPANSION


call:FolderSync D:\user\desktop\test1\ D:\user\desktop\test2\

pause

goto end
:----------子程序开始----------:

REM call:FolderSync 源文件夹 镜像文件夹
:文件夹同步 20151109
:FolderSync
REM 检查子程序使用规则正确与否
if "%~2"=="" (
	echo=	#[Error %0:参数2]镜像文件夹路径为空
	exit/b 1
) else if not exist "%~2\" (
	echo=	#[Error %0:参数2]镜像文件夹不存在
	exit/b 1
)
if "%~1"=="" (
	echo=	#[Error %0:参数1]源文件夹为空
	exit/b 1
) else if not exist "%~1\" (
	echo=	#[Error %0:参数1]源文件夹不存在
	exit/b 1
)

REM 初始化子程序需求变量
for %%- in (folderSync_Temp foderSyncTemp2) do if defined %%- set %%-=

for /r "%~1\" %%- in (*) do if exist "%%~-" (
	if exist "%~2\%%~nx-" (
		for /f "delims=" %%. in ("%~1\%%~nx-") do (
			set folderSync_Temp=%%~t.
			set folderSync_Temp=!folderSync_Temp: =!
			set folderSync_Temp=!folderSync_Temp:/=!
			set folderSync_Temp=!folderSync_Temp::=!
		)
		for /f "delims=" %%. in ("%~2\%%~nx-") do (
			set folderSync_Temp2=%%~t.
			set folderSync_Temp2=!folderSync_Temp2: =!
			set folderSync_Temp2=!folderSync_Temp2:/=!
			set folderSync_Temp2=!folderSync_Temp2::=!
		)
		if not "!folderSync_Temp!"=="!folderSync_Temp2!" (
			copy "%%~-" "%~2\">nul 2>nul
			echo=%~2\%%~nx-
		)
	) else (
		copy "%%~-" "%~2\">nul 2>nul
		echo=%~2\%%~nx-
	)
)
exit/b 0

:----------子程序结束----------:
:end