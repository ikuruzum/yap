library yap;

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yap/hext.dart';

export "deployer.dart";
export "hext.dart";
export "validator/validator.dart";

bool get importHext => true;

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
    onPicked.call(time.format(context));
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

///MODELİN KENDİSİ EKLENMELİ
mixin HMixin<MODEL> on ChangeNotifier {
  ///asırlarca düzenleyici metodlar yazmak ile uğraşmak istemiyorsan bunu kullan
  ///type.action(()async{type.a = 1;})
  FutureOr<void> action(Function() action) async {
    await action.call();
    notifyListeners();
  }

  MODEL create() => this as MODEL;
}



/// provider.of<Tip>(ContextGetir(),listen:false)'ın kısaltmaıs
T pof<T>({BuildContext? context, bool? listen}) {
  return Provider.of<T>(context ?? ContextGetir(), listen: listen ?? false);
}

List<T> fuzzySearch<T>(List<T> veri, List<String> arananlar, String prompt) {
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

extension Hvalidator on String {}
