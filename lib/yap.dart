library yap;
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


String tarihDonusturucu(String tarih) {
  if (tarih.isNotEmpty) {
    var veri = tarih.split(" ")[0].trim().split(".");
    if (veri[0].length == 1) {
      veri[0] = "0${veri[0]}";
    }
    if (veri[1].length == 1) {
      veri[1] = "0${veri[1]}";
    }
    return veri.join(".");
  }
  return "";
}

String jsondanBul({required Map json, required String hedef, String? def}) {
  String mesaj = def ?? "Bir sorun oluştu, lütfen sonra tekrar deneyiniz.";

  try {
    if (json["veri"]["Ana"][0][hedef] != null) {
      mesaj = json["veri"]["Ana"][0][hedef];
    }
  } catch (e) {
    //
  }
  try {
    if (json["veri"][0][hedef] != null) {
      mesaj = json["veri"][0][hedef];
    }
  } catch (e) {
    //
  }
  try {
    if (json["veri"][hedef] != null) {
      mesaj = json["veri"][hedef];
    }
  } catch (e) {
    //
  }

  return mesaj;
}

String? nullabletarihDonusturucu(String? tarih) {
  if (tarih == null) {
    return null;
  } else {
    if (tarih.isNotEmpty) {
      var veri = tarih.split(" ")[0].trim().split(".");
      if (veri[0].length == 1) {
        veri[0] = "0${veri[0]}";
      }
      if (veri[1].length == 1) {
        veri[1] = "0${veri[1]}";
      }
      return veri.join(".");
    }
    return "";
  }
}

Future<void> then([Function() fn = futurefn]) async {
  var done = false;
  SchedulerBinding.instance.scheduleFrameCallback((timeStamp) async {
    fn();

    done = true;
  });
  await waitWhile(() => done, () => null);
}

String makeQueryParams(Map? data) {
  String v = "?";

  if (data != null) {
    data.forEach((key, value) {
      v = "$v&$key=$value";
    });
  }

  return v;
}

double evoDoubleParse(String v) {
  double veri = 0;

  try {
    veri = double.parse(noktasifirkaldir(double.parse(v.isEmpty
        ? "0"
        : v.length > 18
            ? v.substring(0, 18)
            : v)));
  } catch (e) {
    debugPrint("Bunu parse edemedim: $v");
    veri = 0;
  }
  return veri;
}

double evoDoubleParseRaw(String v) {
  double veri = 0;

  try {
    veri = double.parse(v.isEmpty
        ? "0"
        : v.length > 18
            ? v.substring(0, 18)
            : v);
  } catch (e) {
    debugPrint("Bunu parse edemedim: $v");
    veri = 0;
  }
  return veri;
}

double evoDoubleParseAbs(String v) {
  double veri = 0;
  try {
    veri = double.parse(noktasifirkaldir(double.parse(v.isEmpty
            ? "0"
            : v.length > 18
                ? v.substring(0, 18)
                : v)))
        .abs();
  } catch (e) {
    veri = 0;
  }
  return veri;
}

var date = DateTime.now();

Map clearNullOnMap(Map map) {
  Map newMap = {};
  map.forEach((key, value) {
    if (value != null) {
      newMap[key] = value;
    }
  });
  return newMap;
}

