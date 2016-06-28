@echo off
setlocal ENABLEDELAYEDEXPANSION
cd/d "%~dp0"

REM 测试
echo=#生成测试文件
(
	echo=a	b	c	d	e	f	g	h	i
	echo=1	2	3	4	5	6	7	8	9
	echo=app	ban	int	liu	feng	li	july	ab	Ab
)>test.txt
cls
type test.txt
echo=
echo=#测试Database_Read
echo=
echo=将第2行的第3列和第5列数据分别写入到变量a和变量b
call:Database_Read "test.txt" "	" "2" "3,5" "a b"
echo=变量a:%a%
echo=变量b:%b%

echo=&pause&echo=

echo=将第3行的第5列和第6列数据分别写入变量c和变量d
call:Database_Read "test.txt" "	" "3" "5,6" "c d"
echo=变量c:%c%
echo=变量d:%d%

echo=&pause&echo=

cls
type test.txt
echo=
echo=#测试Database_Update
echo=将第3行第2列、第5列的内容分别更改为：change1、change2
call:Database_Update "test.txt" "	" "3" "2,5" "change1" "change2"
type test.txt

echo=&pause&echo=
echo=将第2行第3第4列内容分别更改为:change3,change4
call:Database_Update "test.txt" "	" "2" "3,4" "change3" "change4"
type test.txt

echo=&pause&echo=

cls
type test.txt
echo=
echo=#测试Database_Print
echo=将第一行到第三行的第2列、第5列以*为分隔符显示出来
call:Database_Print "test.txt" "	" "*" "1-3" "2,5"

echo=&pause&echo=

echo=将第一行到第三行的第3列、第7列以*为分隔符显示出来(带序号)
call:Database_Print /ln "test.txt" "	" "*" "1-3" "3,7"

echo=&pause&echo=

echo=将第一行到第三行的第2列、第5列以*为分隔符输出到文件test.tmp中
call:Database_Print /ln "test.txt" "	" "*" "1-3" "2,5" /f test.tmp
type test.tmp
if exist "test.tmp" del /f /q "test.tmp"

echo=&pause&echo=

cls
type test.txt
echo=
echo=#测试Database_Find
echo=搜索所有行1-3行，1-9列中为"ab"的字符串位置,区分大小写
call:Database_Find "test.txt" "	" "ab" "1-3" "1-9" "result"
echo=%result%

echo=&pause&echo=

echo=搜索所有行1-3行，1-9列中为"ab"的字符串位置,不区分大小写
call:Database_Find /i "test.txt" "	" "ab" "1-3" "1-9" "result"
echo=%result%

echo=&pause&echo=

cls
type test.txt
echo=#测试DatabaseInsert
echo=插入数据 A-I 以	为分隔符到尾部
call:Database_Insert "test.txt" "	" "A" "B" "C" "D" "E" "F" "G" "H" "I"
type test.txt

echo=&pause&echo=

echo=插入数据 A-I 以	为分隔符到第二行
call:Database_Insert "test.txt" /ln 2 "	" "A" "B" "C" "D" "E" "F" "G" "H" "I"
type test.txt

echo=&pause&echo=

cls
type test.txt
echo=
echo=#测试Database_Sort
echo=将第一行挪到第三行
call:Database_Sort "test.txt" 1 3
type test.txt

echo=&pause&echo=

echo=将第三行挪到第一行
call:Database_Sort "test.txt" 3 1
type test.txt

echo=&pause&echo=

cls
type test.txt
echo=#测试Database_DeleteLine
echo=删除第三行
call:Database_DeleteLine "test.txt" 3 1 
type test.txt

echo=&pause&echo=

echo=删除1,2,3行
call:Database_DeleteLine "test.txt" 1 3
type test.txt

echo=&pause&echo=

cls
echo=测试完毕
if exist "test.txt" del /f /q "test.txt"
pause



goto end
:-----------------------------------------------------------子程序开始分割线-----------------------------------------------------------:

REM __________________________________________________________________批处理文本数据库工具箱____________________________________________________________________________
REM 
REM                                                          本工具箱致力于文本数据库的操作效率简易化
REM                                                                        -20160625-
REM                                                     作者：F_Ms | 邮箱：imf_ms@yeah.net | 博客：f-ms.cn
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM 使用方法：
REM 	将子程序模块直接复制到自己代码中后直接根据使用方法调用即可(不会被正常运行到的位置)，每个子程序都可以独立运行，不需要的模块直抛弃就好了
REM 	所有子程序没有使用第三方工具，也没有使用不稳定的结果截取命令结果输出判断，兼容性无问题，WinXP/Win7/Win10测试均未出问题
REM 
REM 注意事项：
REM 	子程序运行需要变量延迟，setlocal ENABLEDELAYEDEXPANSION请注意开启
REM 	子程序使用了以下for %变量 (按十进制ASCII编码字符集排序),请在编写程序时for嵌套中调用批处理时避开这些变量名
REM 		%%; %%: %%^> %%? %%@ %%A %%B %%C %%D %%E %%F %%G %%H %%I %%J %%K %%L %%M %%N %%O %%P %%Q %%R %%S %%T %%U %%V %%W %%X %%Y %%Z %%[ %%\ %%] %%_
REM 	所有子程序未做过多特殊字符的处理及测试，故像"< > ( ) | &"等这些字符的兼容性就很难保证了
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM #	Database_Read	从指定文件、指定行、指定分隔符、指定列获取内容赋值到指定变量
REM 		call:Database_Read [/Q(安静模式，不提示错误)] "数据源文件" "数据列分隔符" "数据所在行" "以分隔符为分割的N列数据(列目号与列目号之间使用,分割，且可以区间分割符-)" "单个或多个变量(多个变量之间使用空格或,进行分割)"
REM 			例子：从文件 "c:\users\a\Database.ini" 中将以 "	" 为分隔符的第4行数据的第1,2,3,6列数据分别赋值到var1,var2,var3,var4
REM					call:Database_Read "c:\users\a\Database.ini" "	" "4" "1-3,6" "var1 var2 var3 var4"
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM #	Database_Update	修改指定文件的指定行以指定分隔符分割的指定列的内容
REM 		call:Database_Update [/Q(安静模式，不提示错误)] "数据源" "数据列分隔符" "欲修改数据所在开始行号" "以分隔符为分割的N列数据(列号与列号之间使用,分割，且可以区间分割符-)" "该行第一列修改后数据" "该行第二列修改后数据" ...
REM 			例子：从文件 "c:\users\a\Database.ini" 中第4行以 "	" 为分隔1,2,3,6列数据修改为分别修改为 string1 string2 string3 string4
REM					call:Database_Update "c:\users\a\Database.ini" "	" "4" "1-3,6" "string1" "string2" "string3" "string4"
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM #	Database_Print	从指定文件、指定行、指定分隔符、指定列获取内容并打印到屏幕或文件
REM call:Database_Print [/Q(安静模式，不提示错误)] [/LN(显示数据在整体打印内容中的序号,非数据在数据源文件中的行号)] [/HEAD 打印行头添加内容] [/FOOT 打印行尾追加内容] "数据源" "数据提取分隔符" "数据打印分隔符" "打印数据行(支持单数分隔符,与区间连续分隔符-,0为指定全部行)" "以分隔符为分割的N列数据(列号与列号之间使用,分割，且可以区间分割符-)" [/F 文件(将内容输出到文件)] 
REM 			例子：将文件 "c:\users\a\Database.ini" 中的第4-5行以 "	" 为分隔符的第1,2,3,6列数据以"*"为分隔符打印出来
REM 				call:Database_Print "c:\users\a\Database.ini" "	" "*" "4-5" 1-3,6"
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM #	Database_Find	从指定文件、指定行、指定分隔符、指定列、指定字符串搜索并将搜索结果的行列号写入到指定变量中
REM 		call:Database_Find [/Q(安静模式，不提示错误)] [/i(不区分大小写)] [/first(返回查找到的第一个结果)] "数据源" "数据列分隔符"  "查找字符串" "查找数据行(支持单数分隔符,与区间连续分隔符-,0为指定全部行)" "查找数据列(支持单数分隔符,与区间连续分隔符-)" "查找结果行号列号结果接受赋值变量名"
REM 			注意---------------------------------------------------------------------------------------------------------------------------------
REM 				结果变量的输出格式为："行 列","行 列","..."依次递加，例如第二行第三列和第五行第六列的赋值内容就为："2 3","5 6"
REM 				可以使用 'for %%a in (%结果变量%) do for /f "tokens=1,2" %%b in ("%%~a") do echo=第%%b行，第%%c列' 的方法进行结果使用
REM 				---------------------------------------------------------------------------------------------------------------------------------
REM 			例子：从文件 "c:\users\a\Database.ini"中第三到五行以"	"为分隔符的第一列中不区分大小写的查找字符串data(完全匹配)并将搜索结果的行列号赋值到变量result
REM 				call:Database_Find /i "c:\users\a\Database.ini" "	" "data" "3-5" "1" "result"
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM #	Database_Insert	插入数据到指定文本数据库文件中
REM 		call:Database_Insert [/Q(安静模式，不提示错误)] "数据源" [/LN [插入到行位置(默认底部追加)]] "数据列分隔符" "数据1" "数据2" "数据3" "..."
REM 			例子：将数据"data1" "data2" "data3" 以 "	"为分隔符插入到文本数据库文件" "c:\users\a\Database.ini"
REM 				call:Database_Insert "c:\users\a\Database.ini" "	" "data1" "data2" "data3"
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM #	Database_Sort	排序行数据使其转移到指定行
REM 		call:Database_Sort [/Q(安静模式，不提示错误)] "数据源" "欲排序行号" "排序后行号"
REM 			例子：把文件 "c:\users\a\Database.ini" 中第四行排序到原第二行的位置
REM 				call:Database_Sort "c:\users\a\Database.ini" "4" "2"
REM ____________________________________________________________________________________________________________________________________________________________________
REM 
REM #	Database_DeleteLine	删除指定文件指定行
REM 		call:Database_DeleteLine [/Q(安静模式，不提示错误)] "数据源" "欲删除数据起始行" "从起始行开始继续向下删除多少行(包括本行，向下到结尾请输入0)"
REM 			例子：把文件 "c:\users\a\Database.ini" 中第二第三行删除
REM 				call:Database_DeleteLine "c:\users\a\Database.ini" "2" "2"
REM ____________________________________________________________________________________________________________________________________________________________________

