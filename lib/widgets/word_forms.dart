import 'package:flash_cards/services/word_form_helper.dart';
import 'package:flutter/material.dart';

class WordFormsWidget extends StatelessWidget {
  final Map<String, dynamic> forms;
  final String type;

  const WordFormsWidget({super.key, required this.forms, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(children: buildFormsWidgets(forms));
  }

  List<Widget> buildFormsWidgets(Map<String, dynamic> forms) {
    List<Widget> formWidgets = [];
    forms.forEach((key, value) {
      String keyDisplay = key[0].toUpperCase() + key.substring(1);
      formWidgets.add(const Divider());
      formWidgets.add(Text(
        "$keyDisplay:", // Tense or Form
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));

      if (value is Map) {
        // If value is a Map, it's a Map of Maps (e.g., for verbs)
        Map<String, dynamic>.from(value).forEach((formKey, formValue) {
          String formText = translateFormToRussianWord(key, formKey); // Assuming this function exists
          formWidgets.add(
            Text(
              "$formText: $formValue", // Form name and value
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        });
      } else if (value is String) {
        // If value is a String, it's a single Map (e.g., for adjectives)
        formWidgets.add(Text(
          value, // Value
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
      }
    });
    if (forms.isNotEmpty) formWidgets.add(const Divider());
    return formWidgets;
  }
}
