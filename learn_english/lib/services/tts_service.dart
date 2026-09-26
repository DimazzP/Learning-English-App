import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  factory TtsService() => instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  TtsService._internal();

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.48); // Natural clear learning pace
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        if (kDebugMode) {
          debugPrint('TTS Error: $msg');
        }
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize TTS: $e');
      }
    }
  }

  String _currentLanguage = 'en-US';

  Future<void> speak(String text, {String language = 'en-US'}) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      if (_isSpeaking) {
        await _flutterTts.stop();
      }
      if (_currentLanguage != language) {
        await _flutterTts.setLanguage(language);
        _currentLanguage = language;
      }
      // Clean speech string: remove slashes or parenthetical guides if any
      final cleanText = text.replaceAll('/', ' or ').replaceAll(RegExp(r'[()]'), '');
      await _flutterTts.speak(cleanText);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TTS speak error: $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TTS stop error: $e');
      }
    }
  }
}
