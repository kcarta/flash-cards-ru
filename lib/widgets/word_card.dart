import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pronunciation_test_button.dart';
import '../services/tts_service.dart';
import '../models/word_model.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final bool isFlipped;
  final bool showForms;
  final VoidCallback onFlip;

  const WordCard({super.key, required this.word, this.isFlipped = false, this.showForms = false, required this.onFlip});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.isFlipped;
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    widget.onFlip();
  }

  @override
  Widget build(BuildContext context) {
    final TTSService ttsService = Provider.of<TTSService>(context);
    return GestureDetector(
      onTap: _flipCard,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Adds perspective
          ..rotateY(_isFlipped ? pi : 0), // Flips the card around the Y axis
        child: Card(
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: _isFlipped ? CupertinoColors.systemGrey5 : CupertinoColors.activeBlue,
              //borderRadius: BorderRadius.circular(20)
            ),
            child: Stack(
              children: [
                // Word Text (Russian or English depending on flip state)
                Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          _isFlipped ? widget.word.english : widget.word.russian,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: _isFlipped ? CupertinoColors.black : CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          textAlign: TextAlign.center,
                          _isFlipped ? widget.word.exampleTranslation : widget.word.example,
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: _isFlipped ? CupertinoColors.black : CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Icon showing isLearned status
                if (!_isFlipped)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(widget.word.isLearned ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                        color: Colors.yellowAccent, size: 36),
                  ),

                // Word Type (Top-Center)
                if (!_isFlipped)
                  Positioned(
                    top: 10,
                    left: 18,
                    child: Text(
                      widget.word.type,
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),

                // Icon (Bottom-Center)
                if (!_isFlipped)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Icon(
                      widget.word.icon,
                      color: _isFlipped ? CupertinoColors.black : Colors.yellowAccent,
                      size: 48,
                    ),
                  ),

                // Speak Word FAB (Bottom-Right)
                if (!_isFlipped)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: FloatingActionButton(
                      heroTag: "speak_${widget.word.russian}", // Ensure unique heroTag
                      onPressed: () async {
                        await ttsService.speak(widget.word.russian);
                      },
                      backgroundColor: CupertinoColors.activeBlue,
                      child: const Icon(CupertinoIcons.volume_up, color: Colors.yellowAccent, size: 36),
                    ),
                  ),

                // Test Pronunciation FAB (Bottom-Left)
                if (!_isFlipped)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: PronunciationTestButton(russianWord: widget.word.russian),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
