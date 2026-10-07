# PROGRESS_ENGLISH.md — Catatan Progres & Status Pengembangan Learn English

Dokumen pelacak progres implementasi kode, pembaruan konten pembelajaran, integrasi desain Figma, dan status pengujian pada aplikasi **Learn English**.

---

## 📌 Status Terkini Proyek

- **Versi Rilis:** v1.3.0
- **Total Soal Kuis Grammar:** 553 soal (seluruh shards tervalidasi di `manifest.json`)
- **Total Kosakata Verbs:** 500+ kata kerja (V1, V2, V3, V-ing terdata)
- **Desain Figma:** Terhubung aktif ke file *School-Project* via profile `edul` (3 top-level frame dibuat di Page 1)
- **Status Analisis Statis (`flutter analyze`):** 0 error, 0 warning, 0 issue
- **Status Pengujian Otomatis (`flutter test`):** 23/23 unit & widget tests lulus (100%)
- **Status Deployment Web:** GitHub Pages aktif via workflow GitHub Actions

---

## 🚀 Riwayat Pencapaian & Pembaruan

### 1. Penambahan 150 Soal Kuis Present Tense (Total: 553 Soal)
- Menambahkan 150 soal kuis berkualitas tinggi yang terdistribusi ke seluruh tier:
  - `beginner_present.json`: +50 soal (`b_pres_61` s.d. `b_pres_110`), total **110 soal**.
  - `intermediate_present.json`: +50 soal (`q_pres_73` s.d. `q_pres_122`), total **118 soal**.
  - `expert_present.json`: +50 soal (`exp_pres_47` s.d. `exp_pres_96`), total **100 soal**.
- Memperbarui `manifest.json` dengan total 553 soal.
- Menyelaraskan unit test di `test/verb_repository_test.dart` (ekspektasi 553 soal lolos).
- Karakteristik soal: 4 opsi pilihan terkalibrasi, target kalimat terisi otomatis, dan penjelasan tata bahasa dalam Bahasa Indonesia.

### 2. Integrasi Figma Desktop & Pembuatan Profile Hermes `edul`
- Mendeteksi dan menghubungkan file Figma aktif di Figma Desktop:
  - Nama File: `School-Project`
  - File Key: `UKy60VClmZtOWrQ400DqkX`
- Membuat profile Hermes khusus: `edul` (`hermes profile create edul --clone-from fimoy`) dengan OAuth token Figma Desktop.
- Mengonfigurasi `SOUL.md` profile `edul` sebagai pendamping *design-to-code* terdedikasi untuk proyek `Learning-English-App`.

### 3. Pembuatan Design System & Color Palette di Figma
- Membangun frame kanvas utama di Page 1: `🎨 Color Palette — Learn English App` (Node ID: `10:2`, ukuran 1160 × 1695 px).
- Mendaftarkan collection Figma Local Variables: `Learn English / Colors` (17 tokens):
  - Brand Identity (Primary `#4F46E5`, Primary Dark `#6366F1`, Accent `#0EA5E9`).
  - Grammar Forms (V1 `#2563EB`, V2 `#D97706`, V3 `#059669`, V-ing `#9333EA`).
  - Tenses Categories (Present `#2563EB`, Past `#D97706`, Future `#0D9488`, Past Future `#9333EA`).
  - Surfaces & Neutrals (Light theme & Dark theme).
- Setiap swatch dilengkapi preview kotak warna, kode HEX, dan label fungsi.

### 4. Konversi Tampilan Antarmuka Website ke Figma (Desktop 1440px)
- **Frame 1: `💻 Desktop Web — 2-Pane Split Screen (Grammar + Quiz)` (Node ID: `12:2`):**
  - Ukuran: 1440 × 1080 px di posisi X=1320, Y=80.
  - Mengimplementasikan Top Navbar lengkap (logo, menu navigasi, tombol gradien Split Tampilan, action buttons).
  - Sub-header kontrol multitasking 2 kolom.
  - Kolom Kiri: Tata Bahasa & 16 Tenses (filter chips, kartu rumus Simple Present, Present Continuous, Present Perfect, keterangan waktu).
  - Kolom Kanan: Kuis Interaktif (mode switcher, filter level, progress bar persentase, kartu soal, 4 pilihan opsi jawaban, tombol lewati, dan CTA periksa jawaban).
- **Frame 2: `💻 Desktop Web — Kamus Verbs (Catalog & Search)` (Node ID: `17:5`):**
  - Ukuran: 1440 × 1080 px di posisi X=2840, Y=80.
  - Top Navbar dengan tab *Kamus Verbs* aktif.
  - Hero search bar besar dengan shortcut `⌘K` dan filter chips (Semua, Irregular, Regular, Tingkat).
  - Grid 6 kartu kosakata kata kerja (drink, write, speak, take, study, play) dengan 4 badge bentuk semantik V1-V3-Ving, arti Indonesia, tombol speaker TTS, dan bintang favorit.
  - Pagination bar di bagian bawah.

### 5. Sistem Anti-Repetisi & Bilah Progres Kuis
- Menyimpan progres pengerjaan soal di `SharedPreferences` (`answered_grammar_question_ids`).
- Progres kuis tidak hilang saat berpindah tab atau berganti orientasi layar.
- Mengisolasi progres per filter (level & jenis tenses) secara mandiri.
- Memisahkan aksi *Shuffle* (lewati sesi berjalan) dan submit jawaban (selesai permanen).
- Menampilkan bilah progres persentase, penghitung soal, dan tombol reset.
- Menyediakan *Completion Banner* saat seluruh soal dalam kategori tuntas.

### 6. Fitur Pembelajaran Khusus 'Belajar To Be'
- Modul mandiri untuk memahami aturan dasar *To Be* (am, is, are, was, were, been, being).
- Matriks pemilihan subjek dan dimensi waktu.
- Komparasi kesalahan umum (*Common Mistakes*) nominal vs verbal.
- 30 soal kuis latihan terarah khusus to be.

### 7. Tampilan Awal Default Split Screen & CI/CD Otomatis
- Menetapkan tampilan awal website langsung ke mode **2-Pane Split Screen** berdampingan (Tata Bahasa di kiri, Kuis di kanan).
- Alur deployment otomatis GitHub Actions (`.github/workflows/deploy.yml`) aktif untuk setiap push ke branch `main`.

---

## 🧪 Rangkuman Kualitas & Verifikasi

- **Static Analysis:**
  ```bash
  flutter analyze
  # Result: No issues found! (0 error, 0 warning)
  ```
- **Automated Tests:**
  ```bash
  flutter test
  # Result: 23/23 tests passed (100% lulus)
  ```
- **Git State:** Bersih, ter-push ke `origin/main` (Commit `db7db33`).

---

## 📋 Rencana Kerja Berikutnya (Backlog)

1. **Responsif Tablet & Mobile Breakpoints:**
   - Menambahkan artboard Figma untuk tampilan Tablet (834px) dan Mobile (390px).
2. **Koneksi Desain-ke-Kode (Figma Code Connect):**
   - Menautkan node komponen di Figma ke widget Flutter yang sesuai (`VerbCard`, `TenseCard`, `QuestionCard`).
3. **Ekspansi Soal Tenses Lainnya:**
   - Menambahkan bank soal untuk Past Tense, Future Tense, dan Past Future Tense hingga mencapai total 700+ soal.
4. **Fitur Audio Listening Practice:**
   - Mode kuis tebak kata kerja atau kalimat berdasarkan pelafalan suara TTS.
