import "dart:io";
import "package:grinder/grinder.dart";

Directory slozkaIkon = Directory("web/aplikace/favicons/");
Directory slozkaWebu = Directory("web/");
File tmpSoubor = File(Directory.systemTemp.path + "/pavel-dvorak");
String seznamIkon = "";

main(args) => grind(args);

@Task("Presunuti")
move() {
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

@Task("Webdev")
@Depends(move)
webdev() async {
  Pub.upgrade();
  await Process.run("webdev", ["build"]);
}

@Task("Vraceni")
restore() {
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

@DefaultTask("Build")
@Depends(move, webdev, restore)
build() {}

@Task("Obnoveni")
clean() => defaultClean();
