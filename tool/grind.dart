import "dart:io";
import "package:grinder/grinder.dart";

Directory slozkaIkon = Directory("web/aplikace/favicons/");
Directory slozkaWebu = Directory("web/");
File tmpSoubor = File(Directory.systemTemp.path + "/pavel-dvorak");
String seznamIkon = "";

void main(args) => grind(args);

@Task("Přesun ikon")
void move() {
  if (slozkaIkon.existsSync()) {
    List<FileSystemEntity> ikony = slozkaIkon.listSync();

    print("Nasledujici soubory budou presunuty:");
    ikony.forEach((FileSystemEntity polozka) {
      if ((polozka is File) && (polozka.existsSync())) {
        print(polozka.path.substring(22));
        seznamIkon = seznamIkon + polozka.path.substring(22) + "\n";
        polozka.copySync(slozkaWebu.path + polozka.path.substring(22));
      }
    });

    tmpSoubor.writeAsString(seznamIkon);
    slozkaIkon.deleteSync(recursive: true);
  }
}

@Task("Vrácení ikon")
void restore() {
  if (tmpSoubor.existsSync()) {
    slozkaIkon.createSync(recursive: true);
    tmpSoubor.readAsLines().then((List<String> ikony) {
      print("Nasledujici soubory budou vraceny:");
      ikony.forEach((String polozka) {
        print(polozka);
        File soubor = File(slozkaWebu.path + polozka);
        if (soubor.existsSync()) {
          soubor.copySync(slozkaIkon.path + polozka);
          soubor.deleteSync();
        }
      });
    });
  }
}

@Task("pub upgrade")
void upgrade() async {
  Pub.upgrade();
}

@Task("webdev build")
@Depends(upgrade, move)
void webdevBuild() async {
  await Process.run("webdev", ["build"]);
}

@Task("webdev serve")
@Depends(upgrade, move)
void serve() async {
  await Process.run("webdev", ["serve"]);
}

@DefaultTask("Build")
@Depends(upgrade, move, webdevBuild, restore)
void build() {}

@Task("Smazání buildu")
void clean() => defaultClean();
