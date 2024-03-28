class Word {
  final int? id;
  final String english;
  final String russian;
  final String type;
  bool isLearned;

  Word(
      {this.id,
      required this.english,
      required this.russian,
      required this.type,
      required this.isLearned});

  factory Word.fromMap(Map<String, dynamic> json) => Word(
        id: json["id"],
        english: json["english"],
        russian: json["russian"],
        type: json["type"],
        isLearned: json["isLearned"] == 1,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'russian': russian,
      'type': type,
      'isLearned': isLearned ? 1 : 0,
    };
  }
}
