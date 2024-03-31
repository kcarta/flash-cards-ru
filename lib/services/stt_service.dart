import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await _speech.initialize(onError: (errorNotification) => print(errorNotification));
      _initialized = true;
    }
  }

  Future<void> startListening(String russianWord, Function(String, bool) onResult) async {
    await initialize();
    print("Listening started");
    await _speech.listen(
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        localeId: "ru-RU",
        listenOptions: stt.SpeechListenOptions(
          partialResults: false,
        ),
        onResult: (result) async {
          bool isCorrect =
              (result.recognizedWords.toLowerCase() == russianWord.toLowerCase()) && result.confidence > 0.8;
          onResult(result.recognizedWords, isCorrect);
          print("Recognized: ${result.recognizedWords}");
          await stopListening();
        });
  }

  Future<void> stopListening() async {
    await _speech.stop();
    print("Listening stopped");
  }
}