:---------------------Database_Print---------------------:

REM 从指定文件、指定行、指定分隔符、指定列获取内容并打印到屏幕或文件
REM call:Database_Print [/Q(安静模式，不提示错误)] [/LN(显示数据在整体打印内容中的序号,非数据在数据源文件中的行号)] [/HEAD 打印行头添加内容] [/FOOT 打印行尾追加内容] "数据源" "数据提取分隔符" "数据打印分隔符" "打印数据行(支持单数分隔符,与区间连续分隔符-,0为指定全部行)" "以分隔符为分割的N列数据(列号与列号之间使用,分割，且可以区间分割符-)" [/F 文件(将内容输出到文件)] 
REM 例子：将文件 "c:\users\a\Database.ini" 中的第4-5行以 "	" 为分隔符的第1,2,3,6列数据以"*"为分隔符打印出来
REM					call:Database_Print "c:\users\a\Database.ini" "	" "*" "4-5" 1-3,6"
REM 返回值详情：0-运行正常，1-查无此行，2-参数不符合子程序
REM 注意：列数值最高只支持到31列，推荐在创建数据的时候使用制表符"	"为分隔符，以防后期数据和分隔符混淆,文本数据库中不要含有空行和空值，防止返回数据错误
REM 版本:20160625
:Database_Print
REM 检查子程序运行基本需求参数
for %%A in (d_P_ErrorPrint d_P_LineNumber d_P_PrintHead d_P_PrintFoot) do set "%%A="
if /i "%~1"=="/ln" (
	set "d_P_LineNumber=Yes"
	shift/1
) else if /i "%~1"=="/q" (shift/1) else set "d_P_ErrorPrint=Yes"
if /i "%~1"=="/ln" (
	set "d_P_LineNumber=Yes"
	shift/1
) else if /i "%~1"=="/q" (shift/1) else set "d_P_ErrorPrint=Yes"

if /i "%~1"=="/head" (
	set "d_P_PrintHead=%~2"
	shift/1
	shift/1
) else if /i "%~1"=="/foot" (
	set "d_P_PrintFoot=%~2"
	shift/1
	shift/1
)
if /i "%~1"=="/head" (
	set "d_P_PrintHead=%~2"
	shift/1
	shift/1
) else if /i "%~1"=="/foot" (
	set "d_P_PrintFoot=%~2"
	shift/1
	shift/1
)

if /i "%~6"=="/f" if "%~7"=="" (
	if defined d_P_ErrorPrint echo=	[错误%0:参数7-指定输出文件为空]
)
if "%~5"=="" (
	if defined d_P_ErrorPrint echo=	[错误%0:参数6-指定列目号为空]
	exit/b 2
)
if "%~4"=="" (
	if defined d_P_ErrorPrint echo=	[错误%0:参数4-指定行号为空]
	exit/b 2
)
if "%~3"=="" (
	if defined d_P_ErrorPrint echo=	[错误%0:参数3-指定数据打印分隔符为空]
	exit/b 2
)
if "%~2"=="" (
	if defined d_P_ErrorPrint echo=	[错误%0:参数2-指定数据提取分隔符为空]
	exit/b 2
)
if "%~1"=="" (
	if defined d_P_ErrorPrint echo=	[错误%0:参数1-指定数据源文件为空]
	exit/b 2
) else if not exist "%~1" (
	if defined d_P_ErrorPrint echo=	[错误%0:参数1-指定数据源文件不存在:%~1]
	exit/b 2
)
REM 初始化变量
for %%_ in (d_P_Count d_P_Count2 d_P_Count3 d_P_ValueTemp d_P_StringTest d_P_Count4 d_P_Pass) do set "%%_="
for /f "delims==" %%_ in ('set d_P_AlreadyLineNumber 2^>nul') do set "%%_="
if /i "%~6"=="/f" (
	set d_P_File=">>"%~7""
	if exist "%~7" del /f /q "%~7"
) else set "d_P_File= "

REM 子程序开始运作

