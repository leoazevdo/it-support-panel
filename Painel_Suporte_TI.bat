@echo off
chcp 65001 >nul
title Painel de Suporte TI - ********
color 0B
setlocal EnableExtensions

:: ============================================================
::  PAINEL DE SUPORTE - ********
::  Funcoes criticas exigem execucao como Administrador.
:: ============================================================

:: --- Verifica se esta rodando como administrador ---
set "ISADMIN=0"
net session >nul 2>&1
if %errorlevel%==0 set "ISADMIN=1"

:: --- Define o local do log (com fallback para a pasta TEMP) ---
set "LOGDIR=%ProgramData%\Painel_Suporte_TI"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1
if not exist "%LOGDIR%" set "LOGDIR=%TEMP%"
set "LOGFILE=%LOGDIR%\registro_acoes.log"

call :Log "Painel aberto (admin=%ISADMIN%)"

:MENU
cls
echo ==================================================
echo        ********  ^|  PAINEL DE SUPORTE DA TI
echo ==================================================
echo  PC: %COMPUTERNAME%   Usuario logado: %USERNAME%
if "%ISADMIN%"=="1" (echo  Permissao: ADMINISTRADOR) else (echo  Permissao: USUARIO COMUM - funcoes criticas bloqueadas)
echo ==================================================
echo.
echo --- MANUTENCAO DO SISTEMA ---
echo  [1] Limpeza de arquivos temporarios        (admin)
echo  [2] Limpeza de disco avancada              (admin)
echo  [3] Verificar e reparar arquivos do Windows (SFC) (admin)
echo  [4] Reparar a imagem do Windows (DISM)     (admin)
echo  [5] Verificar o disco C:                   (admin)
echo  [6] Saude do disco (HD/SSD)
echo.
echo --- REDE E INTERNET ---
echo  [7] Reset de rede (IP, Winsock e DNS)      (admin)
echo  [8] Informacoes de rede
echo  [9] Testes de conectividade
echo [10] Limpar cache DNS                       (admin)
echo [11] Abrir Conexoes de Rede
echo.
echo --- IMPRESSAO ---
echo [12] Limpar fila de impressao travada       (admin)
echo [13] Listar impressoras
echo.
echo --- DIAGNOSTICO ---
echo [14] Informacoes do sistema
echo [15] Monitor de recursos e processos
echo.
echo --- DRIVERS E ATUALIZACOES ---
echo [16] Dispositivos com erro
echo [17] Atualizar drivers (Windows Update)     (admin)
echo [18] Backup dos drivers                     (admin)
echo [19] Procurar atualizacoes do Windows       (admin)
echo.
echo --- TI ---
echo [20] Ver registro de acoes deste PC
if "%ISADMIN%"=="0" echo  [A] Reabrir este painel como Administrador
echo.
echo  [0] Sair
echo.
set "OPC="
set /p "OPC=Escolha uma opcao: "

if /i "%OPC%"=="A" goto ELEVAR
if "%OPC%"=="0" goto SAIR
if "%OPC%"=="1" goto OPT1
if "%OPC%"=="2" goto OPT2
if "%OPC%"=="3" goto OPT3
if "%OPC%"=="4" goto OPT4
if "%OPC%"=="5" goto OPT5
if "%OPC%"=="6" goto OPT6
if "%OPC%"=="7" goto OPT7
if "%OPC%"=="8" goto OPT8
if "%OPC%"=="9" goto OPT9
if "%OPC%"=="10" goto OPT10
if "%OPC%"=="11" goto OPT11
if "%OPC%"=="12" goto OPT12
if "%OPC%"=="13" goto OPT13
if "%OPC%"=="14" goto OPT14
if "%OPC%"=="15" goto OPT15
if "%OPC%"=="16" goto OPT16
if "%OPC%"=="17" goto OPT17
if "%OPC%"=="18" goto OPT18
if "%OPC%"=="19" goto OPT19
if "%OPC%"=="20" goto OPT20

echo.
echo Opcao invalida.
timeout /t 2 >nul
goto MENU

:: ============================================================
::  MANUTENCAO DO SISTEMA
:: ============================================================
:OPT1
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Limpeza de arquivos temporarios ===
echo.
echo Limpando %TEMP% ...
del /q /f /s "%TEMP%\*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1
echo Limpando %SystemRoot%\Temp ...
del /q /f /s "%SystemRoot%\Temp\*" >nul 2>&1
for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >nul 2>&1
echo Limpando Prefetch ...
del /q /f /s "%SystemRoot%\Prefetch\*" >nul 2>&1
echo.
echo Concluido. Arquivos em uso foram ignorados.
call :Log "Limpeza de arquivos temporarios"
pause
goto MENU

