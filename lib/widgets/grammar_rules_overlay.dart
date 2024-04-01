import 'package:flutter/cupertino.dart';

class GrammarRulesOverlay extends StatelessWidget {
  const GrammarRulesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // This builds the button that, when tapped, will show the overlay
    return CupertinoButton(
      padding: EdgeInsets.zero, // Adjust padding as needed
      child: const Icon(CupertinoIcons.book, color: CupertinoColors.activeBlue, size: 28),
      onPressed: () {
        // This is where the overlay is triggered
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: const Text('Verb Conjugation Rules'),
            message: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Present Tense Conjugation:'),
                  Text('1. Verbs ending in -ать: Replace -ать with -аю, -аешь, -ает, -аем, -аете, -ают.'),
                  Text('Example: Говорить -> говорю, говоришь, говорит, говорим, говорите, говорят.'),
                  Text('2. Verbs ending in -ять: Replace -ять with -яю, -яешь, -яет, -яем, -яете, -яют.'),
                  Text('Example: Видеть -> вижу, видишь, видит, видим, видите, видят.'),
                  Text(
                      '3. Verbs ending in -еть: Replace -еть with -ею, -еешь, -еет, -еем, -еете, -еют, but with exceptions.'),
                  Text('Example: Обещать -> обещаю, обещаешь, обещает, обещаем, обещаете, обещают.'),
                  Text('4. Verbs ending in -ить (type 1): Replace -ить with -ю, -ишь, -ит, -им, -ите, -ат.'),
                  Text('Example: Говорить -> говорю, говоришь, говорит, говорим, говорите, говорят.'),
                  Text('5. Verbs ending in -ить (type 2, irregular): Conjugation varies.'),
                  Text('Example: Пить -> пью, пьешь, пьет, пьем, пьете, пьют.'),
                  Text('Reflexive Verbs:'),
                  Text('6. For reflexive verbs ending in -ся, the endings are added before the -ся.'),
                  Text('Example: Учиться -> учусь, учишься, учится, учимся, учитесь, учатся.'),
                  Text('Aspectual Pairs:'),
                  Text(
                      '7. Many Russian verbs come in pairs to indicate the aspect: imperfective (ongoing action) and perfective (completed action).'),
                  Text('Imperfective: Читать (to read continuously), Perfective: Прочитать (to have read completely).'),
                  Text(
                      'Note: This is a simplified overview. Russian verb conjugation can be more complex due to exceptions and irregular verbs.'),
                ],
              ),
            ),
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