REM 判断用户输入行号是否符合规则
set "d_P_StringTest=%~4"
for %%_ in (1,2,3,4,5,6,7,8,9,0,",",-) do if defined d_P_StringTest set "d_P_StringTest=!d_P_StringTest:%%~_=!"
if defined d_P_StringTest (
	if defined d_P_ErrorPrint echo=	[错误%0:参数4:指定查找行不符合规则:%~4]
	exit/b 2
)
for %%_ in (%~4) do (
	set "d_P_Pass="
	set "d_P_Pass=%%~_"
	if "!d_P_Pass!"=="!d_P_Pass:-=!" (
		if "%%~_"=="0" (
			set "d_P_Count2=0"
			set "d_P_Count=No"
			set "d_P_Pass="
			) else (
			set /a "d_P_Count2=%%~_-1"
			set /a "d_P_Pass=%%~_-1"
			set "d_P_Count=0"
			if "!d_P_Pass!"=="0" (set "d_P_Pass=") else set "d_P_Pass=skip=!d_P_Pass!"
			)
		call:Database_Print_Run "%~1" "%~2" "%~3" "%~5"
	) else (
		for /f "tokens=1,2 delims=-" %%: in ("%%~_") do (
			if "%%~:"=="%%~;" (
				set "d_P_Count2=%%~:-1"
				set /a "d_P_Pass=%%~:-1"
				set "d_P_Count=0"
				) else call:Database_Print2 "%%~:" "%%~;"
			if "!d_P_Pass!"=="0" (set "d_P_Pass=") else set "d_P_Pass=skip=!d_P_Pass!"
			call:Database_Print_Run "%~1" "%~2" "%~3" "%~5"
		)
	)
)
exit/b 0


REM call:Database_Print_Run "文件" "数据提取分隔符" "数据打印分隔符" "列号"
:Database_Print_Run
set "d_P_Count3="
(
	for /f "usebackq %d_P_Pass% eol=^ tokens=%~4 delims=%~2" %%? in ("%~1") do (
		set /a "d_P_Count3+=1"
		set /a "d_P_Count2+=1"
		
		if not defined d_P_AlreadyLineNumber!d_P_Count2! (
			set "d_P_AlreadyLineNumber!d_P_Count2!=Yes"
			set /a "d_P_Count4+=1"
			
			if defined d_P_LineNumber set "d_P_LineNumber=!d_P_Count4!.%~3"
			for /f "eol=^ delims=%%" %%^> in ("!d_P_LineNumber!%%?%~3%%@%~3%%A%~3%%B%~3%%C%~3%%D%~3%%E%~3%%F%~3%%G%~3%%H%~3%%I%~3%%J%~3%%K%~3%%L%~3%%M%~3%%N%~3%%O%~3%%P%~3%%Q%~3%%R%~3%%S%~3%%T%~3%%U%~3%%V%~3%%W%~3%%X%~3%%Y%~3%%Z%~3%%[%~3%%\%~3%%]") do set d_P_ValueTemp=%%^>
			if "!d_P_ValueTemp:~-1!"=="%~3" (echo=%d_P_PrintHead%!d_P_ValueTemp:~0,-1!%d_P_PrintFoot%) else echo=%d_P_PrintHead%!d_P_ValueTemp!%d_P_PrintFoot%
		)
		if /i not "%d_P_Count%"=="No" (
			if "%d_P_Count%"=="0" exit/b 0
			if "!d_P_Count3!"=="%d_P_Count%" exit/b 0
		)
	)
)%d_P_File:~1,1%%d_P_File:~2,-1%

exit/b 0

REM 可能由于嵌套深度原因导致的问题不得不写出一个子程序进行判断
REM call:Database_Print2 第一个值 第二个值
:Database_Print2
if %~10 gtr %~20 (
	set /a "d_P_Count2=%~2-1"
	set /a "d_P_Pass=%~2-1"
	set /a "d_P_Count=%~1-%~2+1"
) else (
	set /a "d_P_Count2=%~1-1"
	set /a "d_P_Pass=%~1-1"
	set /a "d_P_Count=%~2-%~1+1"
)
exit/b


:---------------------Database_Insert---------------------:


REM 插入数据到指定文本数据库文件中
REM call:Database_Insert [/Q(安静模式，不提示错误)] "数据源" [/LN [插入到行位置(默认底部追加)]] "数据列分隔符" "数据1" "数据2" "数据3" "..."
REM 例子：将数据"data1" "data2" "data3" 以 "	"为分隔符插入到文本数据库文件" "c:\users\a\Database.ini"
REM					call:Database_Insert "c:\users\a\Database.ini" "	" "data1" "data2" "data3"
REM 返回值详情：0-运行正常，1-查无此行，2-参数不符合子程序
REM 注意：列数值最高只支持到31列，推荐在创建数据的时候使用制表符"	"为分隔符，以防后期数据和分隔符混淆,文本数据库中不要含有空行和空值，防止返回数据错误
REM 版本:20160507
:Database_Insert
REM 检查子程序运行基本需求参数
for %%A in (d_I_ErrorPrint d_I_LineNumber d_I_Value) do set "%%A="
if /i "%~1"=="/q" (
	shift/1
) else set "d_I_ErrorPrint=Yes"

if "%~2"=="" (
	if defined d_I_ErrorPrint echo=	[错误%0:参数3-指定分隔符为空]
	exit/b 2
)
if /i "%~2"=="/LN" if "%~3"=="" (
	if defined d_I_ErrorPrint echo=	[错误%0:参数3-指定插入行号为空]
	exit/b 2
) else (
	set "d_I_LineNumber=%~3"
	shift/2
	shift/2
)
if defined d_I_LineNumber if %d_I_LineNumber%0 lss 10 (
	if defined d_I_ErrorPrint echo=	[错误%0:参数3-指定插入行号小于1]
	exit/b 2
)
if "%~3"=="" (
	if defined d_I_ErrorPrint echo=	[错误%0:参数3-指定写入数据为空]
	exit/b 2
)
if "%~2"=="" (
	if defined d_I_ErrorPrint echo=	[错误%0:参数2-指定分隔符为空]
	exit/b 2
)
if "%~1"=="" (
	if defined d_I_ErrorPrint echo=	[错误%0:参数1-指定数据源文件为空]
	exit/b 2
) else if not exist "%~1" (
	if defined d_I_ErrorPrint echo=	[错误%0:参数1-指定数据源文件不存在:%~1]
	exit/b 2
)

REM 初始化变量
for %%_ in (d_I_Count d_I_Pass1 d_I_Temp_File) do set "%%_="
for /l %%_ in (1,1,31) do set "d_I_Value%%_="
if defined d_I_LineNumber (
	set "d_I_Temp_File=%~1_Temp"
	if exist "%d_I_Temp_File%" del /f /q "%d_I_Temp_File%"
)

