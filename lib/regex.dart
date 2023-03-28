
var numregex = RegExp(r"[0-9]*");
var numregexnoktali = RegExp(r"[0-9.]*");
var harfregex = RegExp(r"^[a-zA-Z]*");
RegExp turkceKarRegex = RegExp(r"[iİçÇşŞğĞÜüÖö]*");
RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
RegExp regex2 = RegExp(r"(\.0$)");
RegExp virgulRegex = RegExp(r",");
RegExp noktaRegex = RegExp(r".");

final List<RegExp> trregexList = [
  RegExp(r"ı"),
  RegExp(r"İ"),
  RegExp(r"ç"),
  RegExp(r"Ç"),
  RegExp(r"Ş"),
  RegExp(r"ş"),
  RegExp(r"ğ"),
  RegExp(r"Ğ"),
  RegExp(r"ü"),
  RegExp(r"Ü"),
  RegExp(r"ö"),
  RegExp(r"Ö"),
];

const List<String> trRegexIngKarsilik = [
  "i",
  "I",
  "c",
  "C",
  "S",
  "s",
  "g",
  "G",
  "u",
  "U",
  "o",
  "O",
];
