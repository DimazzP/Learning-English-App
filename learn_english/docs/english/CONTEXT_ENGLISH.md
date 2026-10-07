# CONTEXT_ENGLISH.md — Konteks Teknis & Domain Aplikasi Learn English

Dokumen rujukan tunggal (*Single Source of Truth*) yang merangkum arsitektur teknis, domain pembelajaran bahasa Inggris, struktur data aset, dan integrasi Figma untuk aplikasi **Learn English**.

---

## 1. Spesifikasi Teknis (Tech Stack)

- **Framework & SDK:** Flutter (>= 3.41.0), Dart (>= 3.11.0)
- **Target Platform:** Web (Desktop & Mobile Browser) dan Mobile (Android / iOS)
- **Desain UI:** Material Design 3 dengan palet warna semantik kustom (`AppTheme`)
- **Manajemen State:** Singleton berbasis `ChangeNotifier`
  - `VerbRepository`: Pengelola katalog kata kerja, 16 tenses, bank soal kuis, favorit, dan progres anti-repetisi.
  - `KbbiRepository`: Pemuat dataset kamus KBBI sharded, pencarian baku/nonbaku, dan antonim.
  - `TranslationRepository`: Pemuat kamus dwibahasa sharded (ID-EN & EN-ID) dengan in-memory LRU caching.
  - `TranslationChecker`: Mesin evaluasi kalimat bebas dengan normalisasi kontraksi dan word-level diffing.
  - `TtsService`: Layanan sintesis suara dengan deteksi dinamis locale `en-US` dan `id-ID`.
- **Penyimpanan Lokal:** `shared_preferences` untuk tema tampilan, ID kata kerja favorit, dan riwayat ID soal terjawab.
- **Hosting & CI/CD:** GitHub Pages via GitHub Actions workflow (`.github/workflows/deploy.yml`).

---

## 2. Domain Pembelajaran Bahasa Inggris (Pedagogical Rules)

### A. Hirarki Bentuk Kata Kerja (Verb Forms)
1. **V1 (Base Form / Infinitive):** Digunakan pada Simple Present (subjek jamak/I), modal auxiliary (*can, will, must*), dan *to-infinitive*.
2. **V2 (Simple Past):** Khusus digunakan pada Simple Past Tense dalam kalimat afirmatif (+).
3. **V3 (Past Participle):** Digunakan pada seluruh Perfect Tenses (didahului *have/has/had*) dan konstruksi Passive Voice (*to be + V3*).
4. **V-ing (Present Participle / Gerund):** Digunakan pada seluruh Continuous Tenses (didahului *to be*) atau sebagai kata benda verbal (*Gerund*).

### B. Rumus & Penanda 16 Tenses
- **Present Group:**
  - Simple Present: `S + V1 (s/es)` atau `S + am/is/are + ANA` | Sinyal: *every day, always, usually, often*
  - Present Continuous: `S + am/is/are + V-ing` | Sinyal: *now, right now, at the moment, look!, listen!*
  - Present Perfect: `S + have/has + V3` | Sinyal: *already, just, yet, ever, never, since, for*
  - Present Perfect Continuous: `S + have/has + been + V-ing` | Sinyal: *for hours, all morning, lately*
- **Past Group:**
  - Simple Past: `S + V2` atau `S + was/were + ANA` | Sinyal: *yesterday, last week, two days ago, in 1990*
  - Past Continuous: `S + was/were + V-ing` | Sinyal: *while, when, at 7 PM yesterday*
  - Past Perfect: `S + had + V3` | Sinyal: *before, after, by the time*
  - Past Perfect Continuous: `S + had + been + V-ing` | Sinyal: *before... for 2 hours*
- **Future Group:**
  - Simple Future: `S + will + V1` atau `S + am/is/are + going to + V1` | Sinyal: *tomorrow, next week, soon*
  - Future Continuous: `S + will + be + V-ing` | Sinyal: *at this time tomorrow*
  - Future Perfect: `S + will + have + V3` | Sinyal: *by next year, by tomorrow*
  - Future Perfect Continuous: `S + will + have + been + V-ing` | Sinyal: *by next month... for 5 years*
- **Past Future Group:**
  - Past Future: `S + would + V1`
  - Past Future Continuous: `S + would + be + V-ing`
  - Past Future Perfect: `S + would + have + V3`
  - Past Future Perfect Continuous: `S + would + have + been + V-ing`

