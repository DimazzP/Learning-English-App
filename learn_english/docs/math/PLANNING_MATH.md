# PLANNING_MATH.md — Perencanaan Platform Matematika Anak SD (Non-Database Client-Side)

Dokumen perencanaan kurikulum, arsitektur antarmuka, dan **peta jalan desain bertahap di Figma** untuk modul **Pembelajaran Matematika Anak Sekolah Dasar (SD)**. 

> **Prinsip Arsitektur Utama (Non-Database & No-Login):**
> Aplikasi ini adalah aplikasi **client-side statis murni (tanpa database server, tanpa autentikasi/login pengguna)**. Seluruh konsep, alur navigasi, dan penyimpanan dirancang **mirip persis dengan modul Bahasa Inggris**:
> 1. Tanpa form login/akun; siswa langsung masuk dan belajar secara instan.
> 2. Seluruh materi dan bank soal dimuat dari berkas lokal JSON di `assets/data/math/`.
> 3. Penyimpanan progres (bintang terkumpul, skor, soal terjawab) disimpan lokal di peramban/perangkat menggunakan `SharedPreferences`.
> 4. Kompatibel penuh dengan fitur **Multi-Pane Split Screen** (bisa split Materi Matematika + Kuis Matematika, atau Bahasa Inggris + Matematika berdampingan).

---

## 1. Visi & Pengalaman Belajar Anak SD
- **Target Pengguna:** Siswa Sekolah Dasar (Kelas 1–6, usia 6–12 tahun).
- **Tujuan:** Menjadikan matematika mudah dan menyenangkan melalui pendekatan visual (*Concrete to Abstract*), ramah anak, dan bebas hambatan teknis (langsung klik dan belajar tanpa registrasi).
- **Filosofi Desain:**
  - *No Barriers:* Tidak ada formulir, password, atau registrasi.
  - *Playful & Friendly:* Tipografi bulat besar, tombol empuk 3D, umpan balik bintang dan suara ceria.
  - *Immediate Reinforcement:* Umpan balik seketika saat menjawab tanpa penalti yang menakutkan.

---

## 2. Struktur Modul & Kemiripan dengan Modul Bahasa Inggris

Struktur fitur matematika disusun selaras dan paralel dengan modul Bahasa Inggris yang sudah berjalan:

### A. Modul 1: Panduan Rumus & Konsep (Math Guide)
*Mirip fitur `Tata Bahasa & 16 Tenses` (GrammarGuideTab).*
- Pengelompokan materi berdasarkan Fase/Kelas:
  - Fase A (Kelas 1–2): Mengenal Angka, Nilai Tempat (Satuan & Puluhan), Penjumlahan & Pengurangan dasar.
  - Fase B (Kelas 3–4): Perkalian, Pembagian, Pecahan Visual Sederhana (1/2, 1/4), Jam/Waktu, dan Keliling.
  - Fase C (Kelas 5–6): Pecahan Campuran, Desimal, Bangun Ruang (Volume Kubus/Balok), dan Pengolahan Data.
- Format kartu materi:
  - Definisi konsep sederhana & ilustrasi visual konkret (gambar buah/balok).
  - Rumus ringkas & cara hitung cepat.
  - Contoh soal langkah-demi-langkah (*step-by-step*).

### B. Modul 2: Kuis & Latihan Berhitung (Math Quiz)
*Mirip fitur `Kuis & Latihan` (QuizTab).*
- Filter tingkat kesulitan berjenjang:
  - *Beginner:* Kelas 1–2 (Operasi hitung konkret bilangan 1–20).
  - *Intermediate:* Kelas 3–4 (Perkalian, pembagian, pecahan dasar).
  - *Expert:* Kelas 5–6 (Operasi campuran, bangun ruang, pecahan desimal).
- Filter topik operasi hitung: Semua, Penjumlahan (+), Pengurangan (-), Perkalian (×), Pembagian (÷).
- Dua sub-mode latihan:
  - Pilihan Ganda (*Multiple Choice*) dengan 4 ubin angka chunky.
  - Input Angka Bebas (*Numpad Visual*) yang dirancang khusus ramah anak.
- Sistem Anti-Repetisi & Progress Bar:
  - Progres `x / total soal (%)` tersimpan di `SharedPreferences` lokal per kategori.
  - Tombol lewati (*Shuffle*) vs tombol periksa jawaban.
  - Kartu perayaan bintang emas saat suatu kategori tuntas.

### C. Modul 3: Kartu Visual & Hafalan Ceria (Math Flashcards)
*Mirip fitur `Hafalan (FlashcardsTab)`.*
- Kartu hafalan interaktif bolak-balik:
  - Flashcard Tabel Perkalian Ceria (1 s.d. 10).
  - Flashcard Pecahan Visual (diagram lingkaran potongan kue).
  - Flashcard Rumus Bangun Datar & Ruang.

### D. Modul 4: Belajar Operasi Khusus (Special Guide)
*Mirip fitur `Belajar To Be (ToBeGuideTab)`.*
- Panduan terfokus untuk konsep yang paling sering membingungkan anak:
  - Konsep "Menyimpan" pada Penjumlahan (*Carrying Over*).
  - Konsep "Meminjam" pada Pengurangan (*Borrowing*).
  - Membaca Jam Analog (Jarum Panjang vs Jarum Pendek).
