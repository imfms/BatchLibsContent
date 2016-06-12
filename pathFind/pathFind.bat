@echo off
setlocal ENABLEDELAYEDEXPANSION

call:pathFind t result
echo=%errorlevel%:%result%

goto end

REM 从Path目录中查找找到的第一个指定程序可执行程序(pathext扩展名)的全路径
REM call:pathFind [/Q(安静模式)] "查找程序名" "全路径结果接收变量"
REM errorlevel: 0 - 找到, 1 - 未找到, 2 - 参数错误
REM 20160507
:pathFind
REM 使用参数判断
set pathFindQuit=
if /i "%~1"=="/q" (
	set pathFindQuit=yes
	shift/1
)
if "%~2"=="" (
	if not defined pathFindQuit (
		echo=	#错误:pathFind:未指定全路径结果接收变量
		pause
	)
	exit/b 2
)
if "%~1"=="" (
	if not defined pathFindQuit (
		echo=	#错误:pathFind:未指定查找程序名
		pause
	)
	exit/b 2
)
set pathFind_appName=%~1
for %%a in (/,\,:) do if not "%pathFind_appName%"=="!pathFind_appName:%%a=!" exit/b 1

REM 初始化变量
set %~2=
if defined pathext (set pathFind_pathextTemp=%pathext%) else set pathFind_pathextTemp=.EXE;.BAT;.CMD;.VBS
if not defined path exit/b 1

REM 如果指定程序名含有扩展名的判断
if not "%~x1"=="" set "pathFind_pathextTemp=%~x1"

REM 解析path目录
for /f "delims==" %%a in ('set pathFind_parsePath 2^>nul') do set %%a=
set pathFind_parsePath_count=0
set pathFind_pathTemp=
set pathFind_pathTemp=%path%

:pathFind_parsePath2
set /a pathFind_parsePath_count+=1
for /f "tokens=1,* delims=;" %%a in ("%pathFind_pathTemp%") do (
	set "pathFind_parsePath%pathFind_parsePath_count%=%%~a"
	if not "%%~b"=="" (
		set pathFind_pathTemp=
		set "pathFind_pathTemp=%%~b"
		goto pathFind_parsePath2
	)
)

REM 开始查找
for /l %%a in (1,1,%pathFind_parsePath_count%) do (
	for %%b in (%pathFind_pathextTemp%) do (
		if exist "!pathFind_parsePath%%a!\%~n1%%~b" (
			set "%~2=!pathFind_parsePath%%a!\%~n1%%~b"
			exit/b 0
		)
	)
)
exit/b 1

:end
echo=end
pause
















