import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../models/word_model.dart';

class WordCard extends StatefulWidget {
  final Word word;

  // ignore: use_key_in_widget_constructors
  const WordCard({required this.word});

  @override
  // ignore: library_private_types_in_public_api
  _WordCardState createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _isFlipped = false;
  final FlutterTts flutterTts = FlutterTts();

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
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
            color: _isFlipped
                ? CupertinoColors.systemGrey5
                : CupertinoColors.activeBlue,
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
                        color: _isFlipped
                            ? CupertinoColors.black
                            : CupertinoColors.white),
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
                  child: Icon(widget.word.icon,
                      color: _isFlipped
                          ? CupertinoColors.black
                          : Colors.yellowAccent,
                      size: 48),
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
                      color: _isFlipped
                          ? CupertinoColors.black
                          : CupertinoColors.white,
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
                    child: const Icon(CupertinoIcons.volume_up,
                        color: Colors.yellowAccent, size: 36),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
