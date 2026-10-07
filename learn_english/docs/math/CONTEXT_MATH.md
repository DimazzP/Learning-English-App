# CONTEXT_MATH.md — Konteks Teknis, Pedagogi, & Desain Matematika SD (Non-Database)

Dokumen rujukan kontekstual yang merangkum kurikulum matematika Sekolah Dasar (SD), prinsip desain untuk anak-anak, arsitektur teknis integrasi ke Flutter tanpa database server, dan lingkungan kerja Figma.

---

## 1. Arsitektur Teknis Non-Database & No-Login (Mirip Modul English)

Aplikasi dirancang sebagai aplikasi peramban web statis (Flutter Web client-only) dengan prinsip:
1. **Tanpa Database Eksternal / Backend Server:**
   - Tidak ada MySQL, PostgreSQL, Firebase Auth, Supabase, atau REST backend database.
   - Tidak ada fitur registrasi, login, form kata sandi, atau sinkronisasi cloud.
2. **Data Engine Berbasis Bundled JSON Assets:**
   - Seluruh materi, rumus, dan bank latihan disimpan di `assets/data/math/` (`topics.json`, `manifest.json`, shards per fase belajar).
   - Dimuat seketika di memori lokal saat runtime menggunakan `rootBundle.loadString()`.
3. **Penyimpanan Status Lokal (Client-Side Storage):**
   - Menggunakan `SharedPreferences` bawaan web (LocalStorage peramban).
   - Menyimpan riwayat ID soal yang telah dijawab, total bintang emas yang dikumpulkan anak, dan preferensi tema.
4. **State Management Singleton:**
   - Menggunakan `MathRepository.instance` berbasis `ChangeNotifier` (pola identik dengan `VerbRepository` dan `KbbiRepository`).
5. **Kompatibilitas Multi-Pane Split Screen:**
   - Setiap panel di `HomeScreen` dapat memilih fitur matematika secara independen melalui dropdown header pane.

---

## 2. Konteks Pedagogi & Kurikulum Matematika SD

Kurikulum matematika dasar mengacu pada kurikulum nasional / Kurikulum Merdeka dengan penekanan pada literasi numerasi dasar:

### Pembagian Fase Belajar Anak:
- **Fase A (Kelas 1–2 SD, Usia 6–8 Tahun):**
  - Bilangan cacah 1 sampai 100.
  - Penjumlahan dan pengurangan konkret (menggunakan benda nyata dan gambar).
  - Mengenal bangun datar sederhana (lingkaran, segitiga, segi empat).
  - Membandingkan ukuran (panjang-pendek, tinggi-rendah, berat-ringan).
- **Fase B (Kelas 3–4 SD, Usia 8–10 Tahun):**
  - Bilangan cacah hingga ribuan.
  - Perkalian dan pembagian dasar (tabel perkalian 1–10).
  - Pecahan sederhana (1/2, 1/4, 3/4) dengan visualisasi grafis.
  - Keliling dan luas bangun datar sederhana.
  - Membaca waktu pada jam analog dan digital.
- **Fase C (Kelas 5–6 SD, Usia 10–12 Tahun):**
  - Pecahan campuran, desimal, dan persen.
  - Operasi hitung campuran bilangan bulat.
  - Bangun ruang (kubus, balok) dan volume dasar.
  - Pengolahan data sederhana (diagram batang, tabel frekuensi).

---

## 3. Prinsip Desain UI/UX Khusus Anak-Anak (Child-Centric Design)

1. **Palet Warna Hangat & Ceria (Playful Palette):**
   - Menggunakan warna-warna yang membangkitkan rasa ingin tahu dan kegembiraan tanpa menyebabkan kelelahan mata (*visual fatigue*).
   - Menghindari kontras hitam-putih murni yang terlalu kaku seperti formulir korporat.
2. **Ukuran Elemen & Target Interaksi:**
   - Anak-anak memiliki kontrol motorik halus yang masih berkembang, sehingga target klik/sentuh tombol wajib dibuat besar (tinggi minimal 52–56px).
   - Jarak antar tombol (spacing/gap) minimal 16–20px untuk mencegah salah pencet (*fat-finger errors*).
3. **Bahasa Teks yang Ramah & Sederhana:**
   - Kalimat instruksi singkat, padat, dan menggunakan bahasa Indonesia yang akrab bagi anak.
   - Menggunakan ikon visual pendukung untuk setiap teks instruksi.
4. **Gamifikasi Ringan:**
   - Sistem perolehan bintang (1 sampai 3 bintang) di setiap level latihan.
   - Bilah pencapaian (*progress bar*) yang menampilkan progres visual saat soal dijawab.

---

## 4. Lingkungan Desain di Figma

- **File Figma:** `School-Project`
- **File Key:** `UKy60VClmZtOWrQ400DqkX`
- **URL Desain:** `https://www.figma.com/design/UKy60VClmZtOWrQ400DqkX/School-Project`
- **Profile AI:** `edul` (terhubung ke Figma Desktop)
- **Top-Level Nodes Terdaftar di Kanvas (Page 1):**
  1. `🎨 English Color Palette` (Node ID: `10:2`, X: 80, Y: 80)
  2. `💻 Desktop Web: 2-Pane Split Screen (Grammar + Quiz)` (Node ID: `12:2`, X: 1320, Y: 80)
  3. `💻 Desktop Web: Kamus Verbs Catalog` (Node ID: `17:5`, X: 2840, Y: 80)
  4. `🎨 Math Color Palette — Playful Learning Tokens (SD)` (Node ID: `23:2`, X: 80, Y: 1860) — Fase 1 Selesai
  5. `🧩 Math UI Kit — Komponen Dasar Anak SD (Fase 2)` (Node ID: `28:2`, X: 80, Y: 3420) — Fase 2 Selesai
