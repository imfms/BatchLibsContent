@echo off&setlocal ENABLEDELAYEDEXPANSION&set yuandir=%cd%
REM 20151119
:jumppathdrive
if "%~1"=="/?" (
	echo=%~n0:
	echo=       %~n0 - 本地所有磁盘随机跳转^(包含所有磁盘类型^)
	echo=       %~n0 /? - 显示帮助文件
	echo=       %~n0 /L - 本地所有固定磁盘随机跳转^(不包含可移动磁盘类型^)
	echo=       %~n0 c:\windows - 在c:\windows下随机跳转
	echo=                                                           F_Ms
	exit /b
)
if /i "%~1"=="/l" set localdiskmode=0&shift /1
if not "%~1"=="" (
	if exist "%~1" (
		cd /d "%~1"\
		set diydir=0
		goto jumppathrebegin
	) else (
		echo=错误：指定目录不存在
		exit /b 2
	)
)
if defined jumppathdrive (
	if defined jumpdrivedijia (
		for %%a in (jumppathdijia2 jumppathdijia3) do set %%a=
		goto jumppathrandomdrive
	)
)
for %%a in (jumppathdijia jumppathdrive jumpdrivedijia jumppathdijia2) do set %%a=
if not defined localdiskmode (
	for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
		if exist %%a: (
			set jumppathdrive=!jumppathdrive! %%a:
			set /a jumpdrivedijia+=1
		)
	)
) else (
	for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist %%a: (
		for /f "tokens=2 delims=- " %%b in ('fsutil fsinfo drivetype %%a:') do (
			if defined jumppathtemp set jumppathtemp=
			set jumppathtemp=%%b
			if "!jumppathtemp:~0,5!"=="固定驱动器" (
				set /a jumpdrivedijia+=1
				set jumppathdrive=!jumppathdrive! %%a:
			)
		)
	)
)
:jumppathrandomdrive
set /a jumppathdijia3=%random%%%%jumpdrivedijia%+1
for %%a in (%jumppathdrive%) do (
	set /a jumppathdijia2+=1
	if "%jumppathdijia3%"=="!jumppathdijia2!" (
		cd /d %%a\
		goto jumppathrebegin
	)
)
:jumppathrebegin
set jumppathdijia=&set jumppathdijia2=
for /f "delims=" %%i in ('dir /b /ad 2^>nul^|findstr /v "( ) &"') do set /a jumppathdijia+=1 >nul
if not defined jumppathdijia goto jumppathend
set /a jumppathdijia=%random%%%%jumppathdijia%+1
for /f "delims=" %%i in ('dir /b /ad 2^>nul^|findstr /v "( ) &"') do (
	set /a jumppathdijia2+=1
	if "%jumppathdijia%"=="!jumppathdijia2!" (
		set jumppathdir=%%i
		goto jumppathstart
	)
)
:jumppathstart
cd "%jumppathdir%" 2>nul
if not "%errorlevel%"=="0" (
	if not defined diydir (goto jumppathdrive) else (
		echo=错误：所指定目录没有权限
		exit /b 1
	)
)
goto jumppathrebegin
:jumppathend
echo=%cd%
cd /d %yuandir%
exit /b 0


