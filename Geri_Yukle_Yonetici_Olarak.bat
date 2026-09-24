@echo off
chcp 65001 >nul
title Windows 11 AI Geri Yukleme Baslatici

:: Yönetici yetkisi kontrolü
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Bu script yonetici olarak calistirilmalidir.
    echo [!] Yonetici yetkileri talep ediliyor...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Enable-Windows11-AI.ps1"

pause
