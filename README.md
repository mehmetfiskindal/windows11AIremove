# 🚀 Windows 11 AI Remove & RAM Optimizer

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2011-blue?style=for-the-badge&logo=windows" alt="Platform: Windows 11" />
  <img src="https://img.shields.io/badge/Language-PowerShell-5391FE?style=for-the-badge&logo=powershell" alt="Language: PowerShell" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License: MIT" />
  <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge" alt="PRs Welcome" />
</p>

<p align="center">
  <b>Windows 11'deki yapay zeka (AI) bileşenlerini, telemetriyi ve arka plan WebView2 süreçlerini devre dışı bırakarak RAM ve CPU tasarrufu sağlayan açık kaynaklı optimizasyon aracı.</b><br>
  <i>An open-source utility to disable AI bloatware (Copilot, Recall, Edge AI, Search AI) and reclaim RAM on Windows 11.</i>
</p>

---

> [!WARNING]
> **YASAL UYARI / DISCLAIMER:**  
> **Bu aracın kullanımından doğabilecek TÜM SORUMLULUK KULLANICIYA AİTTİR.**  
> Bu script sistem kayıt defterinde (Registry), Windows servislerinde ve grup ilkelerinde değişiklikler yapar. İşlem öncesinde her ne kadar otomatik Sistem Geri Yükleme Noktası oluşturulsa da, aracı çalıştırmadan önce sisteminizi yedeklemeniz tavsiye edilir. Geliştirici, yazılımın kullanımından kaynaklanabilecek herhangi bir sistem arızası, veri kaybı veya aksaklıktan sorumlu tutulamaz.  
> *(USE AT YOUR OWN RISK: The author/maintainer assumes no responsibility or liability for any damages or issues arising from the use of this script.)*

---

## 📖 Proje Hakkında / About The Project

Modern Windows 11 sürümleri (özellikle 23H2 ve 24H2+), kullanıcı talep etmese bile arka planda çalışan çok sayıda yapay zeka modülü ve veri toplayıcıyla birlikte gelir. Bu bileşenler arka planda onlarca `msedgewebview2.exe` örneği ve sistem servisi çalıştırarak belleği (RAM) tüketir.

Bu proje, düşük veya orta segment RAM (8 GB, 16 GB vb.) kapasitesine sahip sistemlerde performansı optimize etmek ve gizliliği artırmak için tasarlanmıştır.

### 📊 Tahmini RAM Kazancı

| Bileşen | Devre Dışı Bırakılmadan Önce | İşlem Sonrası Durum | Ortalama RAM Kazancı |
| :--- | :--- | :--- | :--- |
| **Windows Widgets (WebExperience)** | Arka planda 4-8 adet `msedgewebview2.exe` çalışır | Tamamen durdurulur | **~300 - 800 MB** |
| **Microsoft Copilot & Runtime** | Arka plan önbelleği ve companion servisleri | İlkelerle kapatılır ve kaldırılır | **~150 - 300 MB** |
| **Windows Search (Bing AI Entegrasyonu)** | `SearchHost.exe` internete bağlanıp web önbelleği tutar | Yalnızca yerel dosya araması yapar | **~100 - 250 MB** |
| **Windows Recall & AI Data Analysis** | Arka planda anlamsal ekran analitiği | Servis ve DISM özelliği kaldırılır | **~200 - 500 MB** |
| **AI Servisleri (WSAIFabricSvc, AarSvc)** | Bellekte sürekli çalışan arka plan servisleri | Servisler durdurulur ve devre dışı kalır | **~50 - 150 MB** |
| **TOPLAM TAHMİNİ KAZANÇ** | — | — | **~800 MB - 2.0 GB** |

---

## ✨ Özellikler

- [x] **Tek Tıkla Başlatma:** PowerShell yürütme politikasıyla uğraşmadan `.bat` dosyası ile kolayca çalıştırılabilir.
- [x] **Otomatik Yönetici Yetkisi:** Eksik yetki durumunda otomatik UAC penceresi açar.
- [x] **Güvenlik & Geri Yükleme:** İşlem başlamadan önce otomatik **Sistem Geri Yükleme Noktası (Restore Point)** oluşturur.
- [x] **Geri Döndürülebilirlik (Reversible):** İleride özellikleri tekrar açmak isterseniz `Enable-Windows11-AI.ps1` ile her şey orijinal haline döner.
- [x] **Modüler Menü:** İster tüm optimizasyonları tek seferde yapın, ister sadece belirli bir bileşeni (örn. sadece Widgets veya sadece Copilot) kapatın.

