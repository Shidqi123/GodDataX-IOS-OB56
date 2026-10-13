# PANDUAN INJEKSI TWEAK HOOK GODDATAX KE FREE FIRE iOS (PILIHAN B)

Panduan ini menjelaskan cara menyuntikkan file **`GodDataXTouchHook.dylib`** ke dalam file **`FreeFire.ipa`** (atau Free Fire MAX) agar:
- Walaupun sensitivitas di dalam game disetel 0, layar tetap bisa berputar kencang dan tarikan drag shot ke kepala musuh sangat enteng.
- Konfigurasi Sumbu X & Y diatur langsung dari aplikasi **GodDataX iOS**.

---

## Cara 1: Menggunakan Sideloadly (PC / Laptop Windows & Mac)

1. Siapkan file **`FreeFire.ipa`** (dapat di-download dari decrypt.day, armconverter, atau sumber IPA terpercaya).
2. Buka aplikasi **Sideloadly** di PC Anda.
3. Sambungkan iPhone ke PC menggunakan kabel data.
4. Drag & drop file `FreeFire.ipa` ke kolom utama Sideloadly.
5. Klik menu **"Advanced Options"** di Sideloadly.
6. Pada bagian **"Inject Dylibs / Frameworks"**, klik tombol **`+`** lalu pilih file:
   `GodDataXTouchHook.dylib`
7. Masukkan Apple ID Anda, lalu klik **Start**.
8. Setelah selesai, buka game Free Fire di iPhone Anda. Pada detik ke-3 akan muncul notifikasi:
   **`GDX OB56 HOOK ACTIVE`**.

---

## Cara 2: Menggunakan ESign / Scarlet / GBox (Langsung di iPhone Tanpa PC)

1. Buka aplikasi **ESign** atau **GBox** di iPhone Anda.
2. Import file `FreeFire.ipa` ke dalam ESign/GBox.
3. Import file `GodDataXTouchHook.dylib` ke menu Files ESign.
4. Klik file `FreeFire.ipa` -> Pilih **"Signature / Sign"**.
5. Buka opsi **"More Settings"** -> **"Add Library / Dylib"**.
6. Centang/pilih `GodDataXTouchHook.dylib`.
7. Klik **"Signature"** dan install ke iPhone Anda.

---

## Cara 3: Menggunakan TrollStore (iOS 15.0 - 17.0)

Jika iPhone Anda mendukung TrollStore:
1. Gunakan shortcut atau tool **TrollFools** (tersedia di GitHub).
2. Buka TrollFools -> Pilih aplikasi **Free Fire**.
3. Klik **"Inject"** -> Pilih file `GodDataXTouchHook.dylib`.
4. Buka Free Fire, dan hook langsung bekerja tanpa perlu install ulang IPA.

---

## Cara Menghubungkan Pengaturan Sumbu X & Y
1. Buka aplikasi **GodDataX iOS**.
2. Masuk ke tab **Fitur**.
3. Atur nilai **Sumbu X** (Horizontal Look) dan **Sumbu Y** (Vertical Drag HS).
4. Tekan tombol **"SYNC CONFIG"**.
5. Nilai akan otomatis tersinkron ke Free Fire.
