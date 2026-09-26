/// Model untuk kartu rumus dan panduan to be
class ToBeRule {
  final String title;
  final String description;
  final String formula;
  final String explanation;
  final List<ToBeSentenceExample> examples;

  const ToBeRule({
    required this.title,
    required this.description,
    required this.formula,
    required this.explanation,
    required this.examples,
  });
}

/// Model contoh kalimat to be
class ToBeSentenceExample {
  final String english;
  final String indonesian;
  final String note;
  final String type; // 'positive', 'negative', 'question'

  const ToBeSentenceExample({
    required this.english,
    required this.indonesian,
    required this.note,
    this.type = 'positive',
  });
}

/// Model perbandingan kesalahan umum (common mistakes)
class CommonMistakeItem {
  final String wrong;
  final String correct;
  final String whyWrong;
  final String tip;

  const CommonMistakeItem({
    required this.wrong,
    required this.correct,
    required this.whyWrong,
    required this.tip,
  });
}

/// Model matriks pasangan to be berdasarkan subjek dan waktu
class ToBeSubjectEntry {
  final String subject;
  final String subjectIndo;
  final String present; // am, is, are
  final String past; // was, were
  final String perfect; // been
  final String exampleEn;
  final String exampleId;

  const ToBeSubjectEntry({
    required this.subject,
    required this.subjectIndo,
    required this.present,
    required this.past,
    required this.perfect,
    required this.exampleEn,
    required this.exampleId,
  });
}

/// Model kuis khusus To Be
class ToBeQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String translation;

  const ToBeQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.translation,
  });
}

/// Dataset terstruktur untuk pembelajaran To Be
class ToBeData {
  static const List<ToBeRule> coreRules = [
    ToBeRule(
      title: 'Kapan Harus Menggunakan To Be?',
      description: 'Aturan Kalimat Nominal (Ketika TIDAK ADA kata kerja tindakan/aktivitas)',
      formula: 'Subject + To Be + ANA (Adjective / Noun / Adverb)',
      explanation:
          'To Be berfungsi sebagai "penghubung" antara subjek dan komplemennya (kata sifat, kata benda, atau keterangan tempat). Dalam bahasa Indonesia, to be sering diartikan sebagai "adalah", "berada", atau bahkan tidak diterjemahkan sama sekali.',
      examples: [
        ToBeSentenceExample(
          english: 'She is diligent.',
          indonesian: 'Dia (perempuan) rajin.',
          note: 'Diligent adalah Adjective (kata sifat), bukan kata kerja. Wajib gunakan "is".',
        ),
        ToBeSentenceExample(
          english: 'They are university students.',
          indonesian: 'Mereka adalah mahasiswa.',
          note: 'University students adalah Noun (kata benda). Gunakan "are".',
        ),
        ToBeSentenceExample(
          english: 'We are in the library.',
          indonesian: 'Kami berada di dalam perpustakaan.',
          note: 'In the library adalah Adverb of Place (keterangan tempat). Gunakan "are".',
        ),
      ],
    ),
    ToBeRule(
      title: 'To Be dalam Present & Past Continuous',
      description: 'Menyatakan aksi yang sedang berlangsung',
      formula: 'Subject + To Be + Verb-ing',
      explanation:
          'To be di sini berfungsi sebagai kata kerja bantu (auxiliary verb) yang mendampingi kata kerja utama berakhiran -ing untuk menandakan aktivitas yang sedang terjadi.',
      examples: [
        ToBeSentenceExample(
          english: 'I am studying English right now.',
          indonesian: 'Saya sedang belajar bahasa Inggris sekarang.',
          note: 'am + studying (Verb-ing). Menunjukkan aktivitas sedang berjalan.',
        ),
        ToBeSentenceExample(
          english: 'He was sleeping when I called.',
          indonesian: 'Dia sedang tidur ketika saya menelepon.',
          note: 'was + sleeping (Past Continuous lampau).',
        ),
      ],
    ),
    ToBeRule(
      title: 'To Be dalam Kalimat Pasif (Passive Voice)',
      description: 'Menyatakan subjek dikenai tindakan (di- / ter-)',
      formula: 'Subject + To Be + Verb 3 (Past Participle)',
      explanation:
          'To be yang diikuti langsung oleh kata kerja bentuk ketiga (Verb 3) selalu membentuk makna pasif (dilakukan / dikenai perbuatan).',
      examples: [
        ToBeSentenceExample(
          english: 'The report is submitted every Monday.',
          indonesian: 'Laporan tersebut diserahkan setiap hari Senin.',
          note: 'is + submitted (V3) = diserahkan.',
        ),
        ToBeSentenceExample(
          english: 'The window was broken yesterday.',
          indonesian: 'Jendela itu rusak/dipecahkan kemarin.',
          note: 'was + broken (V3) = dipecahkan / pecah.',
        ),
      ],
    ),
  ];

