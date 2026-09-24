<#
.SYNOPSIS
    Windows 11 Yapay Zeka (AI) ve RAM Tüketen Bileşenleri Devre Dışı Bırakma Scripti
.DESCRIPTION
    Bu script, Windows 11'de arka planda RAM ve CPU tüketen Copilot, Recall, AI Data Analysis, 
    Edge AI, Widgets (WebExperience), Bing Web Arama ve ilişkili yapay zeka servislerini devre dışı bırakır.
.DISCLAIMER
    TÜM SORUMLULUK KULLANANDADIR (USE AT YOUR OWN RISK).
    Bu script sistem kayıt defteri, servisler ve sistem ilkeleri üzerinde değişiklik yapar.
    Geliştirici veya yazar, bu aracın kullanımından doğabilecek herhangi bir sistem arızasından,
    veri kaybından veya beklenmedik durumdan sorumlu tutulamaz.
.NOTES
    Yönetici (Administrator) yetkileri ile çalıştırılmalıdır.
#>

param(
    [switch]$Silent,
    [switch]$All
)

# PowerShell sürümü ve Karakter Kodlaması Ayarları
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Windows 11 AI & RAM Optimizasyon Aracı"

# Yönetici Yetkisi Kontrolü ve Otomatik Yükseltme
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Bu script yönetici yetkileri gerektirir. Yönetici olarak yeniden başlatılıyor..." -ForegroundColor Yellow
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($Silent) { $argList += " -Silent" }
    if ($All) { $argList += " -All" }
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    exit
}

# Yardımcı Fonksiyonlar
function Print-Header {
    Clear-Host
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "       WINDOWS 11 YAPAY ZEKA (AI) KAPATMA & RAM OPTİMİZASYON ARACI        " -ForegroundColor Green
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "Bu araç Windows 11 Copilot, Recall, Edge AI, Arama AI ve arka plan        " -ForegroundColor Gray
    Write-Host "WebView2 servislerini devre dışı bırakarak RAM kullanımını azaltır.       " -ForegroundColor Gray
    Write-Host "--------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[!] YASAL UYARI: Bu aracın kullanımından doğabilecek TÜM SORUMLULUK        " -ForegroundColor Yellow
    Write-Host "    KULLANANDADIR (Use at your own risk). İşlem öncesi geri yükleme alınır." -ForegroundColor Yellow
    Write-Host "==========================================================================`n" -ForegroundColor Cyan
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

function Set-RegString {
    param([string]$Path, [string]$Name, [string]$Value)
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Create-RestorePointSafe {
    Write-Host "[*] Sistem Geri Yükleme Noktası oluşturuluyor (Güvenlik için)..." -ForegroundColor Yellow
    try {
        $restoreEnabled = (Get-ComputerRestorePoint -ErrorAction SilentlyContinue)
        if ($null -eq $restoreEnabled) {
            Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue | Out-Null
        }
        Checkpoint-Computer -Description "Windows11_AI_Kapatma_Oncesi" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop | Out-Null
        Write-Host "[+] Geri yükleme noktası başarıyla oluşturuldu." -ForegroundColor Green
    } catch {
        Write-Host "[-] Geri yükleme noktası oluşturulamadı veya Sistem Koruması devre dışı (İşleme devam ediliyor)." -ForegroundColor Gray
    }
}

# --- 1. COPILOT DEVRE DIŞI BIRAKMA VE KALDIRMA ---
function Disable-Copilot {
    Write-Host "`n>>> [1/7] Microsoft Copilot Devre Dışı Bırakılıyor ve Kaldırılıyor..." -ForegroundColor Cyan

    # Grup İlkeleri ve Kayıt Defteri Ayarları
    $regChanges = @(
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; Name = "TurnOffWindowsCopilot"; Value = 1 },
        @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"; Name = "TurnOffWindowsCopilot"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "TurnOffWindowsCopilot"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "RemoveMicrosoftCopilotApp"; Value = 1 },
        @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"; Name = "TurnOffWindowsCopilot"; Value = 1 },
        @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"; Name = "RemoveMicrosoftCopilotApp"; Value = 1 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowCopilotButton"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarCompanion"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\Shell\Copilot\BingChat"; Name = "IsUserEligible"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\Shell\Copilot"; Name = "IsCopilotAvailable"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\WindowsCopilot"; Name = "AllowCopilotRuntime"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoInstalledPWAs"; Name = "CopilotPWAPreinstallCompleted"; Value = 1 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoInstalledPWAs"; Name = "Microsoft.Copilot_8wekyb3d8bbwe"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx\RemoveDefaultMicrosoftStorePackages"; Name = "Enabled"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx\RemoveDefaultMicrosoftStorePackages\Microsoft.Copilot_8wekyb3d8bbwe"; Name = "RemovePackage"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx\RemoveDefaultMicrosoftStorePackages\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe"; Name = "RemovePackage"; Value = 1 }
    )

    foreach ($item in $regChanges) {
        Set-RegDword -Path $item.Path -Name $item.Name -Value $item.Value | Out-Null
    }

    Set-RegString -Path "HKCU:\Software\Microsoft\Windows\Shell\Copilot" -Name "CopilotDisabledReason" -Value "FeatureIsDisabled" | Out-Null

    # Copilot Başlangıç Görevi ve Ön Yüklemelerini Temizleme
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunNotification" -Name "*MicrosoftCopilotAutoLaunch*" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.Copilot_8wekyb3d8bbwe\Copilot.StartupTaskId" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe\WebViewHostStartupId" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

    # Appx Paketlerini Kaldırma (Copilot & OfficeHub arka plan webview)
    $copilotPackages = @(
        "*Microsoft.Copilot*",
        "*Windows.Ai.Copilot.Provider*",
        "*MicrosoftWindows.Client.CoPilot*",
        "*Microsoft.MicrosoftOfficeHub*"
    )

    foreach ($pkg in $copilotPackages) {
        Get-AppxPackage -Name $pkg -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "   [-] Kaldırılıyor: $($_.Name)" -ForegroundColor Yellow
            Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue | Out-Null
        }
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $pkg } | ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
    }

    Write-Host "[+] Copilot başarıyla devre dışı bırakıldı ve temizlendi." -ForegroundColor Green
}

