import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yap/regex.dart';
import 'package:yap/yap.dart';


DateTime get now => DateTime.now();


extension Matcher on Iterable<RegExpMatch> {
  String string() {
    return map((e) => e[0]).join();
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

extension ModelParse<T> on T {
  T mnd(T? v) => v ?? this;
}

extension HextS on String {
  double get float => double.tryParse(this) ?? 0;
  int get integer => int.tryParse(this) ?? 0;

  String get htmlRemoved {
    {
      var e = replaceAll(RegExp(r'<[^>]*>'), " ");
      e = e.replaceAll("<p>", " ");
      e = e.replaceAll("</p>", " ");
      e = e.replaceAll("<div>", " ");
      e = e.replaceAll("</div>", " ");
      e = e.replaceAll("<br>", " ");
      e = e.replaceAll("</br>", " ");
      e = e.replaceAll("<span>", " ");
      e = e.replaceAll("</span>", " ");
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

  String tar() {
    return tarihDonusturucu(toString());
  }
}

extension HextSN on String? {
  String hourFormat() {
    return this ?? "00:00";
  }
}

extension HextN on num {
  String toHString() {
    var v = toString();
    if (v.length == 1) {
      return "0$v";
    } else {
      return v;
    }
  }
}
extension HextBC on BuildContext {
  T prov<T>([bool listen = false]) {
    return Provider.of<T>(this, listen: listen);
  }

  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
  double get ratio => MediaQuery.of(this).devicePixelRatio;
}

extension HextDT on DateTime {
  String get string => "$day.$month.$year";
}

extension HextTOD on TimeOfDay {
  String get string =>
      "${hour.toString().length == 1 ? "0$hour" : hour.toString()}:${minute.toString().length == 1 ? "0$minute" : minute.toString()}";
  DateTime get date => DateTime(now.year, now.month, now.day, hour, minute);
}


extension HextB on bool {
    int integer() {
    return this ? 1 : 0;
  }
    String string() {
    return this ? "1" : "0";
  }
}

extension HextL<E> on List<E>{
    List<E> sublistSafe(int start, int end) {
    if (length >= end) {
      return sublist(start, end);
    } else {
      return sublist(start, length);
    }
  }
}