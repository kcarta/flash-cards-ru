import 'package:flash_cards/services/icon_helper.dart';
import 'package:flutter/material.dart';

class Word {
  final int? id;
  final String english;
  final String russian;
  final String type;
  final IconData icon;
  bool isLearned;

  Word(
      {this.id,
      required this.english,
      required this.russian,
      required this.type,
      required this.icon,
      required this.isLearned});

  factory Word.fromMap(Map<String, dynamic> json) {
    return Word(
      id: json["id"],
      english: json["english"],
      russian: json["russian"],
      type: json["type"],
      // TODO support Font Awesome icons by saving fontFamily in the database
      icon: int.tryParse(json["icon"]) != null
          ? IconData(int.parse(json["icon"]), fontFamily: 'MaterialIcons')
          : getMaterialIcon(name: json["icon"]) ?? Icons.error,
      isLearned: json["isLearned"] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'russian': russian,
      'type': type,
      'icon': icon.codePoint.toString(),
      'isLearned': isLearned ? 1 : 0,
    };
  }
}
