# Catatan Kemajuan: Fitur Belajar To Be (PROGRESS_TO_BE_GUIDE)

Dokumen pelacakan status implementasi dan tahapan fitur *Belajar To Be*.

---

## Daftar Tugas & Status

- [x] **Tahap 1: Perencanaan & Arsitektur**
  - Pembuatan dokumen `PLANNING_TO_BE_GUIDE.md` dan diagram Mermaid.
  - Perancangan kurikulum pembelajaran: Teori dasar, matriks to be, komparasi kesalahan umum, dan latihan interaktif.

- [x] **Tahap 2: Pembuatan Model Pembelajaran To Be**
  - Pembuatan file `lib/models/to_be_lesson.dart` berisi dataset terstruktur:
    - Rumus kalimat nominal (Subject + To Be + ANA).
    - Matriks pasangan subjek komprehensif (I, You, We, They, He, She, It) dalam bentuk Present, Past, dan Perfect.
    - Analisis kesalahan umum (*Common Mistakes*) seperti *I am agree*, *She is eat*, *He is like*, dll.
    - 30 butir soal latihan khusus To Be pilihan ganda (ditambah dari 12 soal menjadi 30 soal) beserta penjelasan gramatikal dan arti bahasa Indonesia.

- [x] **Tahap 3: Pembuatan UI Layar Belajar To Be**
  - Pembuatan file `lib/screens/tabs/to_be_guide_tab.dart` dengan fitur:
    - 4 Segment filter: *Pondasi & Rumus*, *Matriks Subjek*, *Kesalahan Umum*, dan *Latihan Soal*.
    - Kartu materi dan contoh kalimat dengan audio TTS manual (*manual-only trigger*).
    - **Mode Latihan Berkesinambungan:** Menghapus tampilan sistem skor akhir kaku (*Skor Anda: X/Y*), diubah menjadi latihan berkelanjutan dengan tombol acak soal persis seperti kuis tenses di QuizTab.

- [x] **Tahap 4: Integrasi ke HomeScreen & Multi-Pane Split Screen**
  - Registrasi fitur `'to_be'` pada `_featureMeta` di `lib/screens/home_screen.dart:77`.
  - Integrasi routing tampilan di `_getFeatureWidget()` pada `lib/screens/home_screen.dart:184`.
  - Integrasi tombol navigasi 'Belajar To Be' pada `_buildTopNavigationBar()` di `lib/screens/home_screen.dart:316`.

- [x] **Tahap 5: Pengujian & Validasi Kualitas**
  - Pembuatan unit test `test/to_be_guide_test.dart` (4 test cases mencakup rules, subject matrix, common mistakes, dan 30 practice questions).
  - Eksekusi `flutter test`: 100% lulus (22 unit test).
  - Eksekusi `flutter analyze`: Bersih (0 errors / 0 warnings).