  static const List<ToBeSubjectEntry> subjectMatrix = [
    ToBeSubjectEntry(
      subject: 'I',
      subjectIndo: 'Saya',
      present: 'am',
      past: 'was',
      perfect: 'have been',
      exampleEn: 'I am ready now. / I was tired yesterday.',
      exampleId: 'Saya siap sekarang. / Saya lelah kemarin.',
    ),
    ToBeSubjectEntry(
      subject: 'You',
      subjectIndo: 'Kamu / Anda / Kalian',
      present: 'are',
      past: 'were',
      perfect: 'have been',
      exampleEn: 'You are very kind. / You were absent last week.',
      exampleId: 'Kamu sangat baik. / Kamu tidak masuk minggu lalu.',
    ),
    ToBeSubjectEntry(
      subject: 'We',
      subjectIndo: 'Kami / Kita',
      present: 'are',
      past: 'were',
      perfect: 'have been',
      exampleEn: 'We are happy here. / We were at the meeting.',
      exampleId: 'Kami senang di sini. / Kami berada di rapat itu.',
    ),
    ToBeSubjectEntry(
      subject: 'They',
      subjectIndo: 'Mereka',
      present: 'are',
      past: 'were',
      perfect: 'have been',
      exampleEn: 'They are my colleagues. / They were in Bali.',
      exampleId: 'Mereka adalah rekan kerja saya. / Mereka berada di Bali.',
    ),
    ToBeSubjectEntry(
      subject: 'He',
      subjectIndo: 'Dia (laki-laki)',
      present: 'is',
      past: 'was',
      perfect: 'has been',
      exampleEn: 'He is an engineer. / He was sick two days ago.',
      exampleId: 'Dia adalah seorang insinyur. / Dia sakit dua hari lalu.',
    ),
    ToBeSubjectEntry(
      subject: 'She',
      subjectIndo: 'Dia (perempuan)',
      present: 'is',
      past: 'was',
      perfect: 'has been',
      exampleEn: 'She is a talented doctor. / She was here earlier.',
      exampleId: 'Dia adalah dokter berbakat. / Dia ada di sini tadi.',
    ),
    ToBeSubjectEntry(
      subject: 'It',
      subjectIndo: 'Benda / Hewan / Situasi',
      present: 'is',
      past: 'was',
      perfect: 'has been',
      exampleEn: 'It is very hot today. / It was difficult to solve.',
      exampleId: 'Hari ini sangat panas. / Hal itu sulit diselesaikan.',
    ),
  ];

