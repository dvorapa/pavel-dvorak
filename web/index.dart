import "dart:html";
import "package:dialog/dialog.dart";
import "package:yaml/yaml.dart";

DateTime dnes = DateTime.now();
Map mapa;
String stav;

///  _  _ . _
/// |||(_||| )
///
main() {
  HttpRequest.getString("stav.yaml").then((String yaml) {
    mapa = loadYaml(yaml);
    if (dnes.isAfter(DateTime.parse(mapa["termin"]))) {
      vytvorit();
      doplnit();
    } else {
      stav = mapa["stav"];
      if (mapa["os"] != 1 && mapa["os"] != "on") doplnit();
    }
  }).catchError((String chyba) {
    vytvorit();
    doplnit();
  }).whenComplete(() {
    querySelector("#stav").text = stav;
    obarvit();
  });

  querySelector("#vchodkheslu").onClick.listen(vstoupitkheslu);
}

///     |_   _  v.|_
/// \/\/|_\/(_)|‾||_
///   /
vytvorit() {
  if (dnes.weekday <= 5) {
    if (dnes.hour == 6 && dnes.minute < 20) {
      stav = "u snídaně";
    } else if (dnes.hour == 12 && dnes.minute < 20) {
      stav = "u oběda";
    } else if (dnes.hour == 21 && dnes.minute < 20) {
      stav = "u večeře";
    } else if (dnes.hour < 6 || dnes.hour >= 22) {
      stav = "v limbu";
    } else if ((dnes.hour == 8 && dnes.minute >= 45) ||
        (dnes.hour > 8 && dnes.hour < 16) ||
        (dnes.hour == 16 && dnes.minute < 45)) {
      stav = "ve škole";
    } else if ((dnes.hour == 16 && dnes.minute >= 55) ||
        (dnes.hour > 16 && dnes.hour < 20) ||
        (dnes.hour == 20 && dnes.minute < 30)) {
      stav = "na tanci";
    } else if ((dnes.hour == 8 && dnes.minute >= 15) ||
        (dnes.hour > 8 && dnes.hour < 21) ||
        (dnes.hour == 21 && dnes.minute < 30)) {
      stav = "venku";
    } else {
      stav = "doma";
    }
  } else if (dnes.weekday > 5) {
    if (dnes.hour == 8 && dnes.minute < 20) {
      stav = "u snídaně";
    } else if (dnes.hour == 13 && dnes.minute < 20) {
      stav = "u oběda";
    } else if (dnes.hour == 18 && dnes.minute < 20) {
      stav = "u večeře";
    } else if (dnes.hour < 8) {
      stav = "v limbu";
    } else {
      stav = "doma";
    }
  }
}

///  _| _  _ | _ .|_
/// (_|(_)|_)|| )||_
///       |
doplnit() {
  if (stav == "doma") {
    mapa = {"in": 1, "tw": 1, "em": 1, "os": 1, "mo": 1, "me": 1, "li": 0};
  } else if (["venku", "na kole", "na cestě"].contains(stav)) {
    mapa = {"in": 0, "tw": 0, "em": 0, "os": 1, "mo": 1, "me": 0, "li": 0};
  } else {
    mapa = {"in": 0, "tw": 0, "em": 0, "os": 1, "mo": 0, "me": 0, "li": 0};
  }
}

///  _ |_  _  _  .|_
/// (_)|_)(_|| \/||_
///
obarvit() {
  mapa.forEach((promenna, hodnota) {
    if (mapa[promenna] == 1 || mapa[promenna] == "on") {
      Element prvek = querySelector("#" + promenna);
      String hint = prvek.getAttribute("aria-label");
      prvek
        ..classes.add("hint--success")
        ..setAttribute("aria-label", hint + "\ndostupný")
        ..querySelector(".icon").style.color = "greenyellow";
    }
  });
}

///    _|_ _     _ .|_  |   |_  _ _|
/// \/_)|_(_)|_||_)||_  |(  | )(-_)||_|
///             |
vstoupitkheslu(_) async {
  int i = 0;
  var heslo = "";
  while (heslo != window.atob("bHRlcGV0YWtvcG9w") && heslo != null) {
    heslo = await prompt("Heslo", "");
    if (i > 0) {
      querySelector("#dialogInput").style
        ..borderColor = "firebrick"
        ..boxShadow = "0 0 0 .2em crimson";
    } else {
      i++;
    }
  }
  if (heslo != null) vstoupitkzapisu(_);
}

///    _|_ _     _ .|_  |   _  _/ _ . _
/// \/_)|_(_)|_||_)||_  |(  /_(_||_)|_)|_|
///             |                |
vstoupitkzapisu(_) async {
  FormElement formular = FormElement();
  formular
    ..action = "zapis.php"
    ..method = "post";
  LabelElement ke_stavu = LabelElement();
  ke_stavu
    ..htmlFor = "stav"
    ..text = "Stav:";
  InputElement stav = InputElement();
  stav.name = "stav";
  BRElement br = BRElement();
  LabelElement k_polim = LabelElement();
  k_polim.text = "Online:";
  BRElement br2 = BRElement();
  InputElement je_in = InputElement();
  je_in
    ..name = "in"
    ..type = "checkbox"
    ..checked = true;
  InputElement je_tw = InputElement();
  je_tw
    ..name = "tw"
    ..type = "checkbox"
    ..checked = true;
  InputElement je_em = InputElement();
  je_em
    ..type = "checkbox"
    ..name = "em";
  InputElement je_os = InputElement();
  je_os
    ..name = "os"
    ..type = "checkbox"
    ..checked = true;
  InputElement je_mo = InputElement();
  je_mo
    ..name = "mo"
    ..type = "checkbox"
    ..checked = true;
  InputElement je_me = InputElement();
  je_me
    ..name = "me"
    ..type = "checkbox"
    ..checked = true;
  InputElement je_li = InputElement();
  je_li
    ..type = "checkbox"
    ..name = "li";
  BRElement br3 = BRElement();
  LabelElement k_terminu = LabelElement();
  k_terminu
    ..htmlFor = "termin"
    ..text = "Termín:";
  InputElement termin = InputElement();
  termin
    ..name = "termin"
    ..type = "datetime-local"
    ..value = dnes.toString().substring(0, 16);
  List<Node> pole = [
    ke_stavu,
    stav,
    br,
    k_polim,
    br2,
    je_in,
    je_tw,
    je_em,
    je_os,
    je_mo,
    je_me,
    je_li,
    br3,
    k_terminu,
    termin
  ];
  pole.forEach((prvek) {
    formular.children.add(prvek);
  });
  if (await modal(
      "Stav?", [formular], "Odeslat", "Zrušit", true, false, true)) {
    zapsat(pole, formular);
  }
}

/// _  _  _  _ _ |_
/// /_(_||_)_)(_||_
///      |
zapsat(List<Node> stav, FormElement formular) {
  querySelector("body").children.add(formular);
  formular.submit();
}