REM 子程序开始运作
REM 提取用户指定值
:Database_Insert1
set /a "d_I_Count+=1"
set "d_I_Value%d_I_Count%=%~3"
if not "%~4"=="" (
	shift/3
	goto Database_Insert1
)
for /l %%_ in (1,1,%d_I_Count%) do (
	set "d_I_Value=!d_I_Value!%~2!d_I_Value%%_!"
)
set "d_I_Value=%d_I_Value:~1%"
REM 未指定插入行号情况
if not defined d_I_LineNumber call:Database_Insert_Echo d_I_Value>>"%~1"&exit/b 0
REM 指定插入行号情况
REM 检测插入行是否存在
set /a "d_I_Pass1=%d_I_LineNumber%-1"
if "%d_I_Pass1%"=="0" (set "d_I_Pass1=") else set "d_I_Pass1=skip=%d_I_Pass1%"
for /f "usebackq %d_I_Pass1% eol=^ delims=" %%? in ("%~1") do goto Database_Insert2
if defined d_I_ErrorPrint echo=	[错误%0:结果:查无此行:%d_I_LineNumber%]
exit/b 1
:Database_Insert2
set "d_I_Count="
REM 指定行前段数据写入临时文件
set /a "d_I_Count2=%d_I_LineNumber%-1"
if "%d_I_Count2%"=="0" goto Database_Insert3
for /f "usebackq eol=^ delims=" %%? in ("%~1") do (
	set /a "d_I_Count+=1"
	echo=%%?
	if "!d_I_Count!"=="%d_I_Count2%" goto Database_Insert3
)>>"%d_I_Temp_File%"
:Database_Insert3
REM 写入插入数据到临时文件
call:Database_Insert_Echo d_I_Value>>"%d_I_Temp_File%"
REM 写入插入行后部数据到临时文件
(
	for /f "usebackq %d_I_Pass1% eol=^ delims=" %%? in ("%~1") do echo=%%?
)>>"%d_I_Temp_File%"
REM 将临时文本数据库文件覆盖源文本数据库文件
copy "%d_I_Temp_File%" "%~1">nul 2>nul
if not "%errorlevel%"=="0" (
	if defined d_I_ErrorPrint echo=	[错误%0:结果:数据覆盖失败，疑似权限不足或文件不存在]
	exit/b 1
)
if exist "%d_I_Temp_File%" del /f /q "%d_I_Temp_File%"
exit/b 0

REM 用于解决输出到数据不能结尾为空格+0/1/2/3和不能含有()问题
REM call:Database_Insert_Echo 变量名
:Database_Insert_Echo
echo=!%~1!
exit/b 0


:---------------------Database_Read---------------------:

REM 从指定文件、指定行、指定分隔符、指定列获取内容赋值到指定变量
REM call:Database_Read [/Q(安静模式，不提示错误)] "数据源文件" "数据列分隔符" "数据所在行" "以分隔符为分割的N列数据(列目号与列目号之间使用,分割，且可以区间分割符-)" "单个或多个变量(多个变量之间使用空格或,进行分割)"
REM 例子：从文件 "c:\users\a\Database.ini" 中将以 "	" 为分隔符的第4行数据的第1,2,3,6列数据分别赋值到var1,var2,var3,var4
REM					call:Database_Read "c:\users\a\Database.ini" "	" "4" "1-3,6" "var1 var2 var3 var4"
REM 返回值详情：0-运行正常，1-查无此行，2-参数不符合子程序
REM 注意：列数值最高只支持到31列，推荐在创建数据的时候使用制表符"	"为分隔符，以防后期数据和分隔符混淆,文本数据库中不要含有空行和空值，防止返回数据错误
REM 版本:20151127
:Database_Read
REM 检查子程序运行基本需求参数
set "d_R_ErrorPrint="
if /i "%~1"=="/q" (shift/1) else set "d_R_ErrorPrint=Yes"
if "%~5"=="" (
	if defined d_R_ErrorPrint echo=	[错误%0:参数5-指定被赋值变量名为空]
	exit/b 2
)
if "%~4"=="" (
	if defined d_R_ErrorPrint echo=	[错误%0:参数4-指定列目号为空]
	exit/b 2
)
if "%~3"=="" (
	if defined d_R_ErrorPrint echo=	[错误%0:参数3-指定行号为空]
	exit/b 2
)
if %~3 lss 1 (
	if defined d_R_ErrorPrint echo=	[错误%0:参数3-指定行号小于1:%~3]
	exit/b 2
)
if "%~2"=="" (
	if defined d_R_ErrorPrint echo=	[错误%0:参数2-指定分隔符为空]
	exit/b 2
)
if "%~1"=="" (
	if defined d_R_ErrorPrint echo=	[错误%0:参数1-指定数据源文件为空]
	exit/b 2
) else if not exist "%~1" (
	if defined d_R_ErrorPrint echo=	[错误%0:参数1-指定数据源文件不存在:%~1]
	exit/b 2
)

REM 初始化变量
for %%_ in (d_R_Count d_R_Pass) do set "%%_="
for /l %%_ in (1,1,31) do if defined d_R_Count%%_ set "d_R_Count%%_="
set /a "d_R_Pass=%~3-1"
if "%d_R_Pass%"=="0" (set "d_R_Pass=") else set "d_R_Pass=skip=%d_R_Pass%"

REM 子程序开始运作
for %%_ in (%~5) do (
	set /a "d_R_Count+=1"
	set "d_R_Count!d_R_Count!=%%_"
)
set "d_R_Count="
for /f "usebackq eol=^ %d_R_Pass% tokens=%~4 delims=%~2" %%? in ("%~1") do (
	for %%_ in ("!d_R_Count1!=%%~?","!d_R_Count2!=%%~@","!d_R_Count3!=%%~A","!d_R_Count4!=%%~B","!d_R_Count5!=%%~C","!d_R_Count6!=%%~D","!d_R_Count7!=%%~E","!d_R_Count8!=%%~F","!d_R_Count9!=%%~G","!d_R_Count10!=%%~H","!d_R_Count11!=%%~I","!d_R_Count12!=%%~J","!d_R_Count13!=%%~K","!d_R_Count14!=%%~L","!d_R_Count15!=%%~M","!d_R_Count16!=%%~N","!d_R_Count17!=%%~O","!d_R_Count18!=%%~P","!d_R_Count19!=%%~Q","!d_R_Count20!=%%~R","!d_R_Count21!=%%~S","!d_R_Count22!=%%~T","!d_R_Count23!=%%~U","!d_R_Count24!=%%~V","!d_R_Count25!=%%~W","!d_R_Count26!=%%~X","!d_R_Count27!=%%~Y","!d_R_Count28!=%%~Z","!d_R_Count29!=%%~[","!d_R_Count30!=%%~\","!d_R_Count31!=%%~]") do (
		set /a "d_R_Count+=1"
		if defined d_R_Count!d_R_Count! set %%_
	)
	exit/b 0
)
if not defined d_R_Count if defined d_R_ErrorPrint echo=	[错误%0:结果-查无此行:%~3]
exit/b 1


:---------------------Database_Sort---------------------:

REM 排序行数据使其转移到指定行
REM call:Database_Sort [/Q(安静模式，不提示错误)] "数据源" "欲排序行号" "排序后行号"
REM 例子：把文件 "c:\users\a\Database.ini" 中第四行排序到原第二行的位置
REM					call:Database_Sort "c:\users\a\Database.ini" "4" "2"
REM 返回值详情：0-运行正常，1-查无此行，2-参数不符合子程序，3-两排序行值相同
REM 版本:20151204
:Database_Sort
REM 检查子程序运行基本需求参数
for %%A in (d_S_ErrorPrint) do set "%%A="
if /i "%~1"=="/q" (
	shift/1
) else set "d_S_ErrorPrint=Yes"
if "%~3"=="" (
	if defined d_S_ErrorPrint echo=	[错误%0:参数3-指定排序后所在行为空]
	exit/b 2
)
if %~3 lss 0 (
	if defined d_S_ErrorPrint echo=	[错误%0:参数3-指定排序后所在行小于0:%~2]
)
if "%~2"=="" (
	if defined d_S_ErrorPrint echo=	[错误%0:参数2-指定欲排序行为空]
	exit/b 3
)
if %~2 lss 0 (
	if defined d_S_ErrorPrint echo=	[错误%0:参数2-指定欲排序行小于0:%~2]
)
if "%~2"=="%~3" (
	if defined d_S_ErrorPrint echo=	[错误%0:参数2;参数1:欲排序行与排序后所在行相同，无实际意义，请检查后重试:%~2:%~3]
	exit/b 1
)
if "%~1"=="" (
	if defined d_S_ErrorPrint echo=	[错误%0:参数1-指定数据源文件为空]
	exit/b 2
) else if not exist "%~1" (
	if defined d_S_ErrorPrint echo=	[错误%0:参数1-指定数据源文件不存在:%~1]
	exit/b 2
)

