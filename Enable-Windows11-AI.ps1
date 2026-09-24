<#
.SYNOPSIS
    Windows 11 Yapay Zeka (AI) ve Bileşenleri Yeniden Etkinleştirme (Geri Alma) Scripti
.DESCRIPTION
    Bu script, daha önce Disable-Windows11-AI.ps1 ile kapatılan Copilot, Recall, Edge AI,
    Arama ve servis ayarlarını orijinal Windows 11 varsayılanlarına geri döndürür.
.DISCLAIMER
    TÜM SORUMLULUK KULLANANDADIR (USE AT YOUR OWN RISK).
.NOTES
    Yönetici (Administrator) yetkileri ile çalıştırılmalıdır.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Windows 11 AI Geri Yükleme (Enable) Aracı"

# Yönetici Yetkisi Kontrolü
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Bu script yönetici yetkileri gerektirir. Yönetici olarak yeniden başlatılıyor..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Print-Header {
    Clear-Host
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "       WINDOWS 11 YAPAY ZEKA (AI) YENİDEN ETKİNLEŞTİRME (GERİ ALMA)       " -ForegroundColor Yellow
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "Bu script kapatılan AI özelliklerini ve servislerini varsayılana çevirir." -ForegroundColor Gray
    Write-Host "--------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[!] YASAL UYARI: TÜM SORUMLULUK KULLANANDADIR (Use at your own risk).     " -ForegroundColor Yellow
    Write-Host "==========================================================================`n" -ForegroundColor Cyan
}

function Remove-RegValue {
    param([string]$Path, [string]$Name)
    try {
        if (Test-Path $Path) {
            Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue | Out-Null
        }
    } catch {}
}