void removeFocus(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

Future<void> saatGoster(context, Function(String time) onPicked) async {
  final TimeOfDay? time =
      await showTimePicker(context: context, initialTime: TimeOfDay.now());
  if (time != null) {
    onPicked.call(time.string());
  }
}

void tarihGoster(context, Function(String) onPicked,
    {String? ilktar, String? sontar, String? startDate}) {
  final DateTime ilkdate = DateTime(
    ilktar != null ? int.parse(ilktar.substring(6)) : 1900,
    ilktar != null ? int.parse(ilktar.substring(3, 5)) : 1,
    ilktar != null ? int.parse(ilktar.substring(0, 2)) : 1,
  );

  final DateTime sondate = DateTime(
    sontar != null ? int.parse(sontar.substring(6)) : 2035,
    sontar != null ? int.parse(sontar.substring(3, 5)) : 1,
    sontar != null ? int.parse(sontar.substring(0, 2)) : 1,
  );

  var s = startDate?.toDateTime();

  var init = s == null
      ? (ilkdate.isAfter(DateTime.now())
          ? ilkdate
          : DateTime.now().isBefore(sondate)
              ? DateTime.now()
              : sondate)
      : (ilkdate.isAfter(s)
          ? ilkdate
          : s.isBefore(sondate)
              ? s
              : sondate);

  showDatePicker(
    context: context,
    initialDate: init,
    firstDate: ilkdate,
    lastDate: sondate,
  ).then((value) {
    if (value != null) {
      onPicked.call(
          "${value.day.toString().length == 1 ? "0${value.day.toString()}" : value.day.toString()}.${value.month.toString().length == 1 ? "0${value.month.toString()}" : value.month.toString()}.${value.year.toString()}");
    }
  });
}

void drawerReplace(PageRouteInfo<dynamic> route, {void Function()? ifnot}) {
  
  SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
    if (kendisayfasinda(ContextGetir(), name: route.routeName)) {
      ifnot?.call();
    } else {
      then(() async {
        AutoRouter.of(ContextGetir()).replace(route);
      });
    }
  });
}



extension EvoGenelScrollControllerExt on ScrollController {
  void enSonaGit(Duration? duration) {
    animateTo(position.maxScrollExtent,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: Curves.ease);
  }
}



bool kendisayfasinda(BuildContext context, {String? name}) {
  var page = AutoRouter.of(ContextGetir()).stack.last.name;
  var beklenen = ModalRoute.of(context)?.settings.name ?? "";

  return page == (name ?? beklenen);
}

void emptyfn() {}
Future<void> futurefn() async {}

void tryTo(Function() fn) {
  try {
    fn();
  } catch (e) {
    //
  }
}

class AIDAAD {
  String aId = "";
  String aAdi = "";

  void duzenle({String? ad, String? id}) {
    aAdi = aAdi.mnd(ad);
    aId = aId.mnd(id);
  }

  AIDAAD({required this.aId, required this.aAdi});

  AIDAAD.fromJson(Map json, {String? aid, String? aad}) {
    aId = json[aid ?? 'a_id'];
    aAdi = json[aad ?? 'a_adi'];
  }

  Map toJson([String? aid, String? aad]) {
    final Map data = {};
    data[aid ?? 'a_id'] = aId;
    data[aad ?? 'a_adi'] = aAdi;
    return data;
  }
}

void linkAc(String url) async {
  var uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint("Url açılamadı");
    //throw 'Could not launch $url';
  }
}

Future<void> smsAc(String telno) async {
  if (!await launchUrl(Uri(path: telno, scheme: "sms"),
      mode: LaunchMode.externalApplication)) {
    debugPrint("sms açılamadı");
    //throw 'Could not launch $url';
  }
}

Future<void> mailAc(String mail) async {
  if (!await launchUrl(Uri(scheme: "mailto", path: mail),
      mode: LaunchMode.externalApplication)) {
    debugPrint("mail açılamadı");
    //throw 'Could not launch $url';
  }
}



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

Widget offlineFiltre(Widget widget, String aranan, String item) {
  var a = aranan.toLowerCase().turkceKarDegis();
  var b = item.toLowerCase().turkceKarDegis();
  var c = (b.contains(a));

  return c ? widget : const NullWidget();
}

class NullWidget extends StatelessWidget {
  const NullWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 0, height: 0);
  }
}
String noktasifirkaldir(double val) {
  var deger = val
      .toStringAsFixed(3)
      .replaceAll(regex, '')
      .replaceAll(regex2, "")
      .replaceAll(RegExp(r"(\.00$)"), "");
  return deger;
}