REM 初始化变量
for %%_ in (d_S_Count d_S_Count2 d_S_Pass1 d_S_Pass2 d_S_Pass3 d_S_Temp_File) do set "%%_="
set "d_S_Temp_File=%~1_Temp"
if exist "%d_S_Temp_File%" del /f /q "%d_S_Temp_File%"


if %~2 lss %~3 (
	REM 前端内容
	set /a "d_S_Count1=%~2-1"
	REM 起始行后，结束行前
	set /a "d_S_Pass1=%~2
	set /a "d_S_Count2=%~3-%~2"
	REM 起始行内容
	set /a "d_S_Pass2=%~2-1"
	set /a "d_S_LineDefinedCheck1=%~2-1"
	REM 结束行后(包括结束行)
	set /a "d_S_Pass3=%~3"
	set /a "d_S_LineDefinedCheck2=%~3-1"
) else (
	REM 前端内容
	set /a "d_S_Count1=%~3-1"
	REM 起始行内容
	set /a "d_S_Pass1=%~2-1"
	set /a "d_S_LineDefinedCheck1=%~2-1"
	REM 结束行(包括结束行)到起始行之间内容
	set /a "d_S_Pass2=%~3-1"
	set /a "d_S_Count2=%~2-%~3"
	set /a "d_S_LineDefinedCheck2=%~3-1"
	REM 起始行后内容
	set /a "d_S_Pass3=%~2"
)

for %%_ in (d_S_LineDefinedCheck1 d_S_LineDefinedCheck2 d_S_Pass1 d_S_Pass2 d_S_Pass3) do if "!%%_!"=="0" (set "%%_=") else set "%%_=skip=!%%_!"

REM 判定是否有指定删除行
for /f "usebackq eol=^ %d_S_LineDefinedCheck1% delims=" %%? in ("%~1") do goto Database_Sort_2
if defined d_S_ErrorPrint (
	echo=	[错误:%0:结果:查无此行:%~2]
)
exit/b 1
:Database_Sort_2
for /f "usebackq eol=^ %d_S_LineDefinedCheck2% delims=" %%? in ("%~1") do goto Database_Sort_3
if defined d_S_ErrorPrint (
	echo=	[错误:%0:结果:查无此行:%~3]
)
:Database_Sort_3

REM 子程序开始运作
REM 文本数据库前端内容写入
if not "%d_S_Count1%"=="0" for /f "usebackq eol=^ delims=" %%_ in ("%~1") do (
	set /a "d_S_Count+=1"
	echo=%%_
	if "!d_S_Count!"=="!d_S_Count1!" goto Database_Sort1
)>>"%d_S_Temp_File%"

:Database_Sort1
set "d_S_Count="
(
	if %~2 lss %~3 (
		for /f "usebackq %d_S_Pass1% eol=^ delims=" %%_ in ("%~1") do (
			set /a "d_S_Count+=1"
			echo=%%_
			if "!d_S_Count!"=="%d_S_Count2%" goto Database_Sort2
		)
	) else (
		for /f "usebackq %d_S_Pass1% eol=^ delims=" %%_ in ("%~1") do (
			echo=%%_
			goto Database_Sort2
		)
	)
)>>"%d_S_Temp_File%"

:Database_Sort2
set "d_S_Count="
(
	if %~2 lss %~3 (
		for /f "usebackq %d_S_Pass2% eol=^ delims=" %%_ in ("%~1") do (
			echo=%%_
			goto Database_Sort3
		)
	) else (
		for /f "usebackq %d_S_Pass2% eol=^ delims=" %%_ in ("%~1") do (
			set /a "d_S_Count+=1"
			echo=%%_
			if "!d_S_Count!"=="%d_S_Count2%" goto Database_Sort3
		)
	)
)>>"%d_S_Temp_File%"
:Database_Sort3
for /f "usebackq %d_S_Pass3% eol=^ delims=" %%_ in ("%~1") do (
	echo=%%_
)>>"%d_S_Temp_File%"

REM 将临时文本数据库文件覆盖源文本数据库文件
copy "%d_S_Temp_File%" "%~1">nul 2>nul
if not "%errorlevel%"=="0" (
	if defined d_S_ErrorPrint echo=	[错误%0:结果:数据覆盖失败，疑似权限不足或文件不存在]
	exit/b 1
)
if exist "%d_S_Temp_File%" del /f /q "%d_S_Temp_File%"
exit/b 0

:---------------------Database_Update---------------------:


REM 修改指定文件的指定行以指定分隔符分割的指定列的内容
REM call:Database_Update [/Q(安静模式，不提示错误)] "数据源" "数据列分隔符" "欲修改数据所在开始行号" "以分隔符为分割的N列数据(列号与列号之间使用,分割，且可以区间分割符-)" "该行第一列修改后数据" "该行第二列修改后数据" ...
REM 例子：从文件 "c:\users\a\Database.ini" 中第4行以 "	" 为分隔1,2,3,6列数据修改为分别修改为 string1 string2 string3 string4
REM					call:Database_Update "c:\users\a\Database.ini" "	" "4" "1-3,6" "string1" "string2" "string3" "string4"
REM 返回值详情：0-运行正常，1-查无此行，2-参数不符合子程序
REM 注意：列数值最高只支持到31列，推荐在创建数据的时候使用制表符"	"为分隔符，以防后期数据和分隔符混淆,文本数据库中不要含有空行和空值，防止返回数据错误
REM 版本:20151130
:Database_Update
REM 检查子程序运行基本需求参数
for %%A in (d_U_ErrorPrint) do set "%%A="
if /i "%~1"=="/q" (
	shift/1
) else set "d_U_ErrorPrint=Yes"
if "%~5"=="" (
	if defined d_U_ErrorPrint echo=	[错误%0:参数5-指定修改后数据为空]
	exit/b 2
)
if "%~4"=="" (
	if defined d_U_ErrorPrint echo=	[错误%0:参数4-指定列号为空]
	exit/b 2
)
if "%~3"=="" (
	if defined d_U_ErrorPrint echo=	[错误%0:参数3-指定行号为空]
	exit/b 2
)
if %~3 lss 1 (
	if defined d_U_ErrorPrint echo=	[错误%0:参数3-指定行号小于1:%~3]
	exit/b 2
)
if "%~2"=="" (
	if defined d_U_ErrorPrint echo=	[错误%0:参数2-数据列分隔符为空]
	exit/b 2
)
if "%~1"=="" (
	if defined d_U_ErrorPrint echo=	[错误%0:参数1-指定数据源文件为空]
	exit/b 2
) else if not exist "%~1" (
	if defined d_U_ErrorPrint echo=	[错误%0:参数1-指定数据源文件不存在:%~1]
	exit/b 2
)
REM 初始化变量
for %%_ in (d_U_Count d_U_Pass1 d_U_Pass2 d_U_Pass3 d_U_Temp_File d_U_FinalValue d_U_Value) do set "%%_="
for /l %%_ in (1,1,31) do (
	set "d_U_Value%%_="
	set "d_U_FinalValue%%_="
)
set "d_U_Temp_File=%~1_Temp"
if exist "%d_U_Temp_File%" del /f /q "%d_U_Temp_File%"
set /a "d_U_Pass3=%~3"
set /a "d_U_Pass2=%~3-1"
set /a "d_U_Pass1=%~3-1"