- Lengkap dengan matriks visual dan analisis kesalahan umum (*Common Mistakes*).

### E. Modul 5: Soal Favorit & Bank Latihan (Favorite Math)
*Mirip fitur `Kata Kerja Favorit (FavoritesTab)`.*
- Menyimpan soal-soal latihan yang ditandai bintang oleh anak agar bisa diulang kembali sewaktu-waktu.

---

## 3. Peta Jalan Desain Bertahap di Figma (*School-Project*)

Selaras dengan arahan pengerjaan bertahap dan arsitektur *non-database*, rencana 6 fase desain disesuaikan:

```
[ Fase 1: Color Palette ] ──> [ Fase 2: UI Kit Dasar ] ──> [ Fase 3: Portal Nav Hub ]
        (SELESAI)                     (SELESAI)                     (SELANJUTNYA)
           │                                                              │
           ▼                                                              ▼
[ Fase 4: Beranda / Math Guide ] ──> [ Fase 5: Kuis & Latihan ] ──> [ Fase 6: Split Multitasking ]
```

### ✅ Fase 1: Color Palette Ceria & Design Tokens Anak (Selesai)
- Dibuat di kanvas Page 1 (`Node ID: 23:2`, 1160 × 1457 px).
- Warna identitas ceria, 4 warna semantik operasi (+, -, ×, ÷), sistem bintang apresiasi, dan warna permukaan lembut ramah mata.
- Koleksi Figma Variable: `Math SD / Colors` (15 tokens).

### ✅ Fase 2: Pustaka Komponen UI Dasar / UI Kit Anak SD (Selesai)
- Dibuat di kanvas Page 1 (`Node ID: 28:2`, 1160 × 1354 px).
- Tombol chunky 3D empuk, kartu nilai tempat angka (76×86px), token operasi visual, evaluasi 3 bintang, dan maskot *Miko si Kelinci Pintar*.

### 🌐 Fase 3: Header Navigasi Portal Terpadu (Top Navigation Hub — Berikutnya)
- **Konsep Non-Database:** Tidak ada avatar login / akun pengguna.
- Header bersih mirip navbar English:
  - Logo & Brand: `Belajar Pintar` (Portal Bahasa Inggris & Matematika SD).
  - Switcher Portal Cepat: Toggle ramah anak antara **[🇬🇧 Bahasa Inggris]** dan **[🔢 Matematika SD]**.
  - Deretan Tab Navigasi Matematika (tanpa login):
    * `Rumus & Konsep`, `Kuis Berhitung`, `Hafalan Visual`, `Operasi Khusus`, `Favorit (⭐)`.
    * Tombol Spesial: **`Split Tampilan`** (Gradien multitasking).
  - Aksi Cepat: Tombol *Acak Soal*, *Dark Mode*, *Pengaturan Suara Audio*.

### 📖 Fase 4: Tampilan Desktop Web — Panduan Konsep & Rumus (Math Guide View)
- Viewport Desktop 1440 × 1080 px.
- Menampilkan modul katalog materi (Fase A, B, C) dengan filter kelas, kartu rumus visual konkret (gambar buah/balok), dan kotak contoh soal.

### 🎮 Fase 5: Tampilan Desktop Web — Kuis & Latihan Berhitung (Math Quiz View)
- Viewport Desktop 1440 × 1080 px.
- Menampilkan mode kuis interaktif: filter tingkat (Beginner/Intermediate/Expert), filter operasi (+, -, ×, ÷), progress bar persentase anti-repetisi, kartu soal berhitung visual bersama maskot Miko, ubin pilihan jawaban, dan tombol aksi.

### 🖥️ Fase 6: Tampilan Desktop Web — Multitasking 2-Pane Split Screen (Math + English / Math Guide + Quiz)
- Viewport Desktop 1440 × 1080 px.
- Menampilkan kecanggihan split screen:
  - Panel Kiri: Panduan Rumus Matematika (atau Materi Bahasa Inggris).
  - Panel Kanan: Kuis Latihan Matematika.
- Menunjukkan fleksibilitas platform multitasking belajar anak.

---

## 4. Standar Teknis Non-Database (Client-Side Storage)

- **SharedPreferences Keys:**
  - `math_answered_question_ids`: Set ID soal matematika yang sudah tuntas dijawab (mencegah repetisi).
  - `math_favorite_question_ids`: Daftar ID soal favorit.
  - `math_stars_count`: Total tabungan bintang emas lokal anak.
  - `is_dark_mode`: Tema tampilan aktif.
- **Data Engine:**
  - Format data JSON identik dengan `GrammarQuestion` (memiliki field: `id`, `level`, `operationType`, `question`, `options`, `correctAnswer`, `explanation`, `visualType`).
- **Audio TTS:**
  - Manual-only playback via `flutter_tts` locale `id-ID` (membacakan teks soal matematika hanya saat tombol speaker ditekan).

---

## 5. Standar Aksesibilitas & Psikologi Anak

1. **Target Sentuh & Klik Besar:** Ukuran tombol minimal 52–56 px dengan jarak aman.
2. **Tipografi Ramah Anak:** Huruf Inter Bold/Medium bulat dengan angka yang tegas.
3. **Umpan Balik Positif:** Selalu membesarkan hati (bintang emas, tanpa hukuman).
4. **Navigasi Simpel:** Semua tab utama terlihat langsung di bar atas tanpa menu tersembunyi.
