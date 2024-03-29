import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../models/word_model.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final bool isFlipped;
  final VoidCallback? onFlip;

  const WordCard({super.key, required this.word, this.isFlipped = false, this.onFlip});

  @override
  // ignore: library_private_types_in_public_api
  _WordCardState createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _isFlipped = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.isFlipped;
  }

  void _flipCard() {
    if (widget.onFlip != null) {
      widget.onFlip!();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _startPronunciationTest() async {
    print("Starting pronunciation test for ${widget.word.russian}");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Adds perspective
          ..rotateY(_isFlipped ? pi : 0), // Flips the card around the Y axis
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isFlipped ? CupertinoColors.systemGrey5 : CupertinoColors.activeBlue,
          ),
          child: Stack(
            children: <Widget>[
              // Word Text
              Align(
                alignment: Alignment.center,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
                  child: Text(
                    _isFlipped ? widget.word.english : widget.word.russian,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _isFlipped ? CupertinoColors.black : CupertinoColors.white),
                  ),
                ),
              ),
              // Icon
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
                  child:
                      Icon(widget.word.icon, color: _isFlipped ? CupertinoColors.black : Colors.yellowAccent, size: 48),
                ),
              ),
              // Type Text
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
                  child: Text(
                    widget.word.type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      color: _isFlipped ? CupertinoColors.black : CupertinoColors.white,
                    ),
                  ),
                ),
              ),
              // TTS Button (only on non-flipped side)
              if (!_isFlipped)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: FloatingActionButton(
                    onPressed: () async {
                      await flutterTts.speak(widget.word.russian);
                    },
                    backgroundColor: CupertinoColors.activeBlue,
                    child: const Icon(CupertinoIcons.volume_up, color: Colors.yellowAccent, size: 36),
                  ),
                ),
              if (!_isFlipped)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: FloatingActionButton(
                    onPressed: _startPronunciationTest,
                    backgroundColor: CupertinoColors.activeBlue,
                    child: const Icon(Icons.mic, color: Colors.yellowAccent, size: 36),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
