import "dart:html";
import "package:dialog/dialog.dart";
import "package:yaml/yaml.dart";

DateTime dnes = DateTime.now();
late Map mapa;
late String stav;
late Map dvojice;
String lang = document.documentElement!.lang!;

///  _  _ . _
/// |||(_||| )
///
void main() {
  HttpRequest.request("stav.yaml", responseType: "text")
      .then((HttpRequest request) {
    String yaml = request.responseText ?? "";
    mapa = loadYaml(yaml);
    if (dnes.isAfter(DateTime.parse(mapa["termin"]))) {
      vytvorit();
      doplnit();
    } else {
      stav = mapa["stav"];
      if (mapa["os"] != 1 && mapa["os"] != "on") doplnit();
    }
  }).catchError((_) {
    vytvorit();
    doplnit();
  }).whenComplete(() {
    querySelector("#stav")!.text = stav;
    poprekladat().then((_) {
      nadepsat(0);
      window.onScroll.listen(nadepsat);
      obarvit();
    });
  });

  querySelector("#vchodkheslu")!.onClick.listen(vstoupitkheslu);
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
  } else if (["v karanténě", "v izolaci", "nemocný"].contains(stav)) {
    mapa = {"in": 1, "tw": 1, "em": 1, "os": 0, "mo": 1, "me": 1, "li": 0};
  } else {
    mapa = {"in": 0, "tw": 0, "em": 0, "os": 1, "mo": 0, "me": 0, "li": 0};
  }
}

///  _  v _| _ _v.|_
/// |_)|‾(-|(_)/_||_
/// |
String? prelozit(String? text) {
  if (lang == "cs") {
    return text;
  }
  for (final String cesky in dvojice.keys) {
    text = text?.replaceAll(cesky, dvojice[cesky]);
  }
  return text;
}

///  _  _  _  v _| | _/ _| _ |_
/// |_)(_)|_)|‾(-|(|(_|(_|(_||_
/// |     |
Future<void> poprekladat() async {
  if (lang == "en") {
    await HttpRequest.request("preklady.yaml", responseType: "text")
        .then((HttpRequest request) {
      String yaml = request.responseText ?? "";
      dvojice = loadYaml(yaml);
    }).catchError((_) {
      dvojice = <String, String>{};
    }).whenComplete(() {
      List<Element> translatables = querySelectorAll("[translate]");
      for (final Element translatable in translatables) {
        String? innerHtml = translatable.innerHtml;
        String? label = translatable.getAttribute("aria-label");
        innerHtml = prelozit(innerHtml);
        label = prelozit(label);
        if (innerHtml != null) {
          translatable.setInnerHtml(innerHtml,
              validator: NodeValidatorBuilder()
                ..allowHtml5()
                ..allowSvg()
                ..allowInlineStyles());
        }
        if (label != null) translatable.setAttribute("aria-label", label);
      }
    });
  }
}

///  _ |_  _  _  .|_
/// (_)|_)(_|| \/||_
///
void obarvit() {
  for (final String promenna in mapa.keys) {
    if (mapa[promenna] == 1 || mapa[promenna] == "on") {
      Element prvek = querySelector("#" + promenna)!;
      String hint = prvek.getAttribute("aria-label")!;
      prvek
        ..classes.add("hint--success")
        ..setAttribute("aria-label", prelozit(hint + "\ndostupný")!)
        ..querySelector(".icon")!.style.color = "greenyellow";
    }
  }
}

///  _  _  _| _ _  _ _ |_
/// | )(_|(_|(-|_)_)(_||_
///            |
void nadepsat(_) {
  final int vyska = document.body!.offsetHeight;
  final double siroky = vyska * .9;
  final double posun = vyska * .6;
  final int pozice = window.scrollY;
  final Element kdoObsah = querySelector("#kdo-obsah .text")!;
  final Element kdeObsah = querySelector("#kde-obsah .text")!;
  final Element projektyObsah = querySelector("#projekty-obsah .text")!;
  final Element kontaktObsah = querySelector("#kontakt-obsah .text")!;
  kdoObsah.text = prelozit("Kdo?");
  kdeObsah.text = prelozit("Kde?");
  projektyObsah.text = prelozit("Projekty?");
  kontaktObsah.text = prelozit("Kontakt?");
  if (pozice <= posun) {
    kdoObsah.text = prelozit("Pavel Dvořák");
  } else if (pozice <= (posun + siroky)) {
    kdeObsah.text = prelozit("asi " + stav);
  } else if (pozice <= (posun + 2 * siroky)) {
    projektyObsah.text = prelozit("ve Škoda Auto");
  } else if (pozice <= (posun + 3 * siroky)) {
    kontaktObsah.text = prelozit("třeba naživo");
    final Map<String, String> poradi = {
      "me": "Messenger",
      "tw": "Twitteru",
      "mo": "mobilu",
      "em": "e-mailu",
      "in": "Instagramu",
      "li": "Linkedinu"
    };
    final String idealniSit = poradi.keys.firstWhere(
        (final String sit) => mapa[sit] == 1 || mapa[sit] == "on",
        orElse: () => "");
    final String? nazevSite = poradi[idealniSit];
    if (nazevSite != null) {
      kontaktObsah.text = prelozit("třeba na " + nazevSite);
    }
  }
}