set "d_U_Pass3=skip=%d_U_Pass3%"
if "%d_U_Pass2%"=="0" (set "d_U_Pass2=") else set "d_U_Pass2=skip=%d_U_Pass2%"

REM 判定是否有指定修改行
for /f "usebackq eol=^ %d_U_Pass2% delims=" %%? in ("%~1") do goto Database_Updata_2
if defined d_U_ErrorPrint (
	echo=	[错误:%0:结果:查无此行:%~3]
)
exit/b 1
:Database_Updata_2
if %d_U_Pass1% leq 0 goto Database_Updata2

REM 子程序开始运作
REM 共分三阶段进行修改，将文本数据库源文件分为三阶段：修改行前内容提取写入，修改行提取修改并写入，修改行后内容提取并写入 进行修改文本数据库

REM 修改行前内容提取写入阶段
:Database_Updata1

(
	for /f "usebackq eol=^ delims=" %%? in ("%~1") do (
		set /a "d_U_Count+=1"
		echo=%%?
		if "!d_U_Count!"=="%d_U_Pass1%" goto Database_Updata2
	)
)>>"%d_U_Temp_File%"

REM 修改行提取修改并写入阶段
:Database_Updata2
set "d_U_Count="

:Database_Updata2_2
REM 将用户指定修改内容赋值到序列变量
set /a "d_U_Count+=1"
set "d_U_Value%d_U_Count%=%~5"
if not "%~6"=="" (
	shift/5
	goto Database_Updata2_2
)

set "d_U_Count="

REM 将用户指定修改内容赋值到行整体数据位置序列变量
for /f "tokens=%~4 delims=," %%? in ("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31") do set "d_U_Column=%%? %%@ %%A %%B %%C %%D %%E %%F %%G %%H %%I %%J %%K %%L %%M %%N %%O %%P %%Q %%R %%S %%T %%U %%V %%W %%X %%Y %%Z %%[ %%\ %%]"
for /f "delims=%%" %%a in ("%d_U_Column%") do set "d_U_Column=%%a"
for %%a in (%d_U_Column%) do (
	set /a "d_U_Count+=1"
	call:Database_Updata_Var d_U_FinalValue%%a d_U_Value!d_U_Count!
)

set "d_U_Count="

REM 将文本数据库修改行不被修改的数据赋值到行整体数据位置序列变量(已经被赋值的序列变量则跳过)
for /f "usebackq eol=^ tokens=1-31 %d_U_Pass2% delims=%~2" %%? in ("%~1") do (
	for %%_ in ("%%?" "%%@" "%%A" "%%B" "%%C" "%%D" "%%E" "%%F" "%%G" "%%H" "%%I" "%%J" "%%K" "%%L" "%%M" "%%N" "%%O" "%%P" "%%Q" "%%R" "%%S" "%%T" "%%U" "%%V" "%%W" "%%X" "%%Y" "%%Z" "%%[" "%%\" "%%]") do (
		if "%%~_"=="" goto Database_Updata2_3
		set /a "d_U_Count+=1"
		if not defined d_U_FinalValue!d_U_Count! set "d_U_FinalValue!d_U_Count!=%%~_"
	)
	goto Database_Updata2_3
)
:Database_Updata2_3
if "%d_U_FinalValue1%"=="" (
	if not defined d_U_ErrorPrint echo=	[错误%0:结果:查无此行]
	exit/b 1
)
REM 将修改后修改行正式写入临时文本数据库文件
for /l %%_ in (1,1,%d_U_Count%) do (
	set "d_U_FinalValue=!d_U_FinalValue!%~2!d_U_FinalValue%%_!"
)
set "d_U_FinalValue=%d_U_FinalValue:~1%"
call:Database_Update_Echo d_U_FinalValue>>"%d_U_Temp_File%"

REM 修改行后内容提取并写入阶段
:Database_Updata3
(
	for /f "usebackq %d_U_Pass3% eol=^ delims=" %%? in ("%~1") do echo=%%?
)>>"%d_U_Temp_File%"

REM 将临时文本数据库文件覆盖源文本数据库文件，修改完毕
copy "%d_U_Temp_File%" "%~1">nul 2>nul
if not "%errorlevel%"=="0" (
	if defined d_U_ErrorPrint echo=	[错误%0:结果:修改后数据覆盖失败，疑似权限不足或文件不存在]
	exit/b 1
)
if exist "%d_U_Temp_File%" del /f /q "%d_U_Temp_File%"
exit/b 0

REM 由于变量深度问题延伸出的子程序
:Database_Updata_Var
set "%~1=!%~2!"
exit/b 0
REM 用于解决输出到数据不能结尾为空格+0/1/2/3和不能含有()问题
REM call:Database_Update_Echo 变量名
:Database_Update_Echo
echo=!%~1!
exit/b 0

:---------------------Database_Find---------------------:

REM 从指定文件、指定行、指定分隔符、指定列、指定字符串搜索并将搜索结果的行列号写入到指定变量中
REM call:Database_Find [/Q(安静模式，不提示错误)] [/i(不区分大小写)] [/first(返回查找到的第一个结果)] "数据源" "数据列分隔符"  "查找字符串" "查找数据行(支持单数分隔符,与区间连续分隔符-,0为指定全部行)" "查找数据列(支持单数分隔符,与区间连续分隔符-)" "查找结果行号列号结果接受赋值变量名"
	REM 注意：-------------------------------------------------------------------------------------------------------------------------------
	REM 	结果变量的输出格式为："行 列","行 列","..."依次递加，例如第二行第三列和第五行第六列的赋值内容就为："2 3","5 6"
	REM 	可以使用 'for %%a in (%结果变量%) do for /f "tokens=1,2" %%b in ("%%~a") do echo=第%%b行，第%%c列' 的方法进行结果使用
	REM -------------------------------------------------------------------------------------------------------------------------------------
REM 例子：从文件 "c:\users\a\Database.ini"中第三到五行以"	"为分隔符的第一列中不区分大小写的查找字符串data(完全匹配)并将搜索结果的行列号赋值到变量result
REM					call:Database_Find /i "c:\users\a\Database.ini" "	" "data" "3-5" "1" "result"
REM 返回值详情：0-根据指定字符串找到结果并已赋值变量，1-未查找到结果，2-参数不符合子程序
REM 注意：列数值最高只支持到31列，推荐在创建数据的时候使用制表符"	"为分隔符，以防后期数据和分隔符混淆,文本数据库中不要含有空行和空值，防止返回数据错误
REM 版本:20160625
:Database_Find
REM 检查子程序运行基本需求参数
for %%A in (d_F_ErrorPrint d_F_Insensitive d_F_FindFirst) do set "%%A="
if /i "%~1"=="/i" (
	set "d_F_Insensitive=/i"
	shift/1
) else if /i "%~1"=="/q" (shift/1) else set "d_F_ErrorPrint=Yes"
if /i "%~1"=="/i" (
	set "d_F_Insensitive=/i"
	shift/1
) else if /i "%~1"=="/q" (shift/1) else set "d_F_ErrorPrint=Yes"

