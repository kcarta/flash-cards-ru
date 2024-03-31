import 'package:flash_cards/services/tts_service.dart';
import 'package:flash_cards/widgets/pronunciation_test_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/word_model.dart';
import 'word_forms.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final bool isFlipped;
  final bool showForms;

  const WordCard({super.key, required this.word, this.isFlipped = false, this.showForms = false});

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
            decoration: BoxDecoration(
              color: _isFlipped ? CupertinoColors.systemGrey5 : CupertinoColors.activeBlue,
            ),
            child: Stack(
              children: [
                // Word Text (Russian or English depending on flip state)
                Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(_isFlipped ? pi : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            _isFlipped ? widget.word.english : widget.word.russian,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _isFlipped ? CupertinoColors.black : CupertinoColors.white,
                            ),
                          ),
                        ),
                        // Word Forms (Center, shown based on showForms flag)
                        if (widget.showForms && !_isFlipped)
                          WordFormsWidget(
                            forms: widget.word.forms,
                            type: widget.word.type,
                          ),
                      ],
                    ),
                  ),
                ),

                // Word Type (Top-Center)
                if (!_isFlipped)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Text(
                      widget.word.type,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        color: CupertinoColors.white,
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

/*
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: setState() called after dispose(): _StatefulBuilderState#072ec(lifecycle state: defunct, not mounted)
This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree (e.g., whose parent widget no longer includes the widget in its build). This error can occur when code calls setState() from a timer or an animation callback.
The preferred solution is to cancel the timer or stop listening to the animation in the dispose() callback. Another solution is to check the "mounted" property of this object before calling setState() to ensure the object is still in the tree.
This error might indicate a memory leak if setState() is being called because another object is retaining a reference to this State object after it has been removed from the tree. To avoid memory leaks, consider breaking the reference to this object during dispose().
#0      State.setState.<anonymous closure> (package:flu<…>
*/