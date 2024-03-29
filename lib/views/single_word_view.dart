import 'package:flash_cards/widgets/word_card.dart';
import 'package:flutter/cupertino.dart';
import '../models/word_model.dart';

class SingleWordView extends StatelessWidget {
  final Word word;

  const SingleWordView({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Word Detail'), // You can customize this title
      ),
      child: SafeArea(
        child: Center(
          child: WordCard(word: word), // Use your WordCard widget here
        ),
      ),
    );
  }
}
