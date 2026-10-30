import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isAvailable = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage('en-US');
      await _flutterTts!.setSpeechRate(0.45); // Tốc độ đọc vừa phải cho người học
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      _isAvailable = true;
    } catch (e) {
      debugPrint('TtsService init warning (safe fallback): $e');
      _isAvailable = false;
    } finally {
      _isInitialized = true;
    }
  }

  Future<bool> speak(String text, {bool slow = false}) async {
    return speakRate(text, rateMultiplier: slow ? 0.75 : 1.0);
  }

  Future<bool> speakRate(String text, {double rateMultiplier = 1.0}) async {
    if (!_isInitialized) {
      await init();
    }
    if (!_isAvailable || _flutterTts == null) {
      debugPrint('TTS is not available on this platform/device.');
      return false;
    }

    try {
      await _flutterTts!.stop();
      // Tốc độ chuẩn 0.46 ứng với 1.0x; tỷ lệ tương ứng cho 0.75x và 1.25x
      final targetRate = (0.46 * rateMultiplier).clamp(0.25, 0.85);
      await _flutterTts!.setSpeechRate(targetRate);
      final result = await _flutterTts!.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('TtsService speak error: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
    } catch (e) {
      debugPrint('TtsService stop error: $e');
    }
  }
}
