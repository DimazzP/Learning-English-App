# PLANNING_ENGLISH.md — Roadmap & Arsitektur Website Learn English

Dokumen perencanaan arsitektur, kurikulum pembelajaran, dan peta jalan pengembangan aplikasi **Learn English** yang difokuskan sebagai platform pembelajaran berbasis Web responsif (Desktop & Mobile) terintegrasi dengan Figma Design System.

---

## 1. Visi & Tujuan Platform
Membangun platform belajar bahasa Inggris interaktif yang komprehensif, menggabungkan:
- Penguasaan kosakata kata kerja (500+ Regular & Irregular Verbs lengkap V1, V2, V3, V-ing).
- Pemahaman sistematis 16 Tenses bahasa Inggris dengan rumus dan penanda waktu.
- Pembelajaran mendalam konsep dasar seperti *To Be* (nominal vs verbal).
- Latihan kuis adaptif (553+ soal) dengan anti-repetisi dan evaluasi terjemahan kalimat bebas.
- Kamus dwibahasa (Inggris-Indonesia) dan integrasi KBBI resmi.
- Pengalaman desktop multitasking melalui fitur *Multi-Pane Split Screen*.
- Keselarasan desain visual antara implementasi kode Flutter dan kanvas Figma (*School-Project*).

---

## 2. Struktur Modul & Fitur Utama

### A. Kamus Verbs (Katalog & Multi-Form Search)
- Katalog 500+ kata kerja dengan klasifikasi Irregular dan Regular.
- Pembedaan semantik 4 bentuk kata kerja:
  - V1 (Base Form / Infinitive)
  - V2 (Simple Past)
  - V3 (Past Participle)
  - V-ing (Present Participle / Gerund)
- Pencarian instan lintas bentuk (mencari "drank" akan menemukan "drink").
- Bookmark kata favorit tersimpan di penyimpanan lokal (*SharedPreferences*).
- Pelafalan audio Text-to-Speech (TTS) manual per kata.

### B. Tata Bahasa & 16 Tenses
- Modul lengkap 16 tenses yang dikelompokkan ke dalam 4 dimensi waktu:
  - Present Tenses (Simple, Continuous, Perfect, Perfect Continuous).
  - Past Tenses (Simple, Continuous, Perfect, Perfect Continuous).
  - Future Tenses (Simple, Continuous, Perfect, Perfect Continuous).
  - Past Future Tenses (Simple, Continuous, Perfect, Perfect Continuous).
- Struktur materi kartu:
  - Rumus standar afirmatif (+), negatif (-), dan interogatif (?).
  - Penanda waktu khas (*time markers*).
  - Contoh kalimat kontekstual dengan penyorotan bentuk kata kerja.

### C. Belajar To Be (Mastering 'To Be')
- Pondasi kalimat nominal vs verbal.
- Aturan formula ANA (*Adjective, Noun, Adverb*).
- Matriks pemilihan to be sesuai subjek dan dimensi waktu (*am, is, are, was, were, been, being*).
- Analisis kesalahan umum (*Common Mistakes*) beserta koreksi dan penjelasannya.
- Kuis interaktif khusus to be (30 soal terarah).

### D. Mesin Kuis & Latihan Interaktif
- 553+ bank soal berstandar tinggi yang terdistribusi ke dalam shards JSON modular.
- Filter multi-level: *Beginner*, *Intermediate*, dan *Expert*.
- Dua mode latihan:
  - Pilihan Ganda (*Multiple Choice*) dengan 4 opsi masuk akal.
  - Latihan Terjemahan Kalimat (*Free-form Sentence Translation*) dengan token-level diffing.
- Sistem pelacakan progres anti-repetisi:
  - Persistensi soal terjawab per kategori di *SharedPreferences*.
  - Progres persentase dan kartu selebrasi penyelesaian materi.
  - Tombol reset progres independen per level/tense.

### E. Kamus Universal & KBBI
- Kamus dwibahasa (ID-EN dan EN-ID) tersharding alfabetis dengan caching in-memory.
- Basis data resmi KBBI dengan deteksi kata baku/nonbaku dan relasi antonim.

