import 'package:flash_cards/models/word_model.dart';
import 'package:flutter/cupertino.dart';

class WordFormsSheet extends StatefulWidget {
  final Word word;
  const WordFormsSheet({super.key, required this.word});

  @override
  State<WordFormsSheet> createState() => _WordFormsSheetState();
}

class _WordFormsSheetState extends State<WordFormsSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const Icon(CupertinoIcons.text_badge_plus, color: CupertinoColors.activeBlue, size: 28),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: Text("Forms for ${widget.word.russian}"),
            message: SizedBox(
              // Define a maximum height to prevent the overlay from taking up the full screen
              height: MediaQuery.of(context).size.height * 0.75,
              child: const Column(
                children: [
                  Flexible(child: Text("Content goes here")),
                ],
              ),
            ),
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }
}