---

## 📁 Dosya Yapısı

```text
├── Calistir_Yonetici_Olarak.bat    # Tek tıkla yönetici olarak çalıştıran başlatıcı
├── Disable-Windows11-AI.ps1        # Ana devre dışı bırakma ve RAM temizleme scripti
├── Geri_Yukle_Yonetici_Olarak.bat  # Geri yükleme başlatıcısı
├── Enable-Windows11-AI.ps1         # Değişiklikleri Windows varsayılanına döndüren script
├── LICENSE                         # MIT Açık Kaynak Lisansı
└── README.md                       # Dokümantasyon
```

---

## 🚀 Hızlı Başlangıç (Nasıl Kullanılır?)

### Yöntem 1: Doğrudan Klasörden Çalıştırma (Önerilen)

1. Bu depoyu indirin (`Code -> Download ZIP` veya `git clone`).
2. Klasör içindeki **`Calistir_Yonetici_Olarak.bat`** dosyasına **sağ tıklayın** ve **"Yönetici olarak çalıştır"** seçeneğini seçin.
3. Açılan komut penceresinde:
   - **`[1]`** tuşuna basarak tam optimizasyonu seçin (**Önerilen**).
   - Ya da menüden kapatmak istediğiniz modülü bağımsız olarak seçin.
4. İşlem tamamlandıktan sonra değişikliklerin tam geçerli olması için bilgisayarınızı **yeniden başlatın**.

### Yöntem 2: PowerShell ile Doğrudan Çalıştırma

Yönetici olarak açılmış bir Windows PowerShell penceresinde:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Disable-Windows11-AI.ps1
```

*(Sessiz ve tüm modülleri otomatik çalıştırmak için: `.\Disable-Windows11-AI.ps1 -All` parametresini ekleyebilirsiniz).*

---

## 🔄 Yapılanları Geri Alma (Nasıl Geri Yüklenir?)

Fikrinizi değiştirirseniz veya bir AI özelliğini tekrar kullanmak isterseniz:
1. Klasördeki **`Geri_Yukle_Yonetici_Olarak.bat`** dosyasına sağ tıklayıp yönetici olarak çalıştırın (veya `Enable-Windows11-AI.ps1` scriptini çalıştırın).
2. Onay verdikten sonra tüm kayıt defteri ve grup politikası ilkeleri varsayılana dönecektir.

---

## 🛡️ Güvenlik & Sistem Kararlılığı

- Bu script sistem dosyalarını (DLL, EXE) silmez ya da bozmaz.
- Değişiklikler; Microsoft'un kurumsal dağıtımlar için sağladığı resmi **Group Policy (Grup İlkeleri)**, **Registry (Kayıt Defteri)** anahtarları ve **DISM isteğe bağlı özellik** yönetimi üzerinden gerçekleştirilir.
- Windows güncellemeleri (Windows Update) çalışmaya devam eder.

---

## 🤝 Katkıda Bulunma (Contributing)

Katkılarınızı memnuniyetle kabul ediyoruz!
1. Bu depoyu Fork'layın (`Fork`).
2. Yeni özellik veya düzeltmeleriniz için bir dal oluşturun (`git checkout -b feature/YeniOzellik`).
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Yeni AI anahtarları eklendi'`).
4. Dalınıza push yapın (`git push origin feature/YeniOzellik`).
5. Bir **Pull Request (PR)** açın.

---

## ⚠️ Sorumluluk Reddi / Disclaimer

- **Tüm sorumluluk kullanandadır.**
- Bu script sistem üzerinde kayıt defteri (Registry), servisler ve paketler düzeyinde derin yapılandırma değişiklikleri uygular.
- Bu aracı kullanırken oluşabilecek veri kaybı, sistem kararsızlığı veya beklenmeyen davranışlardan tamamen kullanıcı sorumludur. Proje yazarı/geliştiricisi hiçbir garanti vermez ve sorumluluk kabul etmez.
- Herhangi bir işlem yapmadan önce önemli verilerinizi yedeklemeniz önemle tavsiye edilir.

---

## ⚖️ Lisans / License

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır. Dilediğiniz gibi kullanabilir, değiştirebilir ve dağıtabilirsiniz.
