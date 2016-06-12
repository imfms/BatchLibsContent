goto end

REM 确认？
REM 20160502
REM call:queRen ["提示内容"] ["确认按键"] ["取消按键"]
REM 返回值：0-用户确认，1-用户取消
:queRen
set queRen_tips=确认?
set queRen_yes=Y
set queRen_no=

if not "%~1"=="" set queRen_tips=%~1
if not "%~2"=="" set queRen_yes=%~2
if not "%~3"=="" set queRen_no=%~3
set queRen_tips=%queRen_tips% [是:%queRen_yes%
if defined queRen_no (
	set queRen_tips=%queRen_tips%/否:%queRen_no%]
) else (
	set queRen_tips=%queRen_tips%]
)

:queRen2
set queRen_user=
set /p queRen_user=%queRen_tips%:
if defined queRen_user (
	
	if /i "%queRen_user%"=="%queRen_yes%" exit/b 0
	if defined queRen_no if /i not "%queRen_user%"=="%queRen_no%" goto queRen2
	
) else (
	if defined queRen_no goto queRen2
)
exit/b 1

:end