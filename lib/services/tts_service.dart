import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  Future<void> speak(String text) async {
    FlutterTts flutterTts = FlutterTts();

    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }
}
