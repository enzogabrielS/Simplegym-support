@echo off
setlocal
title SimpleGym - Iniciar aplicativo
echo Iniciando o SimpleGym...
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Iniciar-SimpleGym.ps1"
if errorlevel 1 (
    echo.
    echo Nao foi possivel iniciar um novo servidor.
    echo Se a mensagem acima indicar porta em uso, confira http://localhost:8080
    echo Caso contrario, confira o erro acima antes de tentar novamente.
    pause
    exit /b 1
)
echo.
echo SimpleGym iniciado. Acesse http://localhost:8080
start "" "http://localhost:8080"
echo Pode fechar esta janela. Os servidores continuam em segundo plano.
pause
endlocal
