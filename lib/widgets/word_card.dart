import 'package:flutter/cupertino.dart';
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
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: _isFlipped
              ? Transform(
                  // Reverse the flip effect for the content
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.word.english,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text("English",
                          style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: CupertinoColors.black)),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(widget.word.russian,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white)),
                    Text(widget.word.type,
                        style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: CupertinoColors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}
