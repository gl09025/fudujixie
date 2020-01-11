@ echo off && PUSHD %~DP0 && mode con cols=80 lines=22
set program=MasterCAM ���⹷��װ��
set bin=%~dp0Bin\
set drvpath=%~dp0Drivers\
set drvname=mcamvusb

title %program% by ���С��
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
if '%fileerr%'=='1' (echo ��ǰ��װ�������������������أ� && goto end)

>NUL 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (goto UAC)
bcdedit |find "DISABLE_INTEGRITY_CHECKS" >nul && echo ���棺���Ѿ������ˡ���������ǩ����顱��Ϊ��֤����ϵͳ�����ȶ�����ͣ�ô�ģʽ��&& pause
goto menu

:UAC
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /b

:menu
set x6=δ
set x6old=δ
set x7=δ
set x7old=δ
set x6_s=δ
set x6old_s=δ
set x7_s=δ
set x7old_s=δ
%bin%devcon find root\%drvname%6 | find "Mastercam" >NUL && set x6=��
%bin%devcon status root\%drvname%6 | find "running" >NUL && set x6_s=��
%bin%devcon find root\%drvname%7 | find "Mastercam" >NUL && set x7=��
%bin%devcon status root\%drvname%7 | find "running" >NUL && set x7_s=��
%bin%devcon find root\%drvname% | find "Virtual Usb" >NUL && set x6old=��
%bin%devcon status root\%drvname% | find "running" >NUL && set x6old_s=��
%bin%devcon find root\MulttKey | find "Virtual Usb" >NUL && set x7old=��
%bin%devcon status root\MulttKey | find "running" >NUL && set x7old_s=��
cls
echo.
echo                         ����  %program% ����
echo                                                    https://www.bdgroup-lab.com
echo �������������������������������������������Щ��������������������Щ��������������������Щ���������������������������������������������������������������������
echo ��     ���⹷����     ��   ��װ   ��   ״̬   ��               ����               ��
echo �������������������������������������������੤�������������������੤�������������������੤��������������������������������������������������������������������
echo ��     x6��ֱװ�棩   ��  %x6%��װ  ��  %x6_s%����  �� 1.��װ/ж��  2.����/ͣ��  3.���� ��
echo �������������������������������������������੤�������������������੤�������������������੤��������������������������������������������������������������������
echo �� x7-2020��ֱװ�棩  ��  %x7%��װ  ��  %x7_s%����  �� 4.��װ/ж��  5.����/ͣ��  6.���� ��
echo �������������������������������������������੤�������������������੤�������������������੤��������������������������������������������������������������������
echo ��    x6-x9��SSQ��    ��  %x6old%��װ  ��  %x6old_s%����  �� 7.ж��       8.����/ͣ��  9.���� ��
echo �������������������������������������������੤�������������������੤�������������������੤��������������������������������������������������������������������
echo ��  2017-2020��SSQ��/ ��  %x7old%��װ  ��  %x7old_s%����  �� 10.ж��     11.����/ͣ�� 12.���� ��
echo ��    ����MultiKey    ��          ��          ��                                  ��
echo �������������������������������������������ة��������������������ة��������������������ة���������������������������������������������������������������������
echo ��  0.�˳�����                                                                 ��
echo ��������������������������������������������������������������������������������������������������������������������������������������������������������������
echo.
set /p act=����ѡ����س���
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
	echo ���ڵ���֤�顭����������ȫ������أ�����С���
	regedit /s "%bin%CA.reg"
	if "%1%"=="mcamvusb7" (echo. && echo ���ڰ�װ�ײ��������� 
		"%bin%haspdinst64.exe" -i
	)
	echo. && echo ���ڰ�װMastercam���⹷����
	regedit /s "%drvpath%%1.reg"
	"%bin%\devcon" install "%drvpath%%1.inf" root\%1
	echo.
	goto success
)

:restart
"%bin%devcon" find root\%1 | find "No" >nul
if '%errorlevel%'=='0' (goto nodevice)
echo ���������豸�����Ժ󡭡�
"%bin%devcon" restart root\%1
goto success

:uninstall
"%bin%devcon" find root\%1 | find "No" >nul
if '%errorlevel%'=='0' (goto nodevice)
echo ����ж�أ����Ժ󡭡�
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
echo ��ǰ���򲻼������Ĳ���ϵͳ��
goto end

:switch
"%bin%devcon" find root\%1 | find "No" >nul
if '%errorlevel%'=='0' (goto nodevice)
echo ���棺
echo 1��x6��x7-2020���⹷���ͬʱ���ã����ᵼ��x6���⹷ʧЧ��������Ҫʹ��x6���⹷�������x7-2020���⹷��
echo 2��x6���⹷��Ҫ�����������ΪNetHASP-Localģʽ��x7-2020���⹷��Ҫ�����������ΪHASPģʽ��������ʹ�ã�
echo.
"%bin%devcon" status root\%1 | find "running" >nul
if '%errorlevel%' NEQ '0' ("%bin%devcon" enable root\%1) else ("%bin%devcon" disable root\%1)
goto success

:success
echo. && echo ������ɣ�
goto gomenu

:end
echo ��������˳���
pause >NUL
exit

:nodevice
echo δ�����ļ�������ҵ������⹷��
goto gomenu

:gomenu
echo ��������������˵���
pause >nul
goto menu