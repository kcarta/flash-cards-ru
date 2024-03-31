import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_cards/services/stt_service.dart';
import 'package:provider/provider.dart';

class PronunciationTestButton extends StatefulWidget {
  final String russianWord;

  const PronunciationTestButton({
    super.key,
    required this.russianWord,
  });

  @override
  State<PronunciationTestButton> createState() => _PronunciationTestButtonState();
}

class _PronunciationTestButtonState extends State<PronunciationTestButton> {
  bool _isListening = false;
  String transcribedText = "";

  void _startListening(STTService sttService, StateSetter setModalState) {
    setModalState(() => _isListening = true); // Set listening state within modal
    sttService.startListening(widget.russianWord, (result, isCorrect) {
      setModalState(() {
        transcribedText = result; // Update transcribed text within modal
        _isListening = false; // Update listening state within modal
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final STTService sttService = Provider.of<STTService>(context, listen: false);
    return FloatingActionButton(
      backgroundColor: CupertinoColors.activeBlue,
      heroTag: "test_pronunciation_${widget.russianWord}",
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext modalContext) {
            return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  children: [
                    const Center(
                      child: Text(
                        "Pronunciation Test",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isListening) const Center(child: CircularProgressIndicator()), // Show spinner when listening
                    if (transcribedText.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            transcribedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          // Some horizontal spacing between the text and icon
                          const SizedBox(width: 10),
                          Icon(
                            transcribedText.toLowerCase() == widget.russianWord.toLowerCase()
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: transcribedText.toLowerCase() == widget.russianWord.toLowerCase()
                                ? Colors.green
                                : Colors.red,
                          )
                        ],
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _startListening(sttService, setModalState),
                        child: const Text('Start'),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ).whenComplete(() async {
          // Ensure listening is stopped and transcribed text is cleared when modal is dismissed
          if (_isListening) {
            await sttService.stopListening();
          }
          setState(() {
            _isListening = false;
            transcribedText = ""; // Clear transcribed text
          });
        });
      },
      child: const Icon(Icons.mic, color: Colors.yellowAccent, size: 36),
    );
  }
}
