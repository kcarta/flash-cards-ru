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
    if (widget.onFlip != null) {
      widget.onFlip!();
    }
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
            color: _isFlipped ? CupertinoColors.systemGrey5 : CupertinoColors.activeBlue,
          ),
          child: Stack(
            children: <Widget>[
              WordText(isFlipped: _isFlipped, word: widget.word),
              WordIcon(isFlipped: _isFlipped, icon: widget.word.icon),
              TypeText(isFlipped: _isFlipped, type: widget.word.type),
              if (!_isFlipped) SpeakWordFAB(word: widget.word.russian),
              if (!_isFlipped) TestPronunciationFAB(word: widget.word.russian),
            ],
          ),
        ),
      ),
    );
  }
}

class WordIcon extends StatelessWidget {
  const WordIcon({
    super.key,
    required bool isFlipped,
    required this.icon,
  }) : _isFlipped = isFlipped;

  final bool _isFlipped;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
        child: Icon(icon, color: _isFlipped ? CupertinoColors.black : Colors.yellowAccent, size: 48),
      ),
    );
  }
}

class WordText extends StatelessWidget {
  const WordText({
    super.key,
    required bool isFlipped,
    required this.word,
  }) : _isFlipped = isFlipped;

  final bool _isFlipped;
  final Word word;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
        child: Text(
          _isFlipped ? word.english : word.russian,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: _isFlipped ? CupertinoColors.black : CupertinoColors.white),
        ),
      ),
    );
  }
}

class TypeText extends StatelessWidget {
  const TypeText({
    super.key,
    required bool isFlipped,
    required this.type,
  }) : _isFlipped = isFlipped;

  final bool _isFlipped;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: _isFlipped ? CupertinoColors.black : CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class TestPronunciationFAB extends StatelessWidget {
  const TestPronunciationFAB({
    super.key,
    required this.word,
  });

  final String word;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      bottom: 8,
      child: FloatingActionButton(
        heroTag: "pronunciation_test",
        onPressed: () {
          print("Starting pronunciation test for $word");
        },
        backgroundColor: CupertinoColors.activeBlue,
        child: const Icon(Icons.mic, color: Colors.yellowAccent, size: 36),
      ),
    );
  }
}

class SpeakWordFAB extends StatelessWidget {
  SpeakWordFAB({
    super.key,
    required this.word,
  });

  final String word;
  final FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      bottom: 8,
      child: FloatingActionButton(
        heroTag: "pronunciation",
        onPressed: () async {
          await flutterTts.speak(word);
        },
        backgroundColor: CupertinoColors.activeBlue,
        child: const Icon(CupertinoIcons.volume_up, color: Colors.yellowAccent, size: 36),
      ),
    );
  }
}
