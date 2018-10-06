<?php
$pole=array("stav","in","tw","em","os","mo","me","li","termin");
$obsah="";
foreach($pole as $promenna){
$obsah.="$promenna: ".$_POST[$promenna]."\r\n";
}
$soubor=fopen("stav.yaml","w+");
fwrite($soubor,$obsah);
fclose($soubor);
header("Location: ".$_SERVER["HTTP_REFERER"]);
?>