  static const List<CommonMistakeItem> commonMistakes = [
    CommonMistakeItem(
      wrong: 'I am agree with you.',
      correct: 'I agree with you.',
      whyWrong:
          '"Agree" adalah kata kerja (verb), BUKAN kata sifat! Jangan tambahkan to be "am" sebelum kata kerja bentuk pertama.',
      tip: 'Ingat: Jika sudah ada kata kerja asli (agree, believe, know, understand, need), JANGAN tambahkan am/is/are.',
    ),
    CommonMistakeItem(
      wrong: 'She is eat an apple.',
      correct: 'She eats an apple. ATAU She is eating an apple.',
      whyWrong:
          'To be tidak boleh langsung bertemu kata kerja Verb 1 dasar ("is eat"). Pilih rutinitas (She eats) atau sedang berlangsung (She is eating).',
      tip: 'Jika pakai to be (is/am/are), kata kerjanya wajib berakhiran -ing jika menyatakan "sedang".',
    ),
    CommonMistakeItem(
      wrong: 'I am student.',
      correct: 'I am a student.',
      whyWrong:
          'Kata benda tunggal yang dapat dihitung (singular countable noun) wajib menggunakan artikel "a" atau "an".',
      tip: 'I am a doctor, She is an architect, He is a teacher.',
    ),
    CommonMistakeItem(
      wrong: 'They was very excited.',
      correct: 'They were very excited.',
      whyWrong:
          'Subjek jamak "They" di masa lampau wajib menggunakan to be "were", bukan "was".',
      tip: 'Was hanya untuk I, He, She, It (tunggal). Were untuk You, We, They (jamak/kamu).',
    ),
    CommonMistakeItem(
      wrong: 'We are not understand this lesson.',
      correct: 'We do not understand this lesson.',
      whyWrong:
          '"Understand" adalah kata kerja. Kalimat negatif untuk kata kerja present menggunakan "do not / does not", bukan "are not".',
      tip: 'Gunakan "are not" hanya jika diikuti kata sifat, benda, keterangan, atau Verb-ing.',
    ),
    CommonMistakeItem(
      wrong: 'He is like coffee.',
      correct: 'He likes coffee.',
      whyWrong:
          '"Like" di sini bermakna "menyukai" (kata kerja). Subjek "He" langsung bertemu Verb 1+s/es.',
      tip: 'Kecuali bermakna "mirip" (He is like his father), kata menyukai adalah "He likes".',
    ),
  ];

  static const List<ToBeQuizQuestion> practiceQuestions = [
    ToBeQuizQuestion(
      id: 'tb_01',
      question: 'She _______ a passionate music teacher at our school.',
      options: ['is', 'are', 'am', 'be'],
      correctAnswer: 'is',
      explanation: 'Subjek tunggal "She" pada kalimat nominal waktu sekarang (Present) menggunakan to be "is".',
      translation: 'Dia adalah seorang guru musik yang bersemangat di sekolah kami.',
    ),
    ToBeQuizQuestion(
      id: 'tb_02',
      question: 'I _______ agree with your opinion on this matter.',
      options: ['totally', 'am totally', 'is totally', 'are totally'],
      correctAnswer: 'totally',
      explanation: '"Agree" adalah kata kerja (verb). Jangan gunakan to be "am" sebelum kata kerja Verb 1!',
      translation: 'Saya sangat setuju dengan pendapatmu mengenai masalah ini.',
    ),
    ToBeQuizQuestion(
      id: 'tb_03',
      question: 'They _______ in Bali during the holiday last week.',
      options: ['were', 'was', 'are', 'is'],
      correctAnswer: 'were',
      explanation: 'Keterangan waktu "last week" menunjukkan masa lampau. Subjek "They" berpasangan dengan "were".',
      translation: 'Mereka berada di Bali selama liburan minggu lalu.',
    ),
    ToBeQuizQuestion(
      id: 'tb_04',
      question: 'Look at the sky! It _______ getting dark.',
      options: ['is', 'are', 'was', 'am'],
      correctAnswer: 'is',
      explanation: 'Subjek "It" dalam Present Continuous (sedang berlangsung) menggunakan "is" + getting.',
      translation: 'Lihatlah ke langit! Hari sedang mulai gelap.',
    ),
    ToBeQuizQuestion(
      id: 'tb_05',
      question: 'We _______ very exhausted after the long hiking trip yesterday.',
      options: ['were', 'was', 'are', 'have'],
      correctAnswer: 'were',
      explanation: 'Subjek jamak "We" pada kalimat lampau (yesterday) berpasangan dengan to be "were".',
      translation: 'Kami sangat kelelahan setelah perjalanan mendaki yang panjang kemarin.',
    ),
    ToBeQuizQuestion(
      id: 'tb_06',
      question: 'I _______ not understand the instructions on the board.',
      options: ['do', 'am', 'is', 'are'],
      correctAnswer: 'do',
      explanation: '"Understand" adalah kata kerja dasar, maka bentuk negatifnya menggunakan "do not", bukan "am not".',
      translation: 'Saya tidak memahami petunjuk di papan tulis.',
    ),
    ToBeQuizQuestion(
      id: 'tb_07',
      question: 'The new hospital _______ built in 2021.',
      options: ['was', 'were', 'is', 'are'],
      correctAnswer: 'was',
      explanation: 'Kalimat pasif lampau (in 2021) untuk subjek tunggal "The new hospital": was + Verb 3 (built).',
      translation: 'Rumah sakit baru tersebut dibangun pada tahun 2021.',
    ),
    ToBeQuizQuestion(
      id: 'tb_08',
      question: '_______ you ready to give the presentation today?',
      options: ['Are', 'Is', 'Am', 'Do'],
      correctAnswer: 'Are',
      explanation: '"Ready" adalah kata sifat (adjective). Pertanyaan nominal untuk subjek "you" diawali to be "Are".',
      translation: 'Apakah kamu siap untuk membawakan presentasi hari ini?',
    ),
    ToBeQuizQuestion(
      id: 'tb_09',
      question: 'He has _______ living in London for five years.',
      options: ['been', 'being', 'be', 'was'],
      correctAnswer: 'been',
      explanation: 'Bentuk Present Perfect Continuous menggunakan rumus: has/have + been + Verb-ing (living).',
      translation: 'Dia telah tinggal di London selama lima tahun.',
    ),
    ToBeQuizQuestion(
      id: 'tb_10',
      question: 'My brothers _______ enthusiastic football fans.',
      options: ['are', 'is', 'was', 'am'],
      correctAnswer: 'are',
      explanation: 'Subjek jamak "My brothers" dalam kalimat fakta saat ini menggunakan to be "are".',
      translation: 'Saudara-saudara laki-laki saya adalah penggemar sepak bola yang antusias.',
    ),
    ToBeQuizQuestion(
      id: 'tb_11',
      question: 'The delicious cake _______ eaten by the guests in minutes.',
      options: ['was', 'were', 'is', 'are'],
      correctAnswer: 'was',
      explanation: 'Kalimat pasif lampau untuk subjek tunggal "The delicious cake": was + eaten.',
      translation: 'Kue yang lezat itu dimakan oleh para tamu dalam beberapa menit.',
    ),
    ToBeQuizQuestion(
      id: 'tb_12',
      question: 'Why _______ she absent from school yesterday?',
      options: ['was', 'were', 'did', 'is'],
      correctAnswer: 'was',
      explanation: '"Absent" adalah kata sifat (bukan kata kerja). Pertanyaan lampau subjek "she" memerlukan to be "was".',
      translation: 'Mengapa dia tidak masuk sekolah kemarin?',
    ),
    ToBeQuizQuestion(
      id: 'tb_13',
      question: 'Listen! Somebody _______ knocking at the front door.',
      options: ['is', 'are', 'was', 'were'],
      correctAnswer: 'is',
      explanation: 'Subjek tak tentu "Somebody" diperlakukan sebagai singular (tunggal), maka menggunakan to be "is".',
      translation: 'Dengarkan! Seseorang sedang mengetuk pintu depan.',
    ),
    ToBeQuizQuestion(
      id: 'tb_14',
      question: 'The children _______ very cheerful at the playground yesterday afternoon.',
      options: ['were', 'was', 'are', 'is'],
      correctAnswer: 'were',
      explanation: '"The children" adalah bentuk jamak dari "child". Kalimat nominal lampau (yesterday) menggunakan to be "were".',
      translation: 'Anak-anak sangat ceria di taman bermain kemarin sore.',
    ),
    ToBeQuizQuestion(
      id: 'tb_15',
      question: 'I _______ believe that hard work always pays off.',
      options: ['truly', 'am truly', 'is truly', 'are truly'],
      correctAnswer: 'truly',
      explanation: '"Believe" adalah kata kerja mental (stative verb). Jangan pernah menambahkan to be "am" sebelum kata kerja bentuk pertama.',
      translation: 'Saya sungguh percaya bahwa kerja keras selalu membuahkan hasil.',
    ),
    ToBeQuizQuestion(
      id: 'tb_16',
      question: 'Neither the manager nor the employees _______ satisfied with the new policy.',
      options: ['are', 'is', 'am', 'be'],
      correctAnswer: 'are',
      explanation: 'Pada struktur "Neither ... nor ...", kata kerja to be mengikuti subjek terdekat ("the employees" yang jamak) -> "are".',
      translation: 'Baik manajer maupun para karyawan tidak merasa puas dengan kebijakan baru itu.',
    ),
    ToBeQuizQuestion(
      id: 'tb_17',
      question: 'Where _______ you born?',
      options: ['were', 'was', 'are', 'did'],
      correctAnswer: 'were',
      explanation: 'Frasa kelahiran selalu menggunakan bentuk pasif lampau: "were you born" (karena subjeknya adalah "you").',
      translation: 'Di mana kamu dilahirkan?',
    ),
    ToBeQuizQuestion(
      id: 'tb_18',
      question: 'He _______ not interested in classical literature.',
      options: ['is', 'does', 'has', 'am'],
      correctAnswer: 'is',
      explanation: '"Interested" adalah kata sifat (adjective). Kalimat nominal negatif untuk subjek "He" adalah "is not".',
      translation: 'Dia tidak tertarik pada sastra klasik.',
    ),
    ToBeQuizQuestion(
      id: 'tb_19',
      question: 'The confidential documents _______ stolen from the safe last night.',
      options: ['were', 'was', 'are', 'is'],
      correctAnswer: 'were',
      explanation: 'Subjek jamak "documents" dalam kalimat pasif lampau (last night) menggunakan to be "were" + stolen (V3).',
      translation: 'Dokumen-dokumen rahasia itu dicuri dari brankas tadi malam.',
    ),
    ToBeQuizQuestion(
      id: 'tb_20',
      question: 'Everybody in this room _______ responsible for keeping it clean.',
      options: ['is', 'are', 'were', 'be'],
      correctAnswer: 'is',
      explanation: 'Kata ganti "Everybody", "Everyone", "Nobody" selalu berstatus tunggal (singular), sehingga memakai to be "is".',
      translation: 'Setiap orang di ruangan ini bertanggung jawab untuk menjaga kebersihannya.',
    ),
    ToBeQuizQuestion(
      id: 'tb_21',
      question: 'How long _______ you been waiting for the bus?',
      options: ['have', 'has', 'are', 'were'],
      correctAnswer: 'have',
      explanation: 'Pola Present Perfect Continuous untuk subjek "you": How long + have + you + been waiting?',
      translation: 'Sudah berapa lama kamu menunggu bus itu?',
    ),
    ToBeQuizQuestion(
      id: 'tb_22',
      question: 'The old bridge is _______ repaired by the workers this week.',
      options: ['being', 'been', 'be', 'was'],
      correctAnswer: 'being',
      explanation: 'Kalimat pasif yang sedang berlangsung (Present Continuous Passive) menggunakan pola: is/are + being + Verb 3 (repaired).',
      translation: 'Jembatan tua itu sedang diperbaiki oleh para pekerja minggu ini.',
    ),
    ToBeQuizQuestion(
      id: 'tb_23',
      question: '_______ your father at home right now?',
      options: ['Is', 'Does', 'Are', 'Was'],
      correctAnswer: 'Is',
      explanation: '"At home" adalah keterangan tempat (Adverb of Place). Kalimat tanya nominal subjek tunggal "your father" diawali "Is".',
      translation: 'Apakah ayahmu berada di rumah sekarang?',
    ),
    ToBeQuizQuestion(
      id: 'tb_24',
      question: 'I _______ so thirsty after playing basketball for two hours.',
      options: ['was', 'were', 'am', 'did'],
      correctAnswer: 'was',
      explanation: 'Menyatakan kondisi lampau subjek "I" dengan kata sifat "thirsty" (haus): I was so thirsty.',
      translation: 'Saya merasa sangat haus setelah bermain bola basket selama dua jam.',
    ),
    ToBeQuizQuestion(
      id: 'tb_25',
      question: 'My mother _______ very proud of my graduation honors.',
      options: ['is', 'are', 'am', 'be'],
      correctAnswer: 'is',
      explanation: '"Proud" adalah kata sifat. Subjek tunggal orang ketiga "My mother" memerlukan to be "is".',
      translation: 'Ibu saya sangat bangga dengan predikat kelulusan saya.',
    ),
    ToBeQuizQuestion(
      id: 'tb_26',
      question: 'They _______ know how to fix the broken printer.',
      options: ['do not', 'are not', 'were not', 'is not'],
      correctAnswer: 'do not',
      explanation: '"Know" adalah kata kerja dasar. Kalimat negatif verbal membutuhkan kata bantu "do not", bukan to be "are not".',
      translation: 'Mereka tidak tahu cara memperbaiki printer yang rusak itu.',
    ),
    ToBeQuizQuestion(
      id: 'tb_27',
      question: 'This delicious soup _______ cooked by my grandmother yesterday.',
      options: ['was', 'were', 'is', 'has'],
      correctAnswer: 'was',
      explanation: 'Bentuk pasif lampau (yesterday) untuk subjek tunggal "This delicious soup": was + cooked (V3).',
      translation: 'Sup yang lezat ini dimasak oleh nenek saya kemarin.',
    ),
    ToBeQuizQuestion(
      id: 'tb_28',
      question: 'Both Denny and Sarah _______ absent from the meeting this morning.',
      options: ['were', 'was', 'are', 'is'],
      correctAnswer: 'were',
      explanation: '"Both Denny and Sarah" membentuk subjek jamak dua orang di masa lampau (this morning), sehingga memerlukan "were".',
      translation: 'Baik Denny maupun Sarah tidak hadir dalam pertemuan tadi pagi.',
    ),
    ToBeQuizQuestion(
      id: 'tb_29',
      question: 'The water in the swimming pool _______ very cold this morning.',
      options: ['was', 'were', 'are', 'did'],
      correctAnswer: 'was',
      explanation: '"The water" adalah uncountable noun (benda tidak dapat dihitung yang bersifat tunggal) di masa lampau: to be "was".',
      translation: 'Air di kolam renang itu sangat dingin tadi pagi.',
    ),
    ToBeQuizQuestion(
      id: 'tb_30',
      question: 'You will _______ able to master English with consistent practice.',
      options: ['be', 'been', 'being', 'are'],
      correctAnswer: 'be',
      explanation: 'Setelah modal verb seperti "will", "can", "must", to be harus kembali ke bentuk dasar infinitive: "be" (will be able).',
      translation: 'Kamu akan mampu menguasai bahasa Inggris dengan latihan yang konsisten.',
    ),
  ];
}
