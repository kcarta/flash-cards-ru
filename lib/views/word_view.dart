import 'package:flash_cards/widgets/word_forms_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flash_cards/widgets/grammar_rules_sheet.dart';
import 'package:flash_cards/widgets/word_card.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';

class WordView extends StatefulWidget {
  final List<Word> words;
  final WordViewMode mode;

  const WordView({super.key, required this.words, required this.mode});

  @override
  State<WordView> createState() => _WordViewState();
}

class _WordViewState extends State<WordView> {
  int currentIndex = 0;
  bool _showForms = false;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == WordViewMode.shuffled) {
      widget.words.shuffle();
    }
  }

  void toggleCardFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _handleCardSwipe(bool isLearned) {
    DatabaseService dbService = DatabaseService();
    if (currentIndex < widget.words.length) {
      Word currentWord = widget.words[currentIndex];
      dbService.updateWordLearnedStatus(currentWord.id!, isLearned);

      if (widget.mode != WordViewMode.single) {
        setState(() {
          currentIndex++;
        });
      } else {
        // In single word view mode, reset currentIndex to 0 to "reload" the card
        setState(() {
          currentIndex = 0;
          // Update the learned status of the word in the list, so the card UI reflects the change
          widget.words[currentIndex].isLearned = isLearned;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.mode == WordViewMode.single ? "Word Detail" : "Learning Session"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GrammarRulesSheet(key: ValueKey(currentIndex), type: widget.words[currentIndex].type),
            const SizedBox(width: 4),
            if (widget.words[currentIndex].hasForms) // Only show the button if the word has forms
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => setState(() => _showForms = !_showForms),
                child: WordFormsSheet(key: ValueKey(currentIndex), word: widget.words[currentIndex]),
              ),
            if (!widget.words[currentIndex].hasForms)
              const SizedBox(width: 44) // Placeholder to save space if word does not have forms
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: currentIndex < widget.words.length
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * (widget.mode == WordViewMode.single ? 1 : 0.9),
                  height: MediaQuery.of(context).size.height * (widget.mode == WordViewMode.single ? 1 : 0.85),
                  child: Dismissible(
                    resizeDuration: const Duration(milliseconds: 75),
                    key: UniqueKey(), // Ensure the card can be dismissed again
                    direction: widget.mode == WordViewMode.single ? DismissDirection.none : DismissDirection.horizontal,
                    onDismissed: (direction) {
                      bool isLearned = direction == DismissDirection.startToEnd;
                      _handleCardSwipe(isLearned);
                    },
                    background: Container(color: CupertinoColors.systemGreen),
                    secondaryBackground: Container(color: CupertinoColors.systemRed),
                    child: WordCard(
                      word: widget.words[currentIndex],
                      showForms: _showForms,
                      isFlipped: _isFlipped,
                      onFlip: toggleCardFlip,
                    ),
                  ),
                )
              : const Text('No more words to learn!', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

enum WordViewMode { single, shuffled, ordered }