# --- 2. WINDOWS RECALL VE AI VERİ ANALİZİNİ DEVRE DIŞI BIRAKMA ---
function Disable-Recall-And-AI {
    Write-Host "`n>>> [2/7] Windows Recall ve AI Veri Analizi Kapatılıyor..." -ForegroundColor Cyan

    $recallReg = @(
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableAIDataAnalysis"; Value = 1 },
        @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableAIDataAnalysis"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "AllowRecallEnablement"; Value = 0 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "TurnOffSavingSnapshots"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableClickToDo"; Value = 1 },
        @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableClickToDo"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableSettingsAgent"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableAgentConnectors"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableAgentWorkspaces"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableRemoteAgentConnectors"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"; Name = "LetAppsAccessGenerativeAI"; Value = 2 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"; Name = "LetAppsAccessSystemAIModels"; Value = 2 }
    )

    foreach ($item in $recallReg) {
        Set-RegDword -Path $item.Path -Name $item.Name -Value $item.Value | Out-Null
    }

    # İsteğe Bağlı Özellik Olan Recall'ı DISM ile Kaldırma
    try {
        dism.exe /Online /Disable-Feature /FeatureName:Recall /Remove /NoRestart /Quiet 2>$null | Out-Null
    } catch {}

    # Copilot+ PC AI Bileşen Paketleri
    $aiWorkloadPackages = @(
        "*MicrosoftWindows.Client.CoreAI*",
        "*MicrosoftWindows.Client.AIX*",
        "*WindowsWorkload.Data.Analysis*",
        "*WindowsWorkload.TextRecognition*",
        "*WindowsWorkload.ImageSearch*",
        "*WindowsWorkload.LanguageModel*"
    )
    foreach ($pkg in $aiWorkloadPackages) {
        Get-AppxPackage -Name $pkg -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "   [-] Kaldırılıyor: $($_.Name)" -ForegroundColor Yellow
            Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue | Out-Null
        }
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $pkg } | ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
    }

    Write-Host "[+] Windows Recall ve AI Veri Analizi başarıyla kapatıldı." -ForegroundColor Green
}

