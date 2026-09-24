@echo off
chcp 65001 >nul
title Windows 11 AI & RAM Optimizasyon Baslatici

:: Yonetici yetkisi kontrolu
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Yonetici yetkileri talep ediliyor...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: PowerShell scriptini calistir
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Disable-Windows11-AI.ps1"

pause
