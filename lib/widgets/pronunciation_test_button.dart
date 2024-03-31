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
  String _transcribedText = "";
  bool _isCorrect = false;

  void _startListening(STTService sttService, StateSetter setModalState) {
    setModalState(() => _isListening = true); // Set listening state within modal
    sttService.startListening(widget.russianWord, (result, isCorrect) {
      setModalState(() {
        _isCorrect = isCorrect; // Update correctness within modal
        _transcribedText = result; // Update transcribed text within modal
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_isListening)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: CupertinoColors.activeBlue),
                      )),
                    if (_transcribedText.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _transcribedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            _isCorrect ? Icons.check_circle : Icons.cancel,
                            color: _isCorrect ? Colors.green : Colors.red,
                          )
                        ],
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CupertinoColors.activeBlue,
                          ),
                          onPressed: () => _startListening(sttService, setModalState),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Test',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(width: 10),
                              Icon(Icons.mic, color: Colors.white),
                            ],
                          ),
                        ),
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
            _transcribedText = "";
          });
        });
      },
      child: const Icon(Icons.mic, color: Colors.yellowAccent, size: 36),
    );
  }
}
