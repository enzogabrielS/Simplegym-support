@echo off
setlocal
title SimpleGym - Desligar servidores
echo Salve suas alteracoes e pause o treino antes de continuar.
pause
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0simplegym-suporte\Desligar-SimpleGym.ps1"
if errorlevel 1 (
    echo.
    echo Nao foi possivel concluir. Confira a mensagem acima.
    pause
    exit /b 1
)
echo.
echo Desligamento concluido. Para abrir novamente, use Iniciar-SimpleGym.bat.
pause
endlocal