///    _|_ _     _ .|_  |   |_  _ _|
/// \/_)|_(_)|_||_)||_  |(  | )(-_)||_|
///             |
void vstoupitkheslu(_) async {
  bool poprve = true;
  String? heslo = "";
  StyleElement styl = StyleElement();
  styl.text =
      "#dialogInput:focus{border-color:firebrick; box-shadow:0 0 0 .2em crimson}";
  while (heslo != window.atob("bHRlcGV0YWtvcG9w") && heslo != null) {
    if (poprve) {
      poprve = false;
    } else {
      document.head!.children.add(styl);
    }
    heslo = await (prompt("Heslo", ""));
  }
  document.head!.children.remove(styl);
  if (heslo != null) vstoupitkzapisu();
}

///    _|_ _     _ .|_  |   _  _/ _ . _
/// \/_)|_(_)|_||_)||_  |(  /_(_||_)|_)|_|
///             |                |
void vstoupitkzapisu() async {
  FormElement formular = FormElement();
  formular
    ..action = "zapis.php"
    ..method = "post";
  LabelElement keStavu = LabelElement();
  keStavu
    ..htmlFor = "je_stav"
    ..text = "Stav:";
  InputElement stav = InputElement();
  stav
    ..id = "je_stav"
    ..name = "stav";
  LabelElement kPolim = LabelElement();
  kPolim.text = "Online:";
  InputElement jeIn = InputElement();
  jeIn
    ..id = "je_in"
    ..name = "in"
    ..type = "checkbox"
    ..checked = true;
  LabelElement stIn = LabelElement();
  stIn
    ..className = "icon icon-instagram"
    ..htmlFor = "je_in";
  InputElement jeTw = InputElement();
  jeTw
    ..id = "je_tw"
    ..name = "tw"
    ..type = "checkbox"
    ..checked = true;
  LabelElement stTw = LabelElement();
  stTw
    ..className = "icon icon-twitter1"
    ..htmlFor = "je_tw";
  InputElement jeEm = InputElement();
  jeEm
    ..id = "je_em"
    ..name = "em"
    ..type = "checkbox"
    ..checked = true;
  LabelElement stEm = LabelElement();
  stEm
    ..className = "icon icon-email"
    ..htmlFor = "je_em";
  InputElement jeOs = InputElement();
  jeOs
    ..id = "je_os"
    ..name = "os"
    ..type = "checkbox"
    ..checked = true;
  LabelElement stOs = LabelElement();
  stOs
    ..className = "icon icon-man"
    ..htmlFor = "je_os";
  InputElement jeMo = InputElement();
  jeMo
    ..id = "je_mo"
    ..name = "mo"
    ..type = "checkbox"
    ..checked = true;
  LabelElement stMo = LabelElement();
  stMo
    ..className = "icon icon-smartphone"
    ..htmlFor = "je_mo";
  InputElement jeMe = InputElement();
  jeMe
    ..id = "je_me"
    ..name = "me"
    ..type = "checkbox"
    ..checked = true;
  LabelElement stMe = LabelElement();
  stMe
    ..className = "icon icon-messenger"
    ..htmlFor = "je_me";
  InputElement jeLi = InputElement();
  jeLi
    ..id = "je_li"
    ..name = "li"
    ..type = "checkbox";
  LabelElement stLi = LabelElement();
  stLi
    ..className = "icon icon-linkedin"
    ..htmlFor = "je_li";
  LabelElement kTerminu = LabelElement();
  kTerminu
    ..htmlFor = "je_termin"
    ..text = "Termín do:";
  InputElement termin = InputElement();
  termin
    ..name = "termin"
    ..id = "je_termin"
    ..type = "datetime-local"
    ..value = dnes.toString().substring(0, 16);
  List<Node> pole = [
    keStavu,
    stav,
    kPolim,
    jeIn,
    stIn,
    jeTw,
    stTw,
    jeEm,
    stEm,
    jeOs,
    stOs,
    jeMo,
    stMo,
    jeMe,
    stMe,
    jeLi,
    stLi,
    kTerminu,
    termin
  ];
  pole.forEach(formular.children.add as void Function(Node));
  if (await (modal(
      "Stav?", [formular], "Odeslat", "Zrušit", true, false, true))) {
    zapsat(formular);
  }
}

/// _  _  _  _ _ |_
/// /_(_||_)_)(_||_
///      |
void zapsat(FormElement formular) {
  document.body!.children.add(formular);
  formular.submit();
}
