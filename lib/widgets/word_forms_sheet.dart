import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_cards/models/word_model.dart';
import 'package:provider/provider.dart';
import '../services/tts_service.dart';
import '../services/word_form_helper.dart'; // Make sure this path is correct

class WordFormsSheet extends StatefulWidget {
  final Word word;

  const WordFormsSheet({super.key, required this.word});

  @override
  State<WordFormsSheet> createState() => _WordFormsSheetState();
}

class _WordFormsSheetState extends State<WordFormsSheet> {
  Widget buildFormSection(String title, dynamic forms) {
    TTSService ttsService = Provider.of<TTSService>(context, listen: false);

    List<Widget> tiles;
    if (forms is Map) {
      tiles = forms.entries.map<Widget>((entry) {
        String displayKey = translateFormToRussianWord(widget.word.type, title, entry.key);
        return ListTile(
          title: Text(
            "$displayKey: ${entry.value}",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () {
              ttsService.speak(entry.value);
            },
          ),
          visualDensity: VisualDensity.compact,
        );
      }).toList();
    } else {
      // Handle the case where forms is just a String
      String displayKey = translateFormToRussianWord(widget.word.type, title, "");
      tiles = [
        ListTile(
          title: Text(
            "$displayKey: $forms",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () {
              ttsService.speak(forms);
            },
          ),
          visualDensity: VisualDensity.compact,
        )
      ];
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ...tiles,
        ],
      ),
    );
  }

  List<Widget> buildFormsWidgets(Map<String, dynamic> forms) {
    List<Widget> formSections = [];
    forms.forEach((key, value) {
      String keyDisplay = key[0].toUpperCase() + key.substring(1);
      formSections.add(buildFormSection(keyDisplay, value));
    });
    return formSections;
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
              height: MediaQuery.of(context).size.height * 0.75,
              child: SingleChildScrollView(
                child: Column(
                  children: buildFormsWidgets(widget.word.forms),
                ),
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
