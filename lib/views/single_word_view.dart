import 'package:flash_cards/widgets/grammar_rules_overlay.dart';
import 'package:flash_cards/widgets/word_card.dart';
import 'package:flutter/cupertino.dart';
import '../models/word_model.dart';

class SingleWordView extends StatefulWidget {
  final Word word;

  const SingleWordView({super.key, required this.word});

  @override
  State<SingleWordView> createState() => _SingleWordViewState();
}

class _SingleWordViewState extends State<SingleWordView> {
  bool _showForms = false;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back, color: CupertinoColors.activeBlue),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 16),
              const GrammarRulesOverlay(),
            ],
          ),
          middle: const Text('Word Detail'),
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
        child: Center(
          child: WordCard(
            word: widget.word,
            showForms: _showForms,
          ),
        ),
      ),
    );
  }
}
