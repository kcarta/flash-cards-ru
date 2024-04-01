import 'package:flash_cards/services/tts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_cards/models/word_model.dart';
import 'package:provider/provider.dart';

import '../services/word_form_helper.dart';

class WordFormsSheet extends StatefulWidget {
  final Word word;

  const WordFormsSheet({super.key, required this.word});

  @override
  State<WordFormsSheet> createState() => _WordFormsSheetState();
}

class _WordFormsSheetState extends State<WordFormsSheet> {
  Widget buildFormSection(String title, Map<String, String> forms) {
    TTSService ttsService = Provider.of<TTSService>(context, listen: false);
    List<Widget> tiles = forms.entries.map((entry) {
      return ListTile(
        title: Text(
          "${translateFormToRussianWord(title, entry.key)}: ${entry.value}",
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.blue),
          onPressed: () async {
            ttsService.speak(entry.value);
          },
        ),
        visualDensity: VisualDensity.compact, // Reduces space between list tiles
      );
    }).toList();

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
      if (value is Map) {
        formSections.add(buildFormSection(keyDisplay, Map<String, String>.from(value)));
      } else if (value is String) {
        formSections.add(buildFormSection(keyDisplay, {keyDisplay: value}));
      }
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
            title: Text("Forms for ${widget.word.russian}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
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
