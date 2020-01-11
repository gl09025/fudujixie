@ echo off && PUSHD %~DP0 && mode con cols=80 lines=22
set program=MasterCAM 虚拟狗安装器
set bin=%~dp0Bin\
set drvpath=%~dp0Drivers\
set drvname=mcamvusb

title %program% by 编程小子
ver | find "5.0." >NUL && goto syserr
ver | find "5.1." >NUL && goto syserr
ver | find "5.2." >NUL && goto syserr
if /i "%PROCESSOR_IDENTIFIER:~0,3%"=="X86" goto syserr

for %%i in (CA.reg Devcon.exe haspdinst64.exe) do (
	if not exist "%bin%%%i" set fileerr=1
)
for %%i in (6 7) do (
	for %%j in (reg cat inf sys) do (
		if not exist "%drvpath%%drvname%%%i.%%j" set fileerr=1
	)
)
if '%fileerr%'=='1' (echo 当前安装包不完整，请重新下载！ && goto end)

>NUL 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (goto UAC)
bcdedit |find "DISABLE_INTEGRITY_CHECKS" >nul && echo 警告：您已经启用了“禁用驱动签名检查”，为保证您的系统运行稳定，请停用此模式！&& pause
goto menu

:UAC
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /b

:menu
set x6=未
set x6old=未
set x7=未
set x7old=未
set x6_s=未
set x6old_s=未
set x7_s=未
set x7old_s=未
%bin%devcon find root\%drvname%6 | find "Mastercam" >NUL && set x6=已
%bin%devcon status root\%drvname%6 | find "running" >NUL && set x6_s=已
%bin%devcon find root\%drvname%7 | find "Mastercam" >NUL && set x7=已
%bin%devcon status root\%drvname%7 | find "running" >NUL && set x7_s=已
%bin%devcon find root\%drvname% | find "Virtual Usb" >NUL && set x6old=已
%bin%devcon status root\%drvname% | find "running" >NUL && set x6old_s=已
%bin%devcon find root\MulttKey | find "Virtual Usb" >NUL && set x7old=已
%bin%devcon status root\MulttKey | find "running" >NUL && set x7old_s=已
cls
echo.
echo                         ★★★  %program% ★★★
echo                                                    https://www.bdgroup-lab.com
echo ┌────────────────────┬──────────┬──────────┬──────────────────────────────────┐
echo │     虚拟狗类型     │   安装   │   状态   │               操作               │
echo ├────────────────────┼──────────┼──────────┼──────────────────────────────────┤
echo │     x6（直装版）   │  %x6%安装  │  %x6_s%启用  │ 1.安装/卸载  2.启用/停用  3.重启 │
echo ├────────────────────┼──────────┼──────────┼──────────────────────────────────┤
echo │ x7-2020（直装版）  │  %x7%安装  │  %x7_s%启用  │ 4.安装/卸载  5.启用/停用  6.重启 │
echo ├────────────────────┼──────────┼──────────┼──────────────────────────────────┤
echo │    x6-x9（SSQ）    │  %x6old%安装  │  %x6old_s%启用  │ 7.卸载       8.启用/停用  9.重启 │
echo ├────────────────────┼──────────┼──────────┼──────────────────────────────────┤
echo │  2017-2020（SSQ）/ │  %x7old%安装  │  %x7old_s%启用  │ 10.卸载     11.启用/停用 12.重启 │
echo │    其他MultiKey    │          │          │                                  │
echo ├────────────────────┴──────────┴──────────┴──────────────────────────────────┤
echo │  0.退出程序                                                                 │
echo └─────────────────────────────────────────────────────────────────────────────┘
echo.
set /p act=输入选项并按回车：
cls
if '%act%'=='1' call :install %drvname%6
if '%act%'=='2' call :switch %drvname%6
if '%act%'=='3' call :restart %drvname%6
if '%act%'=='4' call :install %drvname%7
if '%act%'=='5' call :switch %drvname%7
if '%act%'=='6' call :restart %drvname%7
if '%act%'=='7' call :uninstall %drvname%
if '%act%'=='8' call :switch %drvname%
if '%act%'=='9' call :restart %drvname%
if '%act%'=='10' call :uninstall MulttKey
if '%act%'=='11' call :switch MulttKey
if '%act%'=='12' call :restart MulttKey
if '%act%'=='0' exit /b
goto menu

:install
"%bin%devcon" find root\%1 | find "No" >nul
if '%errorlevel%' NEQ '0' (
	call :uninstall %1
) else (
	echo 正在导入证书……（如遇安全软件拦截，请放行。）
	regedit /s "%bin%CA.reg"
	if "%1%"=="mcamvusb7" (echo. && echo 正在安装底层驱动…… 
		"%bin%haspdinst64.exe" -i
	)
	echo. && echo 正在安装Mastercam虚拟狗……
	regedit /s "%drvpath%%1.reg"
	"%bin%\devcon" install "%drvpath%%1.inf" root\%1
	echo.
	goto success
)

:restart
"%bin%devcon" find root\%1 | find "No" >nul
if '%errorlevel%'=='0' (goto nodevice)
echo 正在重启设备，请稍后……
"%bin%devcon" restart root\%1
goto success

:uninstall
"%bin%devcon" find root\%1 | find "No" >nul
if '%errorlevel%'=='0' (goto nodevice)
echo 正在卸载，请稍后……
@"%bin%\devcon" remove root\%1
if exist "%systemroot%\system32\drivers\%1.sys" del "%systemroot%\system32\drivers\%1.sys" >nul
::call :regclean 584B4AE9
::if "%1"=="mcamvusb7" (call :regclean 4C8F743C)
goto success

:regclean
for %%i in (CurrentControlSet ControlSet002 ControlSet003) do (
	REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\%%i\MultiKey\Dumps\%1 >nul
	REG DELETE HKEY_LOCAL_MACHINE\SYSTEM\%%i\NEWHASP\Services\Emulator\HASP\Dump\%1 >nul
)

:syserr
cls
echo 当前程序不兼容您的操作系统。
goto end

:switch
"%bin%devcon" find root\%1 | find "No" >nul
if '%errorlevel%'=='0' (goto nodevice)
echo 警告：
echo 1、x6和x7-2020虚拟狗如果同时启用，将会导致x6虚拟狗失效。如您需要使用x6虚拟狗，请禁用x7-2020虚拟狗！
echo 2、x6虚拟狗需要在软件内设置为NetHASP-Local模式，x7-2020虚拟狗需要在软件内设置为HASP模式方可正常使用！
echo.
"%bin%devcon" status root\%1 | find "running" >nul
if '%errorlevel%' NEQ '0' ("%bin%devcon" enable root\%1) else ("%bin%devcon" disable root\%1)
goto success

:success
echo. && echo 操作完成！
goto gomenu

:end
echo 按任意键退出。
pause >NUL
exit

:nodevice
echo 未在您的计算机上找到此虚拟狗。
goto gomenu

:gomenu
echo 按任意键返回主菜单。
pause >nul
goto menu