### F. Multi-Pane Split Screen (Desktop Web Experience)
- Mode multitasking berdampingan (default: 2 kolom berdampingan).
  - Kolom Kiri: Teori Tata Bahasa & 16 Tenses.
  - Kolom Kanan: Kuis & Latihan Interaktif.
- Mendukung 2, 3, atau 4 panel simultan dengan header kontrol mandiri (maximize, ganti fitur).

---

## 3. Integrasi Figma Design-to-Code

### Kanvas Desain: File `School-Project`
- **Tautan Figma:** `https://www.figma.com/design/UKy60VClmZtOWrQ400DqkX/School-Project`
- **File Key:** `UKy60VClmZtOWrQ400DqkX`
- **Profile AI:** `edul` (terhubung langsung via Figma MCP)

### Komponen Desain yang Telah Disinkronkan:
1. **Design System & Color Tokens (Node ID: 10:2):**
   - Collection variables: `Learn English / Colors` (17 tokens).
   - Brand tokens: Primary (`#4F46E5`), Primary Dark (`#6366F1`), Accent (`#0EA5E9`).
   - Semantic grammar tokens: V1 (`#2563EB`), V2 (`#D97706`), V3 (`#059669`), V-ing (`#9333EA`).
   - Surfaces & neutrals: Light theme (`#F8FAFC`, `#FFFFFF`, `#E2E8F0`) dan Dark theme (`#0F172A`, `#1E293B`, `#334155`).
2. **Desktop Web — 2-Pane Split Screen (Node ID: 12:2):**
   - Viewport 1440 × 1080 px dengan Auto Layout.
   - Top navbar, multitasking toolbar, kolom tata bahasa, dan kolom kuis interaktif.
3. **Desktop Web — Kamus Verbs Catalog (Node ID: 17:5):**
   - Viewport 1440 × 1080 px dengan Auto Layout.
   - Hero search bar, filter chips, dan grid 6 kartu kata kerja dengan 4 badge semantik.

---

## 4. Rencana Tahapan Pengembangan (Milestones)

### Tahap 1: Penguatan Konten & Bank Soal (Selesai)
- Ekspansi bank soal Present Tense sebanyak 150 soal (total 553 soal).
- Sinkronisasi `manifest.json` dan unit test di `test/verb_repository_test.dart`.
- Persistensi progres kuis anti-repetisi.

### Tahap 2: Standardisasi Desain Website & Figma (Selesai)
- Pembentukan profile Hermes `edul`.
- Pembuatan Color Palette & Token Variables di Figma Desktop.
- Konversi antarmuka website desktop (Split View & Kamus Catalog) ke kanvas Figma.

### Tahap 3: Penyempurnaan Tampilan Web & Responsif (Sedang Berjalan)
- Penyesuaian layout breakpoint untuk tablet (768px - 1024px) dan desktop lebar (>1280px).
- Optimalisasi hotkey navigasi (misal: shortcut `⌘K` untuk pencarian global, spasi/enter untuk kuis).
- Pengujian performa rendering pada Flutter Web release build.

### Tahap 4: Ekspansi Fitur Lanjutan (Mendatang)
- Penambahan mode kuis audio pelafalan (Listening Comprehension).
- Ekspor & impor riwayat progres belajar pengguna.
- Sinkronisasi komponen Figma dua arah (*Code Connect*).

---

## 5. Invarian Teknis & Standar Kualitas

- **Audio Playback:** Wajib dipicu secara manual oleh pengguna (tombol speaker eksplisit). Dilarang auto-play audio saat menjawab atau berpindah halaman.
- **Dataset Sharding:** Data dictionary dan bank soal dimuat secara modular per shard huruf atau kategori agar penggunaan memori web tetap ringan.
- **Kualitas Kode:** Wajib lolos 100% `flutter analyze` (0 issue/warning) dan `flutter test` sebelum perubahan dirilis.
- **CI/CD:** Setiap push ke branch `main` otomatis di-build dan di-deploy ke GitHub Pages via GitHub Actions.