if /i "%~1"=="/first" (
	set d_F_FindFirst=Yes
	shift/1
)

if "%~6"=="" (
	if defined d_F_ErrorPrint echo=	[错误%0:参数6-指定接受结果变量名为空]
	exit/b 2
)
if "%~5"=="" (
	if defined d_F_ErrorPrint echo=	[错误%0:参数5-指定查找列号为空]
	exit/b 2
)
if "%~4"=="" (
	if defined d_F_ErrorPrint echo=	[错误%0:参数4-指定查找行号为空]
	exit/b 2
)
if "%~3"=="" (
	if defined d_F_ErrorPrint echo=	[错误%0:参数3-指定查找字符串为空]
	exit/b 2
)
if "%~2"=="" (
	if defined d_F_ErrorPrint echo=	[错误%0:参数2-指定数据列分隔符为空]
	exit/b 2
)
if "%~1"=="" (
	if defined d_F_ErrorPrint echo=	[错误%0:参数1-指定数据源文件为空]
	exit/b 2
) else if not exist "%~1" (
	if defined d_F_ErrorPrint echo=	[错误%0:参数1-指定数据源文件不存在:%~1]
	exit/b 2
)

REM 初始化变量
for %%_ in (d_F_Count d_F_StringTest d_F_Count2 d_F_Pass %~6) do set "%%_="
for /f "delims==" %%_ in ('set d_F_AlreadyLineNumber 2^>nul') do set "%%_="
for /f "delims==" %%_ in ('set d_F_Column 2^>nul') do set "%%_="

REM 子程序开始运作
REM 判断用户输入行号是否符合规则
set "d_F_StringTest=%~4"
for %%_ in (1,2,3,4,5,6,7,8,9,0,",",-) do if defined d_F_StringTest set "d_F_StringTest=!d_F_StringTest:%%~_=!"
if defined d_F_StringTest (
	if defined d_F_ErrorPrint echo=	[错误%0:参数4:指定查找行号不符合规则:%~4]
	exit/b 2
)

REM 将列号赋值到列变量
for /f "tokens=%~5" %%? in ("1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31") do for /f "delims=%%" %%_ in ("%%? %%@ %%A %%B %%C %%D %%E %%F %%G %%H %%I %%J %%K %%L %%M %%N %%O %%P %%Q %%R %%S %%T %%U %%V %%W %%X %%Y %%Z %%[ %%\ %%]") do for %%: in (%%_) do (
	set /a "d_F_Count+=1"
	set "d_F_Column!d_F_Count!=%%:"
)
set "d_F_Count="
REM 根据行号进行拆分执行命令
for %%_ in (%~4) do (
	set "d_F_Pass="
	set "d_F_Pass=%%~_"
	if "!d_F_Pass!"=="!d_F_Pass:-=!" (
		if "%%~_"=="0" (
			set "d_F_Count2=0"
			set "d_F_Count=No"
			set "d_F_Pass="
		) else (
			set /a "d_F_Count2=%%~_-1"
			set /a "d_F_Pass=%%~_-1"
			set "d_F_Count=0"
			if "!d_F_Pass!"=="0" (set "d_F_Pass=") else set "d_F_Pass=skip=!d_F_Pass!"
		)
		call:Database_Find_Run "%~1" "%~2" "%~5" "%~3" "%~6"
		if defined d_F_FindFirst if defined %~6 (
			set "%~6=!%~6:~1!"
			exit/b 0
		)
	) else (
		for /f "tokens=1,2 delims=-" %%: in ("%%~_") do (
			if "%%~:"=="%%~;" (
				set /a "d_F_Count2=%%~:-1"
				set /a "d_F_Pass=%%~:-1"
				set "d_F_Count=0"
			) else call:Database_Find2 "%%~:" "%%~;"
			if "!d_F_Pass!"=="0" (set "d_F_Pass=") else set "d_F_Pass=skip=!d_F_Pass!"
			call:Database_Find_Run "%~1" "%~2" "%~5" "%~3" "%~6"
			if defined d_F_FindFirst if defined %~6 (
				set "%~6=!%~6:~1!"
				exit/b 0
			)
		)
	)
)

if defined %~6 (set "%~6=!%~6:~1!") else (
	if defined d_F_ErrorPrint echo=	[结果%0:根据关键字"%~3"未能从指定文件行列中找到结果]
	exit/b 1
)
exit/b 0

REM call:Database_Find_Run "文件" "分隔符" "列" "查找字符串" "变量名"
:Database_Find_Run
set "d_F_Count3="
for /f "usebackq %d_F_Pass% eol=^ tokens=%~3 delims=%~2" %%? in ("%~1") do (
	set /a "d_F_Count3+=1"
	set /a "d_F_Count2+=1"
	
	if not defined d_F_AlreadyLineNumber!d_F_Count2! (
		set "d_F_AlreadyLineNumber!d_F_Count2!=Yes"
		
		if "%%?"=="%%~?" (
			if %d_F_Insensitive% "%%?"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column1!"&if defined d_F_FindFirst exit/b
		)
		if "%%@"=="%%~@" (
			if %d_F_Insensitive% "%%@"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column2!"&if defined d_F_FindFirst exit/b
		)
		if "%%A"=="%%~A" (
			if %d_F_Insensitive% "%%A"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column3!"&if defined d_F_FindFirst exit/b
		)
		if "%%B"=="%%~B" (
			if %d_F_Insensitive% "%%B"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column4!"&if defined d_F_FindFirst exit/b
		)
		if "%%C"=="%%~C" (
			if %d_F_Insensitive% "%%C"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column5!"&if defined d_F_FindFirst exit/b
		)
		if "%%D"=="%%~D" (
			if %d_F_Insensitive% "%%D"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column6!"&if defined d_F_FindFirst exit/b
		)
		if "%%E"=="%%~E" (
			if %d_F_Insensitive% "%%E"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column7!"&if defined d_F_FindFirst exit/b
		)
		if "%%F"=="%%~F" (
			if %d_F_Insensitive% "%%F"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column8!"&if defined d_F_FindFirst exit/b
		)
		if "%%G"=="%%~G" (
			if %d_F_Insensitive% "%%G"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column9!"&if defined d_F_FindFirst exit/b
		)
		if "%%H"=="%%~H" (
			if %d_F_Insensitive% "%%H"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column10!"&if defined d_F_FindFirst exit/b
		)
		if "%%I"=="%%~I" (
			if %d_F_Insensitive% "%%I"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column11!"&if defined d_F_FindFirst exit/b
		)
		if "%%J"=="%%~J" (
			if %d_F_Insensitive% "%%J"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column12!"&if defined d_F_FindFirst exit/b
		)
		if "%%K"=="%%~K" (
			if %d_F_Insensitive% "%%K"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column13!"&if defined d_F_FindFirst exit/b
		)
		if "%%L"=="%%~L" (
			if %d_F_Insensitive% "%%L"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column14!"&if defined d_F_FindFirst exit/b
		)
		if "%%M"=="%%~M" (
			if %d_F_Insensitive% "%%M"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column15!"&if defined d_F_FindFirst exit/b
		)
		if "%%N"=="%%~N" (
			if %d_F_Insensitive% "%%N"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column16!"&if defined d_F_FindFirst exit/b
		)
		if "%%O"=="%%~O" (
			if %d_F_Insensitive% "%%O"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column17!"&if defined d_F_FindFirst exit/b
		)
		if "%%P"=="%%~P" (
			if %d_F_Insensitive% "%%P"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column18!"&if defined d_F_FindFirst exit/b
		)
		if "%%Q"=="%%~Q" (
			if %d_F_Insensitive% "%%Q"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column19!"&if defined d_F_FindFirst exit/b
		)
		if "%%R"=="%%~R" (
			if %d_F_Insensitive% "%%R"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column20!"&if defined d_F_FindFirst exit/b
		)
		if "%%S"=="%%~S" (
			if %d_F_Insensitive% "%%S"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column21!"&if defined d_F_FindFirst exit/b
		)
		if "%%T"=="%%~T" (
			if %d_F_Insensitive% "%%T"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column22!"&if defined d_F_FindFirst exit/b
		)
		if "%%U"=="%%~U" (
			if %d_F_Insensitive% "%%U"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column23!"&if defined d_F_FindFirst exit/b
		)
		if "%%V"=="%%~V" (
			if %d_F_Insensitive% "%%V"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column24!"&if defined d_F_FindFirst exit/b
		)
		if "%%W"=="%%~W" (
			if %d_F_Insensitive% "%%W"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column25!"&if defined d_F_FindFirst exit/b
		)
		if "%%X"=="%%~X" (
			if %d_F_Insensitive% "%%X"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column26!"&if defined d_F_FindFirst exit/b
		)
		if "%%Y"=="%%~Y" (
			if %d_F_Insensitive% "%%Y"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column27!"&if defined d_F_FindFirst exit/b
		)
		if "%%Z"=="%%~Z" (
			if %d_F_Insensitive% "%%Z"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column28!"&if defined d_F_FindFirst exit/b
		)
		if "%%["=="%%~[" (
			if %d_F_Insensitive% "%%["=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column29!"&if defined d_F_FindFirst exit/b
		)
		if "%%\"=="%%~\" (
			if %d_F_Insensitive% "%%\"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column30!"&if defined d_F_FindFirst exit/b
		)
		if "%%]"=="%%~]" (
			if %d_F_Insensitive% "%%]"=="%~4" set %~5=!%~5!,"!d_F_Count2! !d_F_Column31!"&if defined d_F_FindFirst exit/b
		)
	)
	if /i not "%d_F_Count%"=="No" (
		if "%d_F_Count%"=="0" exit/b
		if "!d_F_Count3!"=="%d_F_Count%" exit/b
	)
)
exit/b

