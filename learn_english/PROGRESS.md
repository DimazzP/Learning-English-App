# PROGRESS.md — Catatan Progres Pengembangan Aplikasi Learn English

Dokumen ini mencatat riwayat pembaruan, penambahan fitur, perbaikan bug, dan status terkini dari repositori `learn_english`.

---

## 📌 Ringkasan Pembaruan Terkini

### 1. Penambahan Soal Kuis Tata Bahasa (Present & Past Tense)
- **Ekspansi Bank Soal**: Menambahkan **117 soal baru** berkualitas tinggi yang mencakup tingkat *Beginner*, *Intermediate*, dan *Expert* untuk kategori Present Tense dan Past Tense.
- **Total Soal Saat Ini**: Meningkat dari 286 soal menjadi **403 soal** di seluruh shards JSON (`assets/data/questions/`):
  - `beginner_present.json`: +15 soal (total 60 soal)
  - `beginner_past.json`: +22 soal (total 50 soal)
  - `intermediate_present.json`: +15 soal (total 68 soal)
  - `intermediate_past.json`: +23 soal (total 60 soal)
  - `expert_present.json`: +20 soal (total 50 soal)
  - `expert_past.json`: +22 soal (total 40 soal)
  - `manifest.json`: Diperbarui dengan `totalQuestions: 403` dan sinkronisasi jumlah tiap file shard.
- **Standar Soal**: Menggunakan model `GrammarQuestion` dengan 4 pilihan ganda masuk akal, kunci jawaban akurat, target kalimat lengkap, kunci terjemahan, dan penjelasan tata bahasa mendalam dalam Bahasa Indonesia.

### 2. Perbaikan Sistem Pelacakan Anti-Repetisi Kuis
- **Penyimpanan Permanen (SharedPreferences)**:
  - Menyimpan riwayat soal yang sudah dijawab ke dalam `VerbRepository` (`lib/services/verb_repository.dart`) dengan kunci `answered_grammar_question_ids` dan `answered_verb_keys`.
  - Progres pengerjaan soal tidak akan hilang saat pengguna berpindah tab navigasi, mengubah orientasi layar, atau menutup aplikasi.
- **Peniadaan Reset Otomatis Saat Ganti Filter**:
  - Menghapus pemanggilan `_usedGrammarQuestionIds.clear()` dan `_usedVerbIds.clear()` di `quiz_tab.dart` saat pengguna berpindah filter tingkat kesulitan (*level*), jenis tenses (*tenseType*), atau sub-mode. Progres setiap kategori kini tersimpan secara mandiri.
- **Pemisahan Logika Menjawab vs Melewati (Shuffle)**:
  - Tombol acak/lewati (*shuffle*) menggunakan `_sessionSkippedGrammarIds` hanya untuk sesi berjalan agar soal yang baru saja di-*skip* tidak langsung muncul kembali, namun tetap tersedia untuk dijawab di masa mendatang.
  - Soal baru dicatat sebagai "selesai" (`markGrammarQuestionAnswered`) secara permanen ketika pengguna benar-benar **mengirim jawaban**.
- **Menghilangkan Mutasi Diam-diam Saat Soal Habis**:
  - Menghapus baris mutasi `excludeIds.removeAll(...)` di `generateGrammarQuizQuestion`. Ketika seluruh soal dalam suatu kategori telah diselesaikan, fungsi mengembalikan nilai `null` sehingga aplikasi tidak lagi mengulang soal secara sembunyi-sembunyi.

### 3. Peningkatan Antarmuka (UI) Kuis di `quiz_tab.dart`
- **Bilah Progres (Progress Bar)**:
  - Menampilkan jumlah soal yang telah dikerjakan vs total soal dalam kategori aktif:
    `Progres Selesai: [x] / [total] Soal ([%])` disertai `LinearProgressIndicator` Material 3 dan tombol *Reset* cepat.
- **Kartu Penyelesaian Kategori (Completion Banner)**:
  - Saat seluruh soal pada suatu level dan tense telah tuntas, sistem menampilkan kartu ucapan selamat (*Achievement / Completion Card*) dengan ikon piala emas, memberitahukan bahwa seluruh soal telah dikuasai, dan menyediakan tombol:
    - **"Ulangi Latihan Kategori Ini (Reset)"** untuk mengulang latihan kategori tersebut dari awal.
    - Opsi untuk beralih ke level/tense berikutnya.

### 4. Tampilan Awal Default Split Screen (`home_screen.dart`)
- **Tampilan Awal 2 Kolom**: Saat aplikasi atau situs web pertama kali dibuka, tampilan langsung berada pada mode **Split 2 Tampilan Berdampingan** (`2_cols`):
  - **Panel Sisi Kiri**: Panduan Pengetahuan Tata Bahasa & 16 Tenses (`GrammarGuideTab`).
  - **Panel Sisi Kanan**: Kuis & Latihan Soal Interaktif (`QuizTab`).
- Memudahkan pengguna untuk belajar teori tenses di panel kiri sambil langsung menguji pemahaman dengan kuis di panel kanan.
- Tombol reset preset diperbarui ke opsi *"Reset Standar (2 Fitur: Tenses & Kuis)"*.

---

## 🧪 Status Verifikasi & Kualitas Kode

- **Static Analysis (`flutter analyze`)**: 0 error, 0 warning, 0 linter issue (No issues found).
- **Unit & Integration Tests (`flutter test`)**: 23/23 tests passed (100% lulus).
  - Verifikasi total 403 soal grammar.
  - Verifikasi persistensi SharedPreferences untuk `markGrammarQuestionAnswered` dan `markVerbAnswered`.
  - Verifikasi reset progres per kategori dan per mode verb.
  - Verifikasi model KBBI, terjemahan kamus, dan evaluasi grammar check.
