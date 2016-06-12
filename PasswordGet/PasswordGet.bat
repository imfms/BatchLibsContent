@echo off&setlocal enabledelayedexpansion&set dijia2=1
if "%1"=="/?" goto help
for /f "tokens=2" %%i in ('mode^|findstr 列') do set /a center=%%i/2
for /l %%i in (1,1,%center%) do set space=!space! 
if /i "%1"=="/d" (
	set pwddiy=%2
	set pwddiy=!pwddiy:~0,1!
	shift /1&shift /1
) else set pwddiy=*
if "%1"=="" (
	set wide=6
	) else (
	set /a nosee=%1+1
	if "!nosee!"=="1" (goto help) else set wide=%1
)
if "%2"=="" (
	call:word i&call:num
	) else (
	set nosee=%2
	if /i "!nosee:~0,2!"=="d:" (
		set body=!nosee:~2!&set i=/cs&goto start
		) else (
		echo %2|findstr a>nul
		if "!errorlevel!"=="0" call:word i
		echo %2|findstr A>nul
		if "!errorlevel!"=="0" set i=/cs&call:word
		echo %2|findstr [0-9]>nul
		if "!errorlevel!"=="0" call:num
	)
)

:start
cls
echo=!space:~0,-%dijia2%!%noecho%
choice /c %body% %i% /n>nul
set /a pwdtemp=%errorlevel%-1
set pwd=%pwd%!body:~%pwdtemp%,1!
set /a dijia+=1&set /a dijia2=dijia/2+1
if "%dijia%"=="%wide%" echo=%pwd%&goto end
set noecho=%noecho%%pwddiy%
goto start

:word
if "%1"=="i" (set body=%body%ABCDEFGHIJKLMNOPQRSTUVWXYZ) else set body=%body%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
goto :eof
:num
set body=%body%1234567890
goto :eof

:help
echo %~n0 [/d 要设置的密文显示] 密码长 A(区分大小写)^|a(不区分大小写)^|[0-9](0-9数字)^|d:自定义输入内容


:end