String strnoktasifirkaldir(String val) {
  var deger = double.tryParse(val);
  deger = deger ?? 0;

  return deger
      .toStringAsFixed(3)
      .replaceAll(regex, '')
      .replaceAll(regex2, "")
      .replaceAll(RegExp(r"(\.00$)"), "");
}

String virguluNoktaYap(String? val) {
  var deger = val?.replaceAll(virgulRegex, ".").trim();
  return deger ?? "";
}

String noktayiVirgulYap(String? val) {
  var deger = val?.replaceAll(".", ",").trim();
  return deger ?? "";
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> loadingKey = GlobalKey<NavigatorState>();
const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);
// ignore: non_constant_identifier_names
BuildContext ContextGetir() {
  return navigatorKey.currentContext!;
}

Future waitWhile(bool Function() beklenen, Function() fn,
    [bool timeoutMevcut = false,
    Duration timeout = const Duration(seconds: 1),
    Duration pollInterval = const Duration(milliseconds: 200)]) {
  var completer = Completer();
  check() {
    if (beklenen()) {
      completer.complete();
      fn.call();
    } else {
      Timer(pollInterval, check);
    }
  }

  check();
  return completer.future;
}

extension ModelParse<T> on T {
  T mnd(T? v) => v ?? this;
}

extension Tarih on String {
  String tar() {
    return tarihDonusturucu(toString());
  }
}

mixin EvoModelMixin<T> on ChangeNotifier {
  ///asırlarca düzenleyici metodlar yazmak ile uğraşmak istemiyorsan bunu kullan
  ///type.action(()async{type.a = 1;})
  Future<void> action(Function() action) async {
    await action.call();
    notifyListeners();
  }
}

extension Matcher on Iterable<RegExpMatch> {
  String string() {
    return map((e) => e[0]).join();
  }
}

extension EvoGenelExtensionBool on bool {
  String string() {
    return this ? "1" : "0";
  }
}

extension DateTimeStringParse on TimeOfDay {
  String string() {
    var saat = hour.toString();
    var dakika = minute.toString();

    saat = saat.length == 1 ? "0" + saat : saat;
    dakika = dakika.length == 1 ? "0" + dakika : dakika;

    return "$saat:$dakika";
  }
}

extension EvoGenelExtensionList<E> on List<E> {
  List<E> sublistSafe(int start, int end) {
    if (length >= end) {
      return sublist(start, end);
    } else {
      return sublist(start, length);
    }
  }
}

extension EvoGenelExtensionString on String {
  String get htmlRemoved {
    {
      var e = replaceAll(RegExp(r'<[^>]*>'), " ");
      //e = e.Replace("<p>", " ");        // üst satırdaki regex sayesinde html tag'ları ile beraber içerisindeki style vs hepsi temizlenmekte. csv ve xlsx için çalışmakta. 22.06.2020
      //e = e.Replace("</p>", " ");
      //e = e.Replace("<div>", " ");
      //e = e.Replace("</div>", " ");
      //e = e.Replace("<br>", " ");
      //e = e.Replace("</br>", " ");
      //e = e.Replace("<span>", " ");
      //e = e.Replace("</span>", " ");
      e = e.replaceAll("&nbsp", " ");
      e = e.replaceAll("\r\n", " ");
      e = e.replaceAll("\r", " ");
      e = e.replaceAll("\n", " ");
      e = e.replaceAll(";", " ");
      return e;
    }
  }

  String substringSafe(int start, int end) {
    if (length >= end) {
      return substring(start, end);
    } else {
      return substring(start, length);
    }
  }

  String saat() {
    if (length > 6) {
      return substring(10, 16);
    } else {
      return this;
    }
  }

  bool isBlank() => trim().isEmpty;
  double tryParseDouble() => double.tryParse(this) ?? 0;

  int tryParseInt() {
    return int.tryParse(this) ?? 0;
  }

  /// <summary> 00:00 =>>> TimeOfDay(00:00)
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String toSnakeCase() {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return replaceAllMapped(exp, (Match m) => ('_${m.group(0) ?? ""}'))
        .toLowerCase();
  }