:OPT2
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Limpeza de disco avancada ===
echo.
echo Marque os itens desejados na janela que vai abrir e clique em OK.
pause
cleanmgr /sageset:65
echo Executando a limpeza... aguarde.
cleanmgr /sagerun:65
call :Log "Limpeza de disco avancada (cleanmgr)"
echo.
echo Concluido.
pause
goto MENU

:OPT3
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Verificar e reparar arquivos do Windows (SFC) ===
echo Isso pode levar varios minutos...
echo.
sfc /scannow
call :Log "SFC /scannow executado"
echo.
pause
goto MENU

:OPT4
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Reparar a imagem do Windows (DISM) ===
echo Isso pode levar varios minutos e exige internet...
echo.
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth
call :Log "DISM RestoreHealth executado"
echo.
pause
goto MENU

:OPT5
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Verificar o disco C: ===
echo.
echo Executando verificacao online (sem reiniciar)...
chkdsk C: /scan
call :Log "CHKDSK C: /scan executado"
echo.
set "R="
set /p "R=Agendar reparo completo (/f /r) para o proximo boot? (S/N): "
if /i "%R%"=="S" goto CHKDSK_AGENDAR
goto CHKDSK_FIM
:CHKDSK_AGENDAR
echo Y| chkdsk C: /f /r
call :Log "CHKDSK C: /f /r agendado para o proximo boot"
:CHKDSK_FIM
echo.
pause
goto MENU

:OPT6
cls
echo === Saude do disco (HD/SSD) ===
echo.
powershell -NoProfile -Command "Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, @{N='Tamanho(GB)';E={[math]::Round($_.Size/1GB,1)}} | Format-Table -AutoSize"
echo.
echo --- Volumes ---
powershell -NoProfile -Command "Get-Volume | Where-Object {$_.DriveLetter} | Select-Object DriveLetter, FileSystemLabel, HealthStatus, @{N='Livre(GB)';E={[math]::Round($_.SizeRemaining/1GB,1)}}, @{N='Total(GB)';E={[math]::Round($_.Size/1GB,1)}} | Format-Table -AutoSize"
call :Log "Consulta de saude do disco"
pause
goto MENU

:: ============================================================
::  REDE E INTERNET
:: ============================================================
:OPT7
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Reset de rede (IP, Winsock e DNS) ===
echo.
echo Isso vai redefinir a pilha de rede deste PC e pode derrubar a conexao
echo por alguns instantes. Recomenda-se reiniciar o computador depois.
echo.
set "R="
set /p "R=Deseja continuar? (S/N): "
if /i not "%R%"=="S" goto MENU
echo.
netsh winsock reset
netsh int ip reset
ipconfig /release
ipconfig /renew
ipconfig /flushdns
ipconfig /registerdns
call :Log "Reset de rede (winsock, ip, dns)"
echo.
echo Concluido. Reinicie o computador para aplicar totalmente.
pause
goto MENU

:OPT8
cls
echo === Informacoes de rede ===
echo.
ipconfig /all
call :Log "Consulta de informacoes de rede"
echo.
pause
goto MENU

:OPT9
cls
echo === Testes de conectividade ===
echo.
echo [1/4] Loopback (placa de rede local)
ping -n 2 127.0.0.1
echo.
echo [2/4] Gateway padrao
for /f "tokens=3" %%G in ('route print 0.0.0.0 ^| findstr /R /C:"^ *0\.0\.0\.0"') do (
    set "GW=%%G"
    goto TESTE_GW
)
:TESTE_GW
if defined GW (ping -n 2 %GW%) else (echo Gateway nao encontrado.)
echo.
echo [3/4] Internet por IP (8.8.8.8)
ping -n 2 8.8.8.8
echo.
echo [4/4] Resolucao de nomes (google.com)
nslookup google.com
ping -n 2 google.com
call :Log "Testes de conectividade"
echo.
pause
goto MENU

:OPT10
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Limpar cache DNS ===
echo.
ipconfig /flushdns
call :Log "Cache DNS limpo"
echo.
pause
goto MENU

