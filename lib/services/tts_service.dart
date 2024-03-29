import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await setupSpeech(); // TODO move this to a one-time init step
    await flutterTts.speak(text);
  }

  Future<void> setupSpeech() async {
    await flutterTts.setLanguage("ru-RU");
    var voices = await flutterTts.getVoices;
    if (voices.any((voice) => voice["name"] == "Yuri (Enhanced)")) {
      await flutterTts.setVoice({"name": "Yuri (Enhanced)", "locale": "ru-RU"});
    } else if (voices.any((voice) => voice["name"] == "Milena (Enhanced)")) {
      await flutterTts.setVoice({"name": "Milena (Enhanced)", "locale": "ru-RU"});
    } else {
      await flutterTts.setVoice({"name": "Milena", "locale": "ru-RU"});
    }
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }
}
