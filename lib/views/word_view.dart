import 'package:flutter/cupertino.dart';
import 'package:flash_cards/widgets/grammar_rules_overlay.dart';
import 'package:flash_cards/widgets/word_card.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';

class WordView extends StatefulWidget {
  final List<Word> words;
  final bool isFlashcardMode;

  const WordView({super.key, required this.words, this.isFlashcardMode = false});

  @override
  State<WordView> createState() => _WordViewState();
}

class _WordViewState extends State<WordView> {
  int currentIndex = 0;
  bool _showForms = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFlashcardMode) {
      widget.words.shuffle(); // Shuffle only if in flashcard mode
    }
  }

  void _handleCardSwipe(bool isLearned) {
    DatabaseService dbService = DatabaseService();
    if (currentIndex < widget.words.length) {
      Word currentWord = widget.words[currentIndex];
      dbService.updateWordLearnedStatus(currentWord.id!, isLearned);

      if (widget.isFlashcardMode) {
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
        middle: Text(widget.isFlashcardMode ? 'Learning Session' : 'Word Detail'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => setState(() => _showForms = !_showForms),
                child: Icon(CupertinoIcons.text_badge_plus,
                    color: _showForms ? CupertinoColors.activeBlue : CupertinoColors.systemGrey2, size: 28)),
            const SizedBox(width: 10),
            const GrammarRulesOverlay(),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: currentIndex < widget.words.length
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Dismissible(
                    resizeDuration: const Duration(milliseconds: 100),
                    key: UniqueKey(), // Ensure the card can be dismissed again
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      bool isLearned = direction == DismissDirection.startToEnd;
                      _handleCardSwipe(isLearned);
                    },
                    background: Container(color: CupertinoColors.systemGreen),
                    secondaryBackground: Container(color: CupertinoColors.systemRed),
                    child: WordCard(
                      word: widget.words[currentIndex],
                      showForms: _showForms,
                    ),
                  ),
                )
              : const Text('No more words to learn!', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