  String turkceKarDegis() {
    String s = this;
    if (contains(turkceKarRegex)) {
      for (int i = 0; i < trregexList.length; i++) {
        s = s.replaceAll(trregexList[i], trRegexIngKarsilik[i]);
      }
    }

    return s;
  }

  Hour toHours() {
    if (length == 5) {
      List v = split(":");
      v = v.map((e) => int.parse(e)).toList();
      return Hour(hour: v[0], minutes: v[1]);
    } else if (length > 5) {
      List v = substring(11).split(":");
      v = v.map((e) => int.parse(e)).toList();
      return Hour(hour: v[0], minutes: v[1]);
    } else {
      return Hour(hour: 0, minutes: 0);
    }
  }

  TimeOfDay toTimeOfDay() {
    late TimeOfDay sonuc;
    try {
      sonuc = TimeOfDay(
          hour: int.parse(substring(0, 2)), minute: int.parse(substring(3, 5)));
    } catch (e) {
      sonuc = const TimeOfDay(hour: 0, minute: 0);
    }

    return sonuc;
  }

  String reverse() {
    return split('').reversed.join();
  }

  bool? toBool([bool? ifnull]) {
    if (isEmpty) {
      return ifnull;
    } else {
      return this == "1";
    }
  }

  String noktaToVirgul() {
    return virguluNoktaYap(evoDoubleParse(noktaDuzenle()).toStringAsFixed(2));
  }

  String virguTolNokta() {
    return replaceAll(",", ".");
  }

  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  String toStringAsFixed(int uzunluk) {
    var val = harfSayiAyir().first.split(".");
    if (val.length == 1) {
      return this;
    }

    if (val.last.length > uzunluk) {
      var yuvarlamali = int.parse(val.last[uzunluk]) >= 5;
      val.last = val.last.substring(0, uzunluk);
      var sonchar =
          (int.parse(val.last.substring(uzunluk - 1)) + (yuvarlamali ? 1 : 0))
              .toString();
      val.last = val.last.substring(0, uzunluk - 1) + sonchar;
    }

    if (val.length > 1 && val.last.length > uzunluk && val.last.isEmpty) {
      val.removeLast();
    } else if (val.last.length < uzunluk) {
      var fark = (val.last.length - uzunluk).abs();
      for (var i = 0; i < fark; i++) {
        val.last = val.last + "0";
      }
    }

    return val.join(".") + harfSayiAyir().last;
  }

  DateTime toDateTime() {
    DateTime time = DateTime.now();
    if (isNotEmpty) {
      try {
        time = DateTime(int.parse(substring(6, 10)), int.parse(substring(3, 5)),
            int.parse(substring(0, 2)));
      } catch (e) {
        debugPrint("toDateTime() başarısız");
      }
    }

    return time;
  }

  String noktaDuzenle() {
    return replaceAll(regex, '')
        .replaceAll(regex2, "")
        .replaceAll(RegExp(r"(\.00$)"), "");
  }

  ///nokta dahildir
  ///

  ///harfleri ve sayilari 0. oge sayi 1. oge harfler olacak şekilde ayırır, double ise double olarak tutar
  List<String> harfSayiAyir() {
    var a = replaceAll(numregex, "").replaceAll(".", "").trim();
    var b = numregexnoktali.allMatches(this).string();

    return [b, a];
  }

  String htmlToText() {
    return replaceAll(RegExp(r"/<[^>]*>/g"), ' ')
        .replaceAll(RegExp(r"/\s{2,}/g"), ' ')
        .trim();
  }

  List<String> bosluktanAyir() {
    return split(" ");
  }

