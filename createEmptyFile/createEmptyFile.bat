REM 创建空文件 20160425
REM call:createEmptyFile "文件名"
REM 返回值：1 - 文件生成失败， 2 - 调用参数错误， 0 - 成功
:createEmptyFile
REM 判断参数是否正确
if "%~1"=="" (
	if defined debug (
		echo=#createEmptyFile:参数为空
		pause
	)
	exit/b 2
)

REM 生成空文件
(
	if a==b echo=此处用于生成空文件
)>"%~1"

if exist "%~1" (
	exit/b 0
) else if defined debug (
	echo=#createEmptyFile:文件生成失败
	pause
)
exit/b 1