# --- 3. WIDGETS (ARAÇ TAKIMLARI & WEB EXPERIENCE) KAPATMA - EN BÜYÜK RAM KAZANCI ---
function Disable-Widgets {
    Write-Host "`n>>> [3/7] Windows Widgets ve WebExperience (Arka Plan WebView2 RAM Tüketimi) Kapatılıyor..." -ForegroundColor Cyan

    # Kayıt defteri politikası ile Widget'ları kapatma
    Set-RegDword -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 | Out-Null
    Set-RegDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 | Out-Null
    Set-RegDword -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Value 0 | Out-Null

    # Arka planda gizlice çalışan Widgets WebExperience WebView2 süreçlerini durdurma
    Get-Process -Name "Widgets", "WebExperienceHostApp" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    Write-Host "[+] Windows Widgets devre dışı bırakıldı (WebView2 RAM tasarrufu sağlandı)." -ForegroundColor Green
}

# Opsiyonel: WebExperience Paketini Tamamen Kaldırma
function Uninstall-WebExperience {
    Write-Host "   [-] WebExperience paketi tamamen sistemden kaldırılıyor..." -ForegroundColor Yellow
    Get-AppxPackage -Name "*WebExperience*" -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue | Out-Null
    }
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*WebExperience*" } | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host "[+] WebExperience paketi kaldırıldı." -ForegroundColor Green
}

# --- 4. WINDOWS ARAMA BING AI VE WEB ENTEGRASYONUNU KAPATMA ---
function Disable-Search-Web-AI {
    Write-Host "`n>>> [4/7] Başlat Menüsü Arama Bing AI & Web Önerileri Kapatılıyor..." -ForegroundColor Cyan
    Write-Host "   (SearchHost.exe'nin arka planda RAM tüketmesini engeller)" -ForegroundColor Gray

    $searchReg = @(
        @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"; Name = "DisableSearchBoxSuggestions"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "DisableWebSearch"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "ConnectedSearchUseWeb"; Value = 0 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "AllowSearchHighlights"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name = "BingSearchEnabled"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name = "CortanaConsent"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name = "DeviceHistoryEnabled"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"; Name = "IsBingSearchEnabled"; Value = 0 }
    )

    foreach ($item in $searchReg) {
        Set-RegDword -Path $item.Path -Name $item.Name -Value $item.Value | Out-Null
    }

    # Arama motorunu tazelemek ve bellek şişmesini sıfırlamak için SearchHost yeniden başlatılır
    Stop-Process -Name "SearchHost" -Force -ErrorAction SilentlyContinue

    Write-Host "[+] Bing Web Arama ve AI önerileri kapatıldı." -ForegroundColor Green
}

# --- 5. MICROSOFT EDGE COPILOT VE AI BİLEŞENLERİNİ KAPATMA ---
function Disable-Edge-AI {
    Write-Host "`n>>> [5/7] Microsoft Edge Copilot & AI Araçları Kapatılıyor..." -ForegroundColor Cyan

    $edgeReg = @(
        @{ Name = "HubsSidebarEnabled"; Value = 0 },
        @{ Name = "CopilotPageContext"; Value = 0 },
        @{ Name = "CopilotCDPPageContext"; Value = 0 },
        @{ Name = "DiscoverPageContextEnabled"; Value = 0 },
        @{ Name = "ComposeInlineEnabled"; Value = 0 },
        @{ Name = "AIGenThemesEnabled"; Value = 0 },
        @{ Name = "GenAILocalFoundationalModelSettings"; Value = 1 },
        @{ Name = "BuiltInAIAPIsEnabled"; Value = 0 },
        @{ Name = "EdgeHistoryAISearchEnabled"; Value = 0 },
        @{ Name = "ShareBrowsingHistoryWithCopilotSearchAllowed"; Value = 0 },
        @{ Name = "AllowBrowsingWithCopilot"; Value = 0 },
        @{ Name = "CopilotNewTabPageEnabled"; Value = 0 },
        @{ Name = "CopilotAddressBarSuggestionsEnabled"; Value = 0 },
        @{ Name = "CopilotCoworkToolActionsEnabled"; Value = 0 }
    )

    foreach ($item in $edgeReg) {
        Set-RegDword -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name $item.Name -Value $item.Value | Out-Null
    }

    Write-Host "[+] Microsoft Edge AI & Copilot özellikleri devre dışı bırakıldı." -ForegroundColor Green
}

# --- 6. AI ARKA PLAN SERVİSLERİ VE TELEMETRİ GÖREVLERİNİ DURDURMA ---
function Disable-AI-Services {
    Write-Host "`n>>> [6/7] AI Arka Plan Servisleri ve Telemetri Durduruluyor..." -ForegroundColor Cyan

    # AI ve Ajan Servisleri
    $servicesToStop = @(
        "WSAIFabricSvc",                     # Windows AI Fabric Service
        "MicrosoftCopilotElevationService",  # Copilot Elevation Service
        "AarSvc*"                            # Agent Activation Runtime Service
    )

    foreach ($svcName in $servicesToStop) {
        Get-Service -Name $svcName -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "   [-] Servis Durduruluyor & Devre Dışı Bırakılıyor: $($_.Name)" -ForegroundColor Yellow
            try {
                Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
            } catch {}
        }
    }

    # IsoEnvBroker (Yalıtılmış Ajan Ortamı) Kayıt Defterinde Devre Dışı Bırakma (4 = Disabled)
    Set-RegDword -Path "HKLM:\SYSTEM\CurrentControlSet\Services\IsoEnvBroker" -Name "Start" -Value 4 | Out-Null

    # Yazma / Çizim AI Eğitimi ve Telemetri Veri Toplamayı Kapatma
    $telemetryReg = @(
        @{ Path = "HKCU:\Software\Microsoft\input\Settings"; Name = "InsightsEnabled"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\InputPersonalization"; Name = "RestrictImplicitInkCollection"; Value = 1 },
        @{ Path = "HKCU:\Software\Microsoft\InputPersonalization"; Name = "RestrictImplicitTextCollection"; Value = 1 },
        @{ Path = "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"; Name = "HarvestContacts"; Value = 0 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CPSS\Store\InkingAndTypingPersonalization"; Name = "Value"; Value = 0 },
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name = "DisableConsumerAccountStateContent"; Value = 1 },
        @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint"; Name = "DisableImageCreator"; Value = 1 },
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\View"; Name = "IsSignedUpForTargetingService"; Value = 0 }
    )

    foreach ($item in $telemetryReg) {
        Set-RegDword -Path $item.Path -Name $item.Name -Value $item.Value | Out-Null
    }

    # Cortana Remnant Temizliği
    Get-AppxPackage -Name "*549981C3F5F10*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Out-Null

    Write-Host "[+] AI servisleri ve arka plan veri toplayıcıları durduruldu." -ForegroundColor Green
}

# --- 7. ANLIK RAM VE BELLEK TEMİZLİĞİ ---
function Optimize-Current-RAM {
    Write-Host "`n>>> [7/7] Çalışan Artık AI ve Arka Plan Süreçleri Sonlandırılıyor..." -ForegroundColor Cyan

    $procsToClean = @(
        "Copilot",
        "WebExperienceHostApp",
        "DiscoveryHubApp",
        "VisualAssistExe"
    )

    foreach ($proc in $procsToClean) {
        Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }

    # Windows Explorer'ı yeniden başlatarak görev çubuğu ve bellek tablosunu sıfırlama
    Write-Host "   [*] Windows Gezgini (Explorer) yenileniyor..." -ForegroundColor Yellow
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    if (-not (Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
        Start-Process explorer.exe
    }

    # Bellek Çöp Toplayıcıyı Tetikleme
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    Write-Host "[+] Bellek temizliği tamamlandı." -ForegroundColor Green
}

# --- TÜMÜNÜ ÇALIŞTIRMA FONKSİYONU ---
function Run-All-Optimizations {
    param([bool]$removeWebExp = $false)
    Create-RestorePointSafe
    Disable-Copilot
    Disable-Recall-And-AI
    Disable-Widgets
    if ($removeWebExp) {
        Uninstall-WebExperience
    }
    Disable-Search-Web-AI
    Disable-Edge-AI
    Disable-AI-Services
    Optimize-Current-RAM

    Write-Host "`n==========================================================================" -ForegroundColor Green
    Write-Host "                    TÜM İŞLEMLER BAŞARIYLA TAMAMLANDI!                    " -ForegroundColor Green
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host "Yapay zeka araçları kapatıldı ve arka plan bellek yükleri hafifletildi." -ForegroundColor White
    Write-Host "Değişikliklerin sistem genelinde tam etkinleşmesi için bilgisayarınızı" -ForegroundColor Yellow
    Write-Host "yeniden başlatmanız tavsiye edilir.`n" -ForegroundColor Yellow
}

# --- ÇALIŞTIRMA MANTIĞI ---
if ($Silent -or $All) {
    Print-Header
    Run-All-Optimizations -removeWebExp $true
    exit
}

do {
    Print-Header
    Write-Host "Lütfen yapmak istediğiniz işlemi seçin:" -ForegroundColor White
    Write-Host " [1] " -NoNewline -ForegroundColor Green; Write-Host "Tam AI Kaldırma & Maksimum RAM Tasarrufu (ÖNERİLEN - Hepsi)"
    Write-Host " [2] " -NoNewline -ForegroundColor Yellow; Write-Host "Sadece Copilot'u Kapat ve Kaldır"
    Write-Host " [3] " -NoNewline -ForegroundColor Yellow; Write-Host "Sadece Windows Recall & AI Veri Analizini Kapat"
    Write-Host " [4] " -NoNewline -ForegroundColor Yellow; Write-Host "Sadece Widgets / WebExperience Kapat (Yüksek RAM Tasarrufu)"
    Write-Host " [5] " -NoNewline -ForegroundColor Yellow; Write-Host "Sadece Başlat Arama Bing AI & Web Önerilerini Kapat"
    Write-Host " [6] " -NoNewline -ForegroundColor Yellow; Write-Host "Sadece Edge Tarayıcı AI & Copilot'u Kapat"
    Write-Host " [7] " -NoNewline -ForegroundColor Yellow; Write-Host "Sadece AI Servisleri & Telemetriyi Durdur"
    Write-Host " [8] " -NoNewline -ForegroundColor Cyan; Write-Host "Anlık RAM / Bellek Temizliği Yap"
    Write-Host " [0] " -NoNewline -ForegroundColor Red; Write-Host "Çıkış`n"

    $secim = Read-Host "Seçiminiz (0-8)"

    switch ($secim) {
        "1" {
            $webExpSecim = Read-Host "`nWebExperience paketini tamamen silmek istiyor musunuz? (Maksimum RAM için E, aksi halde H) [E/H]"
            $removePkg = ($webExpSecim -eq "E" -or $webExpSecim -eq "e")
            Run-All-Optimizations -removeWebExp $removePkg
            Write-Host "Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "2" {
            Create-RestorePointSafe
            Disable-Copilot
            Optimize-Current-RAM
            Write-Host "`nTamamlandı. Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "3" {
            Create-RestorePointSafe
            Disable-Recall-And-AI
            Write-Host "`nTamamlandı. Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "4" {
            Create-RestorePointSafe
            Disable-Widgets
            $webExpSecim = Read-Host "`nWebExperience paketini de tamamen silmek istiyor musunuz? [E/H]"
            if ($webExpSecim -eq "E" -or $webExpSecim -eq "e") {
                Uninstall-WebExperience
            }
            Optimize-Current-RAM
            Write-Host "`nTamamlandı. Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "5" {
            Create-RestorePointSafe
            Disable-Search-Web-AI
            Write-Host "`nTamamlandı. Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "6" {
            Create-RestorePointSafe
            Disable-Edge-AI
            Write-Host "`nTamamlandı. Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "7" {
            Create-RestorePointSafe
            Disable-AI-Services
            Write-Host "`nTamamlandı. Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "8" {
            Optimize-Current-RAM
            Write-Host "`nTamamlandı. Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
            Read-Host | Out-Null
        }
        "0" {
            Write-Host "`nÇıkış yapılıyor..." -ForegroundColor Gray
            exit
        }
        default {
            Write-Host "`nGeçersiz seçim, lütfen 0-8 arasında bir rakam girin." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($secim -ne "0")
