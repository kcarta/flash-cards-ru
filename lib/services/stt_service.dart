import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await _speech.initialize(
          onStatus: (status) => debugPrint("Speech to text: $status"),
          onError: (errorNotification) async {
            await _speech.stop();
            debugPrint("Speech to text: ${errorNotification.errorMsg}");
          });
      debugPrint("Speech to text initialized");
      _initialized = true;
    }
  }

  Future<void> startListening(String russianWord, Function(String, bool) onResult) async {
    await initialize();
    await _speech.listen(
        localeId: "ru-RU",
        listenFor: const Duration(seconds: 7),
        pauseFor: const Duration(seconds: 2),
        listenOptions: stt.SpeechListenOptions(
            //listenMode: stt.ListenMode.search, // TODO check this
            partialResults: false,
            onDevice: true,
            cancelOnError: true),
        onResult: (result) async {
          bool isCorrect =
              (result.recognizedWords.toLowerCase() == russianWord.toLowerCase()) && result.confidence > 0.8;
          onResult(result.recognizedWords, isCorrect);
          debugPrint("Speech to text recognized: ${result.recognizedWords} at ${result.confidence}");
          await stopListening();
        });
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
