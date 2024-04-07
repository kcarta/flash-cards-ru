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
    await flutterTts.setVolume(1.0); // Reset volume to 1.0 in case it was changed (by STT service)
    await flutterTts.speak(text);
    debugPrint("Speaking $text");
  }

  Future<void> _initialize() async {
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);

    // Needed for interop with the Speech-to-Text service
    // Options are pretty extreme, but they work - should investigate further
    await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers],
        IosTextToSpeechAudioMode.voicePrompt);

    await setVoice();
  }

  Future<void> setVoice([Voice voiceChoice = Voice.male]) async {
    Map<String, String> selectedVoice = await _setAvailableVoices(voiceChoice);
    debugPrint("Selected voice: $selectedVoice");
    await flutterTts.setVoice(selectedVoice);
  }

  Future<Map<String, String>> _setAvailableVoices([Voice voiceChoice = Voice.male]) async {
    var voices = await flutterTts.getVoices;

    // If Milena selected, use Milena (Enhanced) if available, otherwise Milena
    // If Yuri selected, use Yuri (Enhanced) if available, otherwise Yuri
    // If neither available, use Milena as default as it seems to be enabled by default
    Map<String, String> selectedVoice = {"name": "Milena", "locale": "ru-RU"};
    for (var voice in voices) {
      if (voiceChoice == Voice.female && voice["name"] == "Milena (Enhanced)") {
        return {"name": "Milena (Enhanced)", "locale": "ru-RU"};
      }
      if (voiceChoice == Voice.male) {
        if (voice["name"] == "Yuri (Enhanced)") {
          return {"name": "Yuri (Enhanced)", "locale": "ru-RU"};
        } else if (voice["name"] == "Yuri") {
          selectedVoice = {"name": "Yuri", "locale": "ru-RU"};
          // Don't stop yet, in case the enhanced version is available
        }
      }
    }
    return selectedVoice;
  }
}

enum Voice { male, female }