:OPT11
start "" ncpa.cpl
call :Log "Abriu Conexoes de Rede"
goto MENU

:: ============================================================
::  IMPRESSAO
:: ============================================================
:OPT12
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Limpar fila de impressao travada ===
echo.
echo Parando o servico de spooler...
net stop spooler /y
echo Apagando arquivos da fila...
del /q /f /s "%SystemRoot%\System32\spool\PRINTERS\*" >nul 2>&1
echo Iniciando o servico de spooler...
net start spooler
call :Log "Fila de impressao limpa (spooler reiniciado)"
echo.
echo Concluido.
pause
goto MENU

:OPT13
cls
echo === Impressoras instaladas ===
echo.
powershell -NoProfile -Command "Get-Printer | Select-Object Name, DriverName, PortName, PrinterStatus | Format-Table -AutoSize"
call :Log "Listou impressoras"
pause
goto MENU

:: ============================================================
::  DIAGNOSTICO
:: ============================================================
:OPT14
cls
echo === Informacoes do sistema ===
echo.
systeminfo
call :Log "Consulta de informacoes do sistema"
echo.
pause
goto MENU

:OPT15
start "" resmon.exe
call :Log "Abriu Monitor de Recursos"
cls
echo === Processos que mais consomem memoria ===
echo.
powershell -NoProfile -Command "Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 Name, Id, @{N='Memoria(MB)';E={[math]::Round($_.WorkingSet/1MB,1)}}, CPU | Format-Table -AutoSize"
pause
goto MENU

:: ============================================================
::  DRIVERS E ATUALIZACOES
:: ============================================================
:OPT16
cls
echo === Dispositivos com erro ===
echo.
powershell -NoProfile -Command "$d = Get-PnpDevice -PresentOnly | Where-Object {$_.Status -ne 'OK'}; if ($d) { $d | Select-Object FriendlyName, Class, Status, InstanceId | Format-Table -AutoSize } else { Write-Host 'Nenhum dispositivo com erro encontrado.' -ForegroundColor Green }"
call :Log "Consulta de dispositivos com erro"
echo.
pause
goto MENU

:OPT17
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Atualizar drivers (Windows Update) ===
echo.
echo Reescaneando dispositivos...
pnputil /scan-devices
echo.
echo Abrindo atualizacoes opcionais (drivers) do Windows Update...
start "" ms-settings:windowsupdate-optionalupdates
call :Log "Atualizacao de drivers via Windows Update"
echo.
pause
goto MENU

:OPT18
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Backup dos drivers ===
echo.
for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%T"
set "DEST=C:\Backup_Drivers\%COMPUTERNAME%_%TS%"
mkdir "%DEST%" >nul 2>&1
echo Exportando drivers para: %DEST%
echo.
DISM /Online /Export-Driver /Destination:"%DEST%"
call :Log "Backup de drivers em %DEST%"
echo.
echo Concluido.
pause
goto MENU

:OPT19
call :RequireAdmin
if errorlevel 1 goto MENU
cls
echo === Procurar atualizacoes do Windows ===
echo.
usoclient StartScan
start "" ms-settings:windowsupdate
call :Log "Busca por atualizacoes do Windows"
echo Busca iniciada. Acompanhe na janela do Windows Update.
echo.
pause
goto MENU

:: ============================================================
::  TI
:: ============================================================
:OPT20
cls
echo === Registro de acoes deste PC ===
echo Arquivo: %LOGFILE%
echo.
if exist "%LOGFILE%" (type "%LOGFILE%") else (echo Nenhum registro encontrado.)
echo.
pause
goto MENU

:: ============================================================
::  FUNCOES AUXILIARES
:: ============================================================
:ELEVAR
echo.
echo Solicitando permissao de administrador...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b

:RequireAdmin
if "%ISADMIN%"=="1" exit /b 0
echo.
echo ==================================================
echo  ACESSO NEGADO
echo  Esta funcao exige execucao como ADMINISTRADOR.
echo  Feche o painel, clique com o botao direito no
echo  arquivo e escolha "Executar como administrador",
echo  ou use a opcao [A] no menu.
echo ==================================================
call :Log "Tentativa BLOQUEADA (sem admin) - opcao %OPC%"
echo.
pause
exit /b 1

:Log
>>"%LOGFILE%" echo [%date% %time%] %COMPUTERNAME% / %USERNAME% - %~1
exit /b

:SAIR
call :Log "Painel encerrado"
endlocal
exit /b
