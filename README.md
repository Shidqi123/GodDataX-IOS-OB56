# 🚀 GODDATAX iOS (OB56 EDITION) - PURE NATIVE IPA

Proyek ini telah dikonversi secara total dari berbasis web/HTML/PWA menjadi **Pure Native iOS Application (Swift & SwiftUI)**.

Aplikasi ini menghasilkan file **`.ipa` mandiri (pure IPA)** langsung dari **GitHub Actions CI/CD** tanpa memerlukan domain, server hosting (Vercel/dll), ataupun Mac lokal!

---

## ✨ Fitur & Pembaruan Utama (OB56)

1. **Bahasa Pemrograman Native (SwiftUI & Swift)**
   - Bukan webview / HTML / PWA.
   - Performa 120 FPS ProMotion native, animasi haptik halus, UI bertema Cyberpunk Dark Mode & Glassmorphism.
2. **Pure Standalone `.ipa` via GitHub Actions**
   - Di-compile otomatis di cloud GitHub menggunakan macOS runner + Xcode.
   - File `.ipa` langsung tersedia untuk di-download di tab **Actions / Artifacts** dan **Releases** setiap kali push commit.
   - Tanpa perlu beli domain web atau langganan hosting.
3. **Real-time Free Fire App Icon (Auto-Update)**
   - Menggunakan integrasi Apple iTunes App Store Lookup API (`com.dts.freefireth` & `com.dts.freefiremax`).
   - Setiap kali Garena memperbarui icon Free Fire di App Store, icon di dalam aplikasi GodDataX akan **otomatis terupdate secara realtime**.
4. **Pembaruan OB56**
   - Semua label dan konfigurasi lama (OB53 - OB54) telah diganti menjadi **OB56**.
   - Penyesuaian konfigurasi target engine Free Fire OB56.
5. **Direct Game Launcher**
   - Tombol launch langsung memanggil iOS URL Scheme (`freefire://` & `freefiremax://`).
6. **Sistem Lisensi & HWID Lock**
   - HWID otomatis digenerate dari `UIDevice.current.identifierForVendor` dengan fitur 1-tap copy.
   - Mendukung lisensi offline (seperti `SAIKUTO`, `SAIFREE`, `OB56VIP`, `LIFETIME`, dll).

---

## 📂 Struktur Proyek

```
GodDataX IOS OB56/
├── .github/
│   └── workflows/
│       └── build-ipa.yml          # GitHub Actions compile otomatis ke .ipa
├── GodDataX/
│   ├── App/
│   │   └── GodDataXApp.swift      # Entry point aplikasi
│   ├── Models/
│   │   └── ConfigModel.swift      # Konfigurasi & konstanta OB56
│   ├── Services/
│   │   ├── AuthService.swift      # Sistem verifikasi Key & HWID
│   │   └── FreeFireIconManager.swift # Fetching realtime logo FF dari App Store
│   ├── Views/
│   │   ├── ContentView.swift      # Main container & custom navbar
│   │   ├── LoginView.swift        # Tampilan login futuristik
│   │   ├── MainDashboardView.swift # Launcher game + realtime artwork
│   │   ├── FeaturesView.swift     # Toggle fitur OB56
│   │   ├── StatusProfileView.swift # Profil, HWID & status lisensi
│   │   └── Components/
│   │       ├── DynamicIslandBanner.swift # Banner status Dynamic Island
│   │       └── GlassCard.swift    # Kartu glassmorphic & toggle
│   ├── Assets.xcassets/           # Aset gambar & icon
│   └── Info.plist                 # Skema URL & izin iOS
├── GodDataX.xcodeproj/            # File Xcode project siap build
├── project.yml                    # XcodeGen spec
└── README.md
```

---

## 🛠️ Cara Build `.ipa` di GitHub (100% Gratis)

1. Upload/Push seluruh file proyek ini ke repositori GitHub Anda:
   `https://github.com/Shidqi123/GODDATAX-IOS-PROJECT`
2. Buka tab **Actions** di GitHub repository Anda.
3. GitHub Actions akan secara otomatis menjalankan workflow:
   **"Build GodDataX iOS Pure IPA (OB56)"**
4. Setelah build selesai (sekitar 2–3 menit):
   - Buka menu **Summary** dari run tersebut, scroll ke bagian **Artifacts**.
   - Download file **`GodDataX_OB56_iOS_IPA.zip`** (di dalamnya terdapat file `GodDataX_OB56.ipa`).
   - Atau download langsung dari menu **Releases** repositori Anda.

---

## 📲 Cara Install ke iPhone / iPad

File `.ipa` yang dihasilkan dapat di-install menggunakan sideload tools populer:
- **TrollStore** (Direkomendasikan untuk iOS yang mendukung TrollStore)
- **Scarlet**
- **AltStore / Sidestore**
- **Sideloadly** (PC/Mac)
- **Esign / Gbox / MapleSign**