  /// DO 123456789.12345 => 123.456.789,12345                DON'T  123ABC145.55 => 123.145,55ABC
  String displayNumFormat([String label = ""]) {
    int chunkSize = 3;
    var input = toStringAsFixed(2);

    var negatif = input.contains("-");
    input = input.replaceAll("-", "");
    if (input == "0" || input.isEmpty) {
      return "0,00";
    }
    var endofThis = input.harfSayiAyir().last;
    input = input.harfSayiAyir().first;
    if (label.isNotEmpty) {
      debugPrint("Label: $label  value = $input");
      debugPrint(input.harfSayiAyir().toString());
    }
    var splitted = input.split(".");
    splitted.first = splitted.first.reverse();

    List futureSplitted = [];
    for (var i = 0; i < splitted.first.length; i += chunkSize) {
      futureSplitted.add(splitted.first.substring(
          i,
          i + chunkSize > splitted.first.length
              ? splitted.first.length
              : i + chunkSize));
    }

    String futurestr = futureSplitted.join(".");
    splitted.first = futurestr.reverse();
    splitted = splitted.length == 2 ? splitted : [splitted.first, "00"];
    var output = splitted.join(",");
    return (negatif ? "-" : "") + output + endofThis;
  }
}

var numregex = RegExp(r"[0-9]*");
var numregexnoktali = RegExp(r"[0-9.]*");
var harfregex = RegExp(r"^[a-zA-Z]*");

/// provider.of<Tip>(ContextGetir(),listen:false)'ın kısaltmaıs
T pof<T>({BuildContext? context, bool? listen}) {
  return Provider.of<T>(context ?? ContextGetir(), listen: listen ?? false);
}

extension TarihStringParse on DateTime {
  String string() {
    return "${day.toString().length == 1 ? "0$day" : day}.${month.toString().length == 1 ? "0$month" : month}.$year";
  }

  DateTime addHours(Hour time) {
    var v = add(Duration(hours: time.hour, minutes: time.minutes));
    return v;
  }

  DateTime removeHours([Hour? saat]) {
    var time = saat ?? Hour(hour: hour, minutes: minute - 1);
    var v = subtract(Duration(hours: time.hour, minutes: time.minutes));
    return v;
  }

  ///AYIN SON GÜNÜNÜ GETİRİR
  DateTime get lastDate => DateTime(year, month + 1, 0);

  bool operator >(DateTime other) => isAfter(other);
  bool operator <(DateTime other) => isBefore(other);
  bool operator >=(DateTime other) => isAfter(other) || this == other;
  bool operator <=(DateTime other) => isBefore(other) || this == other;
}

class Hour {
  int hour;
  int minutes;
  Hour({required this.hour, required this.minutes});
  @override
  String toString() {
    var hour = this.hour.toString();
    var minutes = this.minutes.toString();

    hour = hour.length == 1 ? "0" + hour : hour;
    minutes = minutes.length == 1 ? "0" + minutes : hour;

    return hour + ":" + minutes;
  }
}


List<T> evoFuzzySearch<T>(List<T> veri, List<String> arananlar, String prompt) {
  List<T> sonuc = [];
  var i = 0;
  if (prompt.length > 2) {
    arananlar.forEach((element) {
      var s1 = element.toLowerCase().turkceKarDegis();
      var s2 = prompt.toLowerCase().turkceKarDegis();
      if (s1.contains(s2)) {
        sonuc.add(veri[i]);
      }
      i += 1;
    });
  }
  return sonuc;
}
double ratioToZeroToOne(num x, num y) {
  // Eğer y sıfıra eşitse, 1 döndürür.
  if (y == 0) {
    return 1.0;
  }

  // Eğer x sıfıra eşitse, 0 döndürür.
  if (x == 0) {
    return 0.0;
  }

  // Eğer x ve y aynı işaretli değilse, 0 döndürür.
  if ((x < 0 && y > 0) || (x > 0 && y < 0)) {
    return 0.0;
  }

  // Oranı hesaplar ve 0 ile 1 arasında sınırlar.
  double ratio = x / y;
  if (ratio > 1.0) {
    ratio = 1.0;
  } else if (ratio < 0.0) {
    ratio = 0.0;
  }

  return ratio;
}







































