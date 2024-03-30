library word_form_helper;

String translateFormToRussianWord(String tense, String form) {
  if (tense == "present") {
    switch (form) {
      case "first-singular":
        return "я";
      case "second-singular":
        return "ты";
      case "third-singular":
        return "он/она/оно";
      case "first-plural":
        return "мы";
      case "second-plural":
        return "вы";
      case "third-plural":
        return "они";
    }
  } else if (tense == "past") {
    switch (form) {
      case "masculine-singular":
        return "я";
      case "feminine-singular":
        return "ты";
      case "neuter-singular":
        return "он/она/оно";
    }
  }
  return form;
}
