library word_form_helper;

String translateFormToRussianWord(String form, String subform) {
  if (form == "present") {
    switch (subform) {
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
  } else if (form == "past") {
    switch (subform) {
      case "masculine-singular":
        return "я";
      case "feminine-singular":
        return "ты";
      case "neuter-singular":
        return "он/она/оно";
    }
  }
  return subform;
}
