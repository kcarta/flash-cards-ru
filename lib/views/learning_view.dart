import 'package:flutter/cupertino.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
import '../widgets/word_card.dart';

class LearningView extends StatefulWidget {
  final List<Word> words;

  const LearningView({super.key, required this.words});

  @override
  State<LearningView> createState() => _LearningViewState();
}

class _LearningViewState extends State<LearningView> {
  DatabaseService dbService = DatabaseService();
  List<Word> wordsToLearn = [];
  int currentIndex = 0;
  bool _showForms = false;

  @override
  void initState() {
    super.initState();
    wordsToLearn = widget.words..shuffle(); // Shuffle the words for a random learning order.
  }

  void _handleCardSwipe(bool isLearned) {
    setState(() {
      if (currentIndex < wordsToLearn.length) {
        Word currentWord = wordsToLearn[currentIndex];
        dbService.updateWordLearnedStatus(currentWord.id!, isLearned); // Update the learning status in the database.
        currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          middle: const Text('Learning Session'),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.text_badge_plus,
                  color: _showForms ? CupertinoColors.activeBlue : CupertinoColors.systemGrey2),
              CupertinoSwitch(
                activeColor: CupertinoColors.activeBlue,
                value: _showForms,
                onChanged: (bool value) {
                  setState(() {
                    _showForms = value;
                  });
                },
              ),
            ],
          )),
      child: SafeArea(
        child: currentIndex < wordsToLearn.length
            ? Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Dismissible(
                    resizeDuration: const Duration(milliseconds: 100),
                    key: UniqueKey(), // Ensures each card can be dismissed
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      // Handle swipe direction and card dismissal
                      bool isLearned = direction == DismissDirection.startToEnd;
                      _handleCardSwipe(isLearned);
                    },
                    background: Container(
                      color: CupertinoColors.systemGreen,
                    ),
                    secondaryBackground: Container(
                      color: CupertinoColors.systemRed,
                    ),
                    child: WordCard(
                      word: wordsToLearn[currentIndex],
                      showForms: _showForms,
                    ),
                  ),
                ),
              )
            : const Center(
                child: Text('No more words to learn!', style: TextStyle(fontSize: 24)),
              ),
      ),
    );
  }
}
