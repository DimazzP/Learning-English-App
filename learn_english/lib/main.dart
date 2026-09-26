import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/kbbi_repository.dart';
import 'services/translation_repository.dart';
import 'services/tts_service.dart';
import 'services/verb_repository.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize repositories and TTS
  await VerbRepository.instance.init();
  await KbbiRepository.instance.init();
  await TranslationRepository.instance.init();
  await TtsService.instance.init();

  runApp(const LearnEnglishApp());
}

class LearnEnglishApp extends StatelessWidget {
  const LearnEnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = VerbRepository.instance;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        return MaterialApp(
          title: 'Belajar Verbs',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: repo.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
