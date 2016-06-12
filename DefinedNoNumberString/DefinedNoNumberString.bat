@echo off
cd /d "%~dp0"
setlocal ENABLEDELAYEDEXPANSION

call:DefinedNoNumberString a0
echo=a0	%errorlevel%

pause

goto end

:-----------子程序开始-------

REM 判断变量中是否含有非数字字符 call:DefinedNoNumberString 被判断字符
REM	返回值0代表有非数字字符，返回值1代表无非数字字符，返回值2代表参数为空
REM 版本：20151231
:DefinedNoNumberString
REM 判断子程序基本需求参数
if "%~1"=="" exit/b 2

REM 初始化子程序需求变量
for %%B in (DefinedNoNumberString) do set %%B=
set DefinedNoNumberString=%~1

REM 子程序开始运行
for /l %%B in (0,1,9) do (
	set DefinedNoNumberString=!DefinedNoNumberString:%%B=!
	if not defined DefinedNoNumberString exit/b 1
)
exit/b 0

:-----------子程序结束-----------:
:end