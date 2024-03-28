import 'package:flutter/cupertino.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
import '../widgets/word_card.dart';

class LearningView extends StatefulWidget {
  final List<Word> words;

  // ignore: use_key_in_widget_constructors
  const LearningView({required this.words});

  @override
  // ignore: library_private_types_in_public_api
  _LearningViewState createState() => _LearningViewState();
}

class _LearningViewState extends State<LearningView> {
  DatabaseService dbService = DatabaseService();
  List<Word> wordsToLearn = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    wordsToLearn = widget.words
      ..shuffle(); // Shuffle the words for a random learning order.
  }

  void _handleCardSwipe(bool isLearned) {
    setState(() {
      if (currentIndex < wordsToLearn.length) {
        Word currentWord = wordsToLearn[currentIndex];
        dbService.updateWordLearnedStatus(currentWord.id!,
            isLearned); // Update the learning status in the database.
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
      ),
      child: SafeArea(
        child: currentIndex < wordsToLearn.length
            ? Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
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
                    child: WordCard(word: wordsToLearn[currentIndex]),
                  ),
                ),
              )
            : const Center(
                child: Text('No more words to learn!',
                    style: TextStyle(fontSize: 24)),
              ),
      ),
    );
  }
}