### C. Aturan Penggunaan 'To Be'
- Kalimat Nominal: Wajib menggunakan *To Be* jika predikat bukan kata kerja (berupa *Adjective, Noun, Adverb*).
  - Contoh benar: "*I am happy*", "*She is a teacher*", "*They were here*".
  - Kesalahan umum dihindari: "*I am agree*" (Salah, kata *agree* adalah kata kerja. Benar: "*I agree*").
- Kalimat Verbal: Dilarang menyisipkan *am/is/are* sebelum kata kerja dasar.
  - Kesalahan umum dihindari: "*I am work every day*" (Salah. Benar: "*I work every day*").

---

## 3. Struktur Data & Sharding Aset

Lokasi aset berada di `assets/data/`:
- `verbs.json`: Katalog data kata kerja utama (500+ kata beserta arti, bentuk V1-V3-Ving, dan contoh).
- `tenses.json`: Definisi lengkap 16 tenses, rumus afirmatif/negatif/tanya, dan contoh kontekstual.
- `questions/`: Bank soal kuis termodularisasi menurut tingkat kesulitan dan tipe tenses:
  - `beginner_present.json` (110 soal)
  - `intermediate_present.json` (118 soal)
  - `expert_present.json` (100 soal)
  - `beginner_past.json` (50 soal)
  - `intermediate_past.json` (60 soal)
  - `expert_past.json` (40 soal)
  - `beginner_future.json` (12 soal)
  - `intermediate_future.json` (20 soal)
  - `expert_future.json` (5 soal)
  - `beginner_past_future.json` (13 soal)
  - `intermediate_past_future.json` (13 soal)
  - `expert_past_future.json` (12 soal)
  - `manifest.json`: Indeks pusat metadata (`totalQuestions: 553`).
- `dict/`: Kamus dwibahasa terindeks abjad (`en_id/` dan `id_en/`).
- `kbbi/`: Dataset resmi KBBI per abjad (`a.json` s.d. `z.json`), `baku_nonbaku.json`, dan `antonim.json`.

---

## 4. Sistem Pelacakan Anti-Repetisi Kuis

- **Penyimpanan Permanen:**
  Menggunakan `SharedPreferences` dengan kunci `answered_grammar_question_ids` (soal grammar) dan `answered_verb_keys` (kuis verb).
- **Isolasi Progres Per Kategori:**
  Progres tersimpan independen per kombinasi filter (`level` dan `tenseType`). Berpindah filter tidak mereset progres kategori lain.
- **Pembedaan Aksi Shuffle vs Menjawab:**
  - Tombol lewati (*Shuffle*) hanya menandai soal dilewati sementara pada sesi berjalan (`_sessionSkippedGrammarIds`).
  - Soal baru dicatat selesai permanen (`markGrammarQuestionAnswered`) saat pengguna mengirim jawaban kuis.
- **Kartu Penyelesaian (Completion State):**
  Saat seluruh soal pada suatu kategori tuntas dijawab, sistem menampilkan kartu prestasi dengan opsi mengulang latihan (*Reset Progres*) tanpa mengulang soal secara diam-diam.

---

## 5. Invarian Kebijakan Audio TTS

- **Manual Trigger Eksklusif:** Audio Text-to-Speech HANYA diputar saat pengguna menekan tombol speaker / dengarkan secara sadar.
- **Dilarang Auto-Play:** Tidak boleh ada audio otomatis saat memilih opsi jawaban, saat mengirim jawaban, atau saat berganti tab.
- **Deteksi Locale Dinamis:** Otomatis mengubah locale engine `flutter_tts` ke `en-US` untuk teks bahasa Inggris dan `id-ID` untuk arti bahasa Indonesia.

---

## 6. Lingkungan & File Desain Figma

- **File Figma:** `School-Project`
- **File Key:** `UKy60VClmZtOWrQ400DqkX`
- **URL Desain:** `https://www.figma.com/design/UKy60VClmZtOWrQ400DqkX/School-Project`
- **Profile Hermes:** `edul` (terkoneksi langsung dengan token OAuth Figma Desktop)
- **Top-Level Nodes Aktif di Kanvas (Page 1):**
  1. `🎨 Color Palette — Learn English App` (Node ID: `10:2`, 1160 × 1695 px, X=80, Y=80)
  2. `💻 Desktop Web — 2-Pane Split Screen (Grammar + Quiz)` (Node ID: `12:2`, 1440 × 1080 px, X=1320, Y=80)
  3. `💻 Desktop Web — Kamus Verbs (Catalog & Search)` (Node ID: `17:5`, 1440 × 1080 px, X=2840, Y=80)
- **Local Variables Collection:** `Learn English / Colors` (17 tokens semantik)
