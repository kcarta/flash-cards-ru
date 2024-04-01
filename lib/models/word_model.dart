import 'dart:convert';

import 'package:flash_cards/services/icon_helper.dart';
import 'package:flutter/material.dart';

class Word {
  final int? id;
  final String english;
  final String russian;
  final String example;
  final String exampleTranslation;
  final String type;
  final IconData icon;
  final Map<String, dynamic> forms;
  bool isLearned;

  Word({
    this.id,
    required this.english,
    required this.russian,
    required this.type,
    required this.icon,
    this.example = '',
    this.exampleTranslation = '',
    this.forms = const {},
    this.isLearned = false,
  });

  factory Word.fromMap(Map<String, dynamic> json) {
    Map<String, dynamic> formsMap = {};

    // Check if 'forms' exists and is not null
    if (json.containsKey('forms') && json['forms'] != null) {
      var forms = json['forms'];

      if (forms is String) {
        // Decode the string to a map
        formsMap = jsonDecode(forms) as Map<String, dynamic>;
      } else if (forms is Map) {
        // Cast the map to the desired type
        formsMap = forms.cast<String, dynamic>();
      }
    }

    // If 'forms' does not exist or is null, formsMap remains an empty map

    return Word(
      id: json["id"],
      english: json["english"],
      russian: json["russian"],
      example: json["example"] ?? '',
      exampleTranslation: json["exampleTranslation"] ?? '',
      type: json["type"],
      icon: int.tryParse(json["icon"]) != null
          ? IconData(int.parse(json["icon"]), fontFamily: 'MaterialIcons')
          : getMaterialIcon(name: json["icon"]) ?? Icons.error,
      isLearned: json["isLearned"] == 1,
      forms: formsMap,
    );
  }

  bool get hasForms => forms.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'russian': russian,
      'example': example,
      'exampleTranslation': exampleTranslation,
      'type': type,
      'icon': icon.codePoint.toString(),
      'isLearned': isLearned ? 1 : 0,
      'forms': json.encode(forms),
    };
  }
}
