import "dart:html";
import "package:dialog/dialog.dart";
import "package:yaml/yaml.dart";

DateTime dnes = DateTime.now();
Map mapa;
String stav;

///  _  _ . _
/// |||(_||| )
///
void main() {
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
void vytvorit() {
  if (dnes.weekday <= 5) {
    if (dnes.hour < 5 || dnes.hour >= 22) {
      stav = "v limbu";
    } else if (dnes.hour == 5 && dnes.minute < 30) {
      stav = "u snídaně";
    } else if (dnes.hour == 12 && dnes.minute < 30) {
      stav = "u oběda";
    } else if (dnes.hour >= 6 && dnes.hour < 15) {
      stav = "v práci";
    } else if (dnes.hour >= 17 && dnes.hour < 20) {
      stav = "na tanci";
    } else if (dnes.hour == 21 && dnes.minute >= 30) {
      stav = "u večeře";
    } else if ((dnes.hour == 5 && dnes.minute >= 30) ||
        (dnes.hour > 5 && dnes.hour < 21) ||
        (dnes.hour == 21 && dnes.minute < 30)) {
      stav = "venku";
    } else {
      stav = "doma";
    }
  } else {
    if (dnes.hour < 9) {
      stav = "v limbu";
    } else if (dnes.hour == 9 && dnes.minute < 30) {
      stav = "u snídaně";
    } else if (dnes.hour == 11 && dnes.minute < 30) {
      stav = "u oběda";
    } else if (dnes.hour == 18 && dnes.minute < 30) {
      stav = "u večeře";
    } else {
      stav = "doma";
    }
  }
}

///  _| _  _ | _ .|_
/// (_|(_)|_)|| )||_
///       |
void doplnit() {
  if (stav == "doma") {
    mapa = {"in": 1, "tw": 1, "em": 1, "os": 1, "mo": 1, "me": 1, "li": 0};
  } else if (["venku", "na kole", "na cestě"].contains(stav)) {
    mapa = {"in": 0, "tw": 0, "em": 0, "os": 1, "mo": 1, "me": 0, "li": 0};
  } else if (["v karanténě", "v izolaci"].contains(stav)) {
    mapa = {"in": 1, "tw": 1, "em": 1, "os": 0, "mo": 1, "me": 1, "li": 0};
  } else {
    mapa = {"in": 0, "tw": 0, "em": 0, "os": 1, "mo": 0, "me": 0, "li": 0};
  }
}

///  _ |_  _  _  .|_
/// (_)|_)(_|| \/||_
///
void obarvit() {
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
void vstoupitkheslu(_) async {
  int i = 0;
  var heslo = "";
  while (heslo != window.atob("bHRlcGV0YWtvcG9w") && heslo != null) {
    if (i > 0) {
      querySelector("#dialogInput").style
        ..borderColor = "firebrick"
        ..boxShadow = "0 0 0 .2em crimson";
    } else {
      i++;
    }
    heslo = await prompt("Heslo", "");
  }
  if (heslo != null) vstoupitkzapisu(_);
}

///    _|_ _     _ .|_  |   _  _/ _ . _
/// \/_)|_(_)|_||_)||_  |(  /_(_||_)|_)|_|
///             |                |
void vstoupitkzapisu(_) async {
  FormElement formular = FormElement();
  formular
    ..action = "zapis.php"
    ..method = "post";
  LabelElement ke_stavu = LabelElement();
  ke_stavu
    ..htmlFor = "je_stav"
    ..text = "Stav:";
  InputElement stav = InputElement();
  stav
    ..id = "je_stav"
    ..name = "stav";
  LabelElement k_polim = LabelElement();
  k_polim.text = "Online:";
  InputElement je_in = InputElement();
  je_in
    ..id = "je_in"
    ..name = "in"
    ..type = "checkbox"
    ..checked = true;
  LabelElement st_in = LabelElement();
  st_in
    ..className = "icon icon-instagram"
    ..htmlFor = "je_in";
  InputElement je_tw = InputElement();
  je_tw
    ..id = "je_tw"
    ..name = "tw"
    ..type = "checkbox"
    ..checked = true;
  LabelElement st_tw = LabelElement();
  st_tw
    ..className = "icon icon-twitter1"
    ..htmlFor = "je_tw";
  InputElement je_em = InputElement();
  je_em
    ..id = "je_em"
    ..name = "em"
    ..type = "checkbox"
    ..checked = true;
  LabelElement st_em = LabelElement();
  st_em
    ..className = "icon icon-email"
    ..htmlFor = "je_em";
  InputElement je_os = InputElement();
  je_os
    ..id = "je_os"
    ..name = "os"
    ..type = "checkbox"
    ..checked = true;
  LabelElement st_os = LabelElement();
  st_os
    ..className = "icon icon-man"
    ..htmlFor = "je_os";
  InputElement je_mo = InputElement();
  je_mo
    ..id = "je_mo"
    ..name = "mo"
    ..type = "checkbox"
    ..checked = true;
  LabelElement st_mo = LabelElement();
  st_mo
    ..className = "icon icon-smartphone"
    ..htmlFor = "je_mo";
  InputElement je_me = InputElement();
  je_me
    ..id = "je_me"
    ..name = "me"
    ..type = "checkbox"
    ..checked = true;
  LabelElement st_me = LabelElement();
  st_me
    ..className = "icon icon-messenger"
    ..htmlFor = "je_me";
  InputElement je_li = InputElement();
  je_li
    ..id = "je_li"
    ..name = "li"
    ..type = "checkbox";
  LabelElement st_li = LabelElement();
  st_li
    ..className = "icon icon-linkedin"
    ..htmlFor = "je_li";
  LabelElement k_terminu = LabelElement();
  k_terminu
    ..htmlFor = "je_termin"
    ..text = "Termín:";
  InputElement termin = InputElement();
  termin
    ..name = "termin"
    ..id = "je_termin"
    ..type = "datetime-local"
    ..value = dnes.toString().substring(0, 16);
  List<Node> pole = [
    ke_stavu,
    stav,
    k_polim,
    je_in,
    st_in,
    je_tw,
    st_tw,
    je_em,
    st_em,
    je_os,
    st_os,
    je_mo,
    st_mo,
    je_me,
    st_me,
    je_li,
    st_li,
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
void zapsat(List<Node> stav, FormElement formular) {
  querySelector("body").children.add(formular);
  formular.submit();
}