function Set-RegDword {
    param([string]$Path, [string]$Name, [int]$Value)
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Restore-Copilot {
    Write-Host "`n>>> Copilot Ayarları Varsayılana Döndürülüyor..." -ForegroundColor Cyan

    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot"
    Remove-RegValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "TurnOffWindowsCopilot"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "RemoveMicrosoftCopilotApp"
    Remove-RegValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "TurnOffWindowsCopilot"
    Remove-RegValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "RemoveMicrosoftCopilotApp"
    Remove-RegValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Copilot" -Name "CopilotDisabledReason"
    Remove-RegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\WindowsCopilot" -Name "AllowCopilotRuntime"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx\RemoveDefaultMicrosoftStorePackages" -Name "Enabled"

    Set-RegDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 1
    Set-RegDword -Path "HKCU:\Software\Microsoft\Windows\Shell\Copilot\BingChat" -Name "IsUserEligible" -Value 1
    Set-RegDword -Path "HKCU:\Software\Microsoft\Windows\Shell\Copilot" -Name "IsCopilotAvailable" -Value 1

    Write-Host "[+] Copilot ilkeleri sıfırlandı. (Uygulama silindiyse Microsoft Store'dan tekrar yüklenebilir)." -ForegroundColor Green
}

function Restore-Recall-And-AI {
    Write-Host "`n>>> Windows Recall ve AI Veri Analizi Varsayılana Döndürülüyor..." -ForegroundColor Cyan

    $keys = @(
        "DisableAIDataAnalysis", "AllowRecallEnablement", "TurnOffSavingSnapshots",
        "DisableClickToDo", "DisableSettingsAgent", "DisableAgentConnectors",
        "DisableAgentWorkspaces", "DisableRemoteAgentConnectors"
    )

    foreach ($k in $keys) {
        Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name $k
        Remove-RegValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name $k
    }

    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessGenerativeAI"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessSystemAIModels"

    try {
        Enable-WindowsOptionalFeature -Online -FeatureName "Recall" -NoRestart -ErrorAction SilentlyContinue | Out-Null
    } catch {}

    Write-Host "[+] Recall ve AI politikaları geri alındı." -ForegroundColor Green
}

function Restore-Widgets {
    Write-Host "`n>>> Windows Widgets (Araç Takımları) Varsayılana Döndürülüyor..." -ForegroundColor Cyan

    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds"
    Set-RegDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 1

    Write-Host "[+] Widgets ilkeleri sıfırlandı. (Paket silindiyse Microsoft Store'dan 'Windows Web Deneyimi Paketi' aranıp yüklenebilir)." -ForegroundColor Green
}

function Restore-Search-Web-AI {
    Write-Host "`n>>> Başlat Arama Web & Bing Önerileri Varsayılana Döndürülüyor..." -ForegroundColor Cyan

    Remove-RegValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchHighlights"
    Remove-RegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled"
    Remove-RegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsBingSearchEnabled"

    Stop-Process -Name "SearchHost" -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Arama web entegrasyonu varsayılana çevrildi." -ForegroundColor Green
}

function Restore-Edge-AI {
    Write-Host "`n>>> Edge AI İlkeleri Kaldırılıyor..." -ForegroundColor Cyan

    $edgeKeys = @(
        "HubsSidebarEnabled", "CopilotPageContext", "CopilotCDPPageContext",
        "DiscoverPageContextEnabled", "ComposeInlineEnabled", "AIGenThemesEnabled",
        "GenAILocalFoundationalModelSettings", "BuiltInAIAPIsEnabled", "EdgeHistoryAISearchEnabled",
        "ShareBrowsingHistoryWithCopilotSearchAllowed", "AllowBrowsingWithCopilot",
        "CopilotNewTabPageEnabled", "CopilotAddressBarSuggestionsEnabled", "CopilotCoworkToolActionsEnabled"
    )

    foreach ($k in $edgeKeys) {
        Remove-RegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name $k
    }

    Write-Host "[+] Edge AI ilkeleri temizlendi." -ForegroundColor Green
}

function Restore-Services {
    Write-Host "`n>>> AI Servisleri Varsayılan Başlangıç Tipine Çevriliyor..." -ForegroundColor Cyan

    Get-Service -Name "WSAIFabricSvc", "MicrosoftCopilotElevationService" -ErrorAction SilentlyContinue | ForEach-Object {
        Set-Service -Name $_.Name -StartupType Manual -ErrorAction SilentlyContinue
    }

    Set-RegDword -Path "HKLM:\SYSTEM\CurrentControlSet\Services\IsoEnvBroker" -Name "Start" -Value 3

    # Telemetri ve Çizim / Yazma Ayarları
    Remove-RegValue -Path "HKCU:\Software\Microsoft\input\Settings" -Name "InsightsEnabled"
    Remove-RegValue -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection"
    Remove-RegValue -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection"
    Remove-RegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint" -Name "DisableImageCreator"

    Write-Host "[+] Servisler normale döndürüldü." -ForegroundColor Green
}

function Restore-All {
    Restore-Copilot
    Restore-Recall-And-AI
    Restore-Widgets
    Restore-Search-Web-AI
    Restore-Edge-AI
    Restore-Services

    Write-Host "`n[*] Windows Gezgini yenileniyor..." -ForegroundColor Yellow
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue

    Write-Host "`n==========================================================================" -ForegroundColor Green
    Write-Host "                GERİ YÜKLEME İŞLEMİ TAMAMLANDI!                           " -ForegroundColor Green
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host "Tüm kısıtlamalar kaldırıldı ve Windows varsayılanlarına döndürüldü." -ForegroundColor White
    Write-Host "Değişikliklerin geçerli olması için bilgisayarınızı yeniden başlatın.`n" -ForegroundColor Yellow
}

Print-Header
Write-Host "Tüm AI ve RAM ayarlarını varsayılana döndürmek istiyor musunuz? [E/H]" -ForegroundColor White
$confirm = Read-Host
if ($confirm -eq "E" -or $confirm -eq "e") {
    Restore-All
} else {
    Write-Host "`nİşlem iptal edildi." -ForegroundColor Gray
}

Write-Host "Çıkmak için Enter tuşuna basın..." -ForegroundColor Gray
Read-Host | Out-Null
