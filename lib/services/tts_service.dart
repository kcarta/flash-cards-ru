import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  Future<void> speak(String text) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setVoice({"name": "Milena", "locale": "ru-RU"});
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(text);
  }
}