REM 可能由于嵌套深度原因导致的问题不得不写出一个子程序进行判断
REM call:Database_Find2 第一个值 第二个值
:Database_Find2
if %~10 gtr %~20 (
	set /a "d_F_Count2=%~2-1"
	set /a "d_F_Pass=%~2-1"
	set /a "d_F_Count=%~1-%~2+1"
) else (
	set /a "d_F_Count2=%~1-1"
	set /a "d_F_Pass=%~1-1"
	set /a "d_F_Count=%~2-%~1+1"
)
exit/b

:---------------------Database_DeleteLine---------------------:

REM 删除指定文件指定行
REM call:Database_DeleteLine [/Q(安静模式，不提示错误)] "数据源" "欲删除数据起始行" "从起始行开始继续向下删除多少行(包括本行，向下到结尾请输入0)"
REM 例子：把文件 "c:\users\a\Database.ini" 中第二第三行删除
REM					call:Database_DeleteLine "c:\users\a\Database.ini" "2" "2"
REM 返回值详情：0-运行正常，1-查无此行，2-参数不符合子程序
REM 版本:20151130
:Database_DeleteLine
REM 检查子程序运行基本需求参数
for %%A in (d_DL_ErrorPrint) do set "%%A="
if /i "%~1"=="/q" (
	shift/1
) else set "d_DL_ErrorPrint=Yes"
if "%~3"=="" (
	if defined d_DL_ErrorPrint echo=	[错误%0:参数3-指定偏移行为空]
	exit/b 2
)
if %~3 lss 0 (
	if defined d_DL_ErrorPrint echo=	[错误%0:参数3-指定偏移行小于0:%~4]
)
if "%~2"=="" (
	if defined d_DL_ErrorPrint echo=	[错误%0:参数2-指定起始行号为空]
	exit/b 2
)
if %~2 lss 1 (
	if defined d_DL_ErrorPrint echo=	[错误%0:参数2-指定起始行号小于1:%~3]
	exit/b 2
)
if "%~1"=="" (
	if defined d_DL_ErrorPrint echo=	[错误%0:参数1-指定数据源文件为空]
	exit/b 2
) else if not exist "%~1" (
	if defined d_DL_ErrorPrint echo=	[错误%0:参数1-指定数据源文件不存在:%~1]
	exit/b 2
)

REM 初始化变量
for %%_ in (d_DL_Count d_DL_Pass1 d_DL_Pass2 d_DL_Pass3 d_DL_Temp_File) do set "%%_="
set "d_DL_Temp_File=%~1_Temp"
if exist "%d_DL_Temp_File%" del /f /q "%d_DL_Temp_File%"
set /a "d_DL_Pass3=%~2-1"
set /a "d_DL_Pass2=%~2+%~3-1"
set /a "d_DL_Pass1=%~2-1"

if "%d_DL_Pass3%"=="0" (set "d_DL_Pass3=") else set "d_DL_Pass3=skip=%d_DL_Pass3%"
if "%d_DL_Pass2%"=="0" (set "d_DL_Pass2=") else set "d_DL_Pass2=skip=%d_DL_Pass2%"

REM 判定是否有指定删除行
for /f "usebackq eol=^ %d_DL_Pass3% delims=" %%? in ("%~1") do goto Database_Updata_2
if defined d_DL_ErrorPrint (
	echo=	[错误:%0:结果:查无此行:%~3]
)
exit/b 1
:Database_Updata_2
if %d_DL_Pass1% leq 0 goto Database_Updata2
REM 子程序开始运作
REM 将删除行前内容写入到临时文本数据库文件
:Database_Updata1
(
	for /f "usebackq eol=^ delims=" %%? in ("%~1") do (
		set /a "d_DL_Count+=1"
		echo=%%?
		if "!d_DL_Count!"=="%d_DL_Pass1%" goto Database_Updata2
	)
)>>"%d_DL_Temp_File%"

REM 将删除行后内容写入到临时文本数据库文件
:Database_Updata2
if "%~3"=="0" (
	if "%~2"=="1" (if "a"=="b" echo=此处生成空文件)>>"%d_DL_Temp_File%"
) else (
	for /f "usebackq %d_DL_Pass2% eol=^ delims=" %%? in ("%~1") do echo=%%?
)>>"%d_DL_Temp_File%"

REM 将临时文本数据库文件覆盖源文本数据库文件
copy "%d_DL_Temp_File%" "%~1">nul 2>nul
if not "%errorlevel%"=="0" (
	if defined d_DL_ErrorPrint echo=	[错误%0:结果:删除后数据覆盖失败，疑似权限不足或文件不存在]
	exit/b 1
)
if exist "%d_DL_Temp_File%" del /f /q "%d_DL_Temp_File%"
exit/b 0

:-----------------------------------------------------------子程序结束分割线-----------------------------------------------------------:
:end