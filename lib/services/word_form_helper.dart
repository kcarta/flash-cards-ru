// File: word_form_helper.dart
library word_form_helper;

String translateFormToRussianWord(String type, String form, String subform) {
  Map<String, Map<String, String>> typeMap = {
    "verb": {
      "first-singular": "я",
      "second-singular": "ты",
      "third-singular": "он/она/оно",
      "first-plural": "мы",
      "second-plural": "вы",
      "third-plural": "они",
    },
    "noun": {
      "singular": "единственное число",
      "plural": "множественное число",
    },
    "adjective": {
      "masculine": "мужской род",
      "feminine": "женский род",
      "neuter": "средний род",
      "plural": "множественное число",
    },
    "pronoun": {
      // Similar mapping for pronouns
    },
    // Add other part of speech mappings as needed
  };

  // Check if the type exists in the map, and if the subform exists for that type
  if (typeMap.containsKey(type) && typeMap[type]!.containsKey(subform)) {
    return typeMap[type]![subform]!;
  } else if (typeMap.containsKey(type) && typeMap[type]!.containsKey(form)) {
    // This condition handles cases where 'form' is the key of interest, not 'subform'
    return typeMap[type]![form]!;
  }

  // Fallback to subform or form if no translation is found
  return subform.isNotEmpty ? subform : form;
}
