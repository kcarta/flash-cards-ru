import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      debugPrint("Initializing TTS service");
      await _initialize();
      _isInitialized = true;
    }
    await flutterTts.speak(text);
    debugPrint("Speaking $text");
  }

  Future<void> _initialize() async {
    await flutterTts.setLanguage("ru-RU");
    var voices = await flutterTts.getVoices;
    Map<String, String> selectedVoice;
    if (voices.any((voice) => voice["name"] == "Yuri (Enhanced)")) {
      selectedVoice = {"name": "Yuri (Enhanced)", "locale": "ru-RU"};
    } else if (voices.any((voice) => voice["name"] == "Milena (Enhanced)")) {
      selectedVoice = {"name": "Milena (Enhanced)", "locale": "ru-RU"};
    } else {
      selectedVoice = {"name": "Milena", "locale": "ru-RU"};
    }
    debugPrint("Selected voice: $selectedVoice");
    await flutterTts.setVoice(selectedVoice);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);

    // Needed for interop with the Speech-to-Text service
    // Options are pretty extreme, but they work - should investigate further
    await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers],
        IosTextToSpeechAudioMode.voicePrompt);
  }
}
