import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GrammarRulesOverlay extends StatefulWidget {
  final String type;
  const GrammarRulesOverlay({super.key, required this.type});

  @override
  State<GrammarRulesOverlay> createState() => _GrammarRulesOverlayState();
}

class _GrammarRulesOverlayState extends State<GrammarRulesOverlay> {
  String _markdownData = "";

  @override
  void initState() {
    super.initState();
    var markdownSource = 'assets/grammar_rules/${widget.type}.md';
    rootBundle.loadString(markdownSource).then((data) => setState(() => _markdownData = data));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const Icon(CupertinoIcons.book, color: CupertinoColors.activeBlue, size: 28),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: const Text('Grammar Rules'),
            message: SizedBox(
              // Define a maximum height to prevent the overlay from taking up the full screen
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Flexible(
                    child: Markdown(
                      data: _markdownData,
                      shrinkWrap: true,
                    ),
                  ),
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
