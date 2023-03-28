import 'dart:convert';

import 'helpers.dart';

Map<String, Object> _defaultNormalizeEmailOptions = {'lowercase': true};
RegExp _email = RegExp(
    r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

RegExp _ipv4Maybe = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
RegExp _ipv6 =
    RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

RegExp _surrogatePairsRegExp = RegExp(r'[\uD800-\uDBFF][\uDC00-\uDFFF]');

RegExp _alpha = RegExp(r'^[a-zA-Z]+$');
RegExp _alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
RegExp _numeric = RegExp(r'^-?[0-9]+$');
RegExp _int = RegExp(r'^(?:-?(?:0|[1-9][0-9]*))$');
RegExp _float =
    RegExp(r'^(?:-?(?:[0-9]+))?(?:\.[0-9]*)?(?:[eE][\+\-]?(?:[0-9]+))?$');
RegExp _hexadecimal = RegExp(r'^[0-9a-fA-F]+$');
RegExp _hexColor = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

RegExp _base64 = RegExp(
    r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

RegExp _creditCard = RegExp(
    r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$');

RegExp _isbn10Maybe = RegExp(r'^(?:[0-9]{9}X|[0-9]{10})$');
RegExp _isbn13Maybe = RegExp(r'^(?:[0-9]{13})$');

Map<String, RegExp> _uuid = {
  '3': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$'),
  '4': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
  '5': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
  'all':
      RegExp(r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$')
};

RegExp _multibyte = RegExp(r'[^\x00-\x7F]');
RegExp _ascii = RegExp(r'^[\x00-\x7F]+$');
RegExp _fullWidth =
    RegExp(r'[^\u0020-\u007E\uFF61-\uFF9F\uFFA0-\uFFDC\uFFE8-\uFFEE0-9a-zA-Z]');
RegExp _halfWidth =
    RegExp(r'[\u0020-\u007E\uFF61-\uFF9F\uFFA0-\uFFDC\uFFE8-\uFFEE0-9a-zA-Z]');

/// check if the string matches the comparison

extension Hvalidator on String {

  /// check if the string is an email
  bool get isEmail {
    return _email.hasMatch(toLowerCase());
  }

  String normalizeEmail([Map<String, Object>? options]) {
    options = merge(options, _defaultNormalizeEmailOptions);
    if (isEmail == false) {
      return '';
    }

    List parts = split('@');
    parts[1] = parts[1].toLowerCase();

    if (options['lowercase'] == true) {
      parts[0] = parts[0].toLowerCase();
    }

    if (parts[1] == 'gmail.com' || parts[1] == 'googlemail.com') {
      if (options['lowercase'] == false) {
        parts[0] = parts[0].toLowerCase();
      }
      parts[0] = parts[0].replaceAll('.', '').split('+')[0];
      parts[1] = 'gmail.com';
    }
    return parts.join('@');
  }

  /// check if the string is a URL
  ///
  /// `options` is a `Map` which defaults to
  /// `{ 'protocols': ['http','https','ftp'], 'require_tld': true,
  /// 'require_protocol': false, 'allow_underscores': false }`.

  /// check if the string is an IP (version 4 or 6)
  ///
  /// `version` is a String or an `int`.
  bool isIP([Object? version]) {
    assert(version == null || version is String || version is int);
    version = version.toString();
    if (version == 'null') {
      return isIP(4) || isIP(6);
    } else if (version == '4') {
      if (!_ipv4Maybe.hasMatch(this)) {
        return false;
      }
      var parts = split('.');
      parts.sort((a, b) => int.parse(a) - int.parse(b));
      return int.parse(parts[3]) <= 255;
    }
    return version == '6' && _ipv6.hasMatch(this);
  }

  /// check if the string is a fully qualified domain name (e.g. domain.com).
  ///
  /// `options` is a `Map` which defaults to `{ 'require_tld': true, 'allow_underscores': false }`.
  bool isFQDN([Map<String, Object>? options]) {
    final defaultFqdnOptions = {
      'require_tld': true,
      'allow_underscores': false
    };

    options = merge(options, defaultFqdnOptions);
    final parts = split('.');
    if (options['require_tld'] as bool) {
      var tld = parts.removeLast();
      if (parts.isEmpty || !RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
        return false;
      }
    }

    for (final part in parts) {
      if (options['allow_underscores'] as bool) {
        if (part.contains('__')) {
          return false;
        }
      }
      if (!RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
        return false;
      }
      if (part[0] == '-' ||
          part[part.length - 1] == '-' ||
          part.contains('---')) {
        return false;
      }
    }
    return true;
  }

  /// check if the string contains only letters (a-zA-Z).
  bool get isAlpha {
    return _alpha.hasMatch(this);
  }

  /// check if the string contains only numbers
  bool get isNumeric {
    return _numeric.hasMatch(this);
  }

  /// check if the string contains only letters and numbers
  bool get isAlphanumeric {
    return _alphanumeric.hasMatch(this);
  }

  /// check if a string is base64 encoded
  bool get isBase64 {
    return _base64.hasMatch(this);
  }

  /// check if the string is an integer
  bool get isInt {
    return _int.hasMatch(this);
  }

  /// check if the string is a float
  bool get isFloat {
    return _float.hasMatch(this);
  }

  /// check if the string is a hexadecimal number
  bool get isHexadecimal {
    return _hexadecimal.hasMatch(this);
  }

  /// check if the string is a hexadecimal color
  bool get isHexColor {
    return _hexColor.hasMatch(this);
  }

  /// check if the string is lowercase
  bool get isLowercase {
    return this == toLowerCase();
  }

  /// check if the string is uppercase
  bool get isUppercase {
    return this == toUpperCase();
  }

  /// check if the string is a number that's divisible by another
  ///
  /// [n] is a String or an int.


  /// check if the string's length falls in a range
  /// If no max is given then any length above min is ok.
  ///
  /// Note: this function takes into account surrogate pairs.
  bool isLength(int min, [int? max]) {
    List surrogatePairs = _surrogatePairsRegExp.allMatches(this).toList();
    int len = length - surrogatePairs.length;
    return len >= min && (max == null || len <= max);
  }

  /// check if the string's length (in bytes) falls in a range.
  bool isByteLength(int min, [int? max]) {
    return length >= min && (max == null || length <= max);
  }

  /// check if the string is a UUID (version 3, 4 or 5).
  bool isUUID([Object? version]) {
    if (version == null) {
      version = 'all';
    } else {
      version = version.toString();
    }

    RegExp? pat = _uuid[version];
    return (pat != null && pat.hasMatch(toUpperCase()));
  }

  /// check if the string is a date
  bool get isDate {
    return DateTime.tryParse(this) != null;
  }

  /// check if the string is a date that's after the specified date
  ///
  /// If `date` is not passed, it defaults to now.

  /// check if the string is a date that's before the specified date
  ///
  /// If `date` is not passed, it defaults to now.

  /// check if the string is in an array of allowed values
  bool isIn(Object? values) {
    if (values == null) return false;
    if (values is String) {
      return values.contains(this);
    }
    if (values is! Iterable) return false;
    for (Object? value in values) {
      if (value.toString() == this) return true;
    }
    return false;
  }

  /// check if the string is a credit card
  bool isCreditCard() {
    String sanitized = replaceAll(RegExp(r'[^0-9]+'), '');
    if (!_creditCard.hasMatch(sanitized)) {
      return false;
    }

    // Luhn algorithm
    int sum = 0;
    String digit;
    bool shouldDouble = false;

    for (int i = sanitized.length - 1; i >= 0; i--) {
      digit = sanitized.substring(i, (i + 1));
      int tmpNum = int.parse(digit);

      if (shouldDouble == true) {
        tmpNum *= 2;
        if (tmpNum >= 10) {
          sum += ((tmpNum % 10) + 1);
        } else {
          sum += tmpNum;
        }
      } else {
        sum += tmpNum;
      }
      shouldDouble = !shouldDouble;
    }

    return (sum % 10 == 0);
  }

  /// check if the string is an ISBN (version 10 or 13)
  bool isISBN([Object? version]) {
    if (version == null) {
      return isISBN('10') || isISBN('13');
    }

    version = version.toString();

    String sanitized = replaceAll(RegExp(r'[\s-]+'), '');
    int checksum = 0;

    if (version == '10') {
      if (!_isbn10Maybe.hasMatch(sanitized)) {
        return false;
      }
      for (int i = 0; i < 9; i++) {
        checksum += (i + 1) * int.parse(sanitized[i]);
      }
      if (sanitized[9] == 'X') {
        checksum += 10 * 10;
      } else {
        checksum += 10 * int.parse(sanitized[9]);
      }
      return (checksum % 11 == 0);
    } else if (version == '13') {
      if (!_isbn13Maybe.hasMatch(sanitized)) {
        return false;
      }
      var factor = [1, 3];
      for (int i = 0; i < 12; i++) {
        checksum += factor[i % 2] * int.parse(sanitized[i]);
      }
      return (int.parse(sanitized[12]) - ((10 - (checksum % 10)) % 10) == 0);
    }

    return false;
  }

  /// check if the string is valid JSON
  bool isJson() {
    try {
      json.decode(this);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// check if the string contains one or more multibyte chars
  bool isMultibyte() {
    return _multibyte.hasMatch(this);
  }

  /// check if the string contains ASCII chars only
  bool isAscii() {
    return _ascii.hasMatch(this);
  }

  /// check if the string contains any full-width chars
  bool isFullWidth() {
    return _fullWidth.hasMatch(this);
  }

  /// check if the string contains any half-width chars
  bool isHalfWidth() {
    return _halfWidth.hasMatch(this);
  }

  /// check if the string contains a mixture of full and half-width chars
  bool isVariableWidth() {
    return isFullWidth() && isHalfWidth();
  }

  /// check if the string contains any surrogate pairs chars
  bool isSurrogatePair() {
    return _surrogatePairsRegExp.hasMatch(this);
  }

  /// check if the string is a valid hex-encoded representation of a MongoDB ObjectId
  bool isMongoId() {
    return (isHexadecimal && length == 24);
  }
}

extension HvalidatorSN on String? {
  bool get isBefore {
    DateTime referenceDate;
    if (this == null) {
      referenceDate = DateTime.now();
    } else if (this!.isDate) {
      referenceDate = DateTime.parse(this!);
    } else {
      return false;
    }

    final strDate = DateTime.tryParse(this!);
    if (strDate == null) return false;

    return strDate.isBefore(referenceDate);
  }

  bool get isAfter {
    DateTime referenceDate;
    if (this == null) {
      referenceDate = DateTime.now();
    } else if (this!.isDate) {
      referenceDate = DateTime.parse(this!);
    } else {
      return false;
    }

    final strDate = DateTime.tryParse(this!);
    if (strDate == null) return false;

    return strDate.isAfter(referenceDate);
  }

  bool isURL([Map<String, Object>? options]) {
    var str = this;
    if (str == null ||
        str.isEmpty ||
        str.length > 2083 ||
        str.indexOf('mailto:') == 0) {
      return false;
    }

    final defaultUrlOptions = {
      'protocols': ['http', 'https', 'ftp'],
      'require_tld': true,
      'require_protocol': false,
      'allow_underscores': false,
    };

    options = merge(options, defaultUrlOptions);

    // String? protocol;
    // String user;
    // String pass;
    // // String auth;
    // String host;
    // String hostname;
    // String port;
    // String portStr;
    // String path;
    // String query;
    // String hash;
    // List<String> split;

    // check protocol
    var split = str.split('://');
    if (split.length > 1) {
      final protocol = shift(split);
      final protocols = options['protocols'] as List<String>;
      if (!protocols.contains(protocol)) {
        return false;
      }
    } else if (options['require_protocol'] == true) {
      return false;
    }
    str = split.join('://');

    // check hash
    split = str.split('#');
    str = shift(split);
    final hash = split.join('#');
    if (hash.isNotEmpty && RegExp(r'\s').hasMatch(hash)) {
      return false;
    }

    // check query params
    split = str?.split('?') ?? [];
    str = shift(split);
    final query = split.join('?');
    if (query != "" && RegExp(r'\s').hasMatch(query)) {
      return false;
    }

    // check path
    split = str?.split('/') ?? [];
    str = shift(split);
    final path = split.join('/');
    if (path != "" && RegExp(r'\s').hasMatch(path)) {
      return false;
    }

    // check auth type urls
    split = str?.split('@') ?? [];
    if (split.length > 1) {
      final auth = shift(split);
      if (auth != null && auth.contains(':')) {
        // final auth = auth.split(':');
        final parts = auth.split(':');
        final user = shift(parts);
        if (user == null || !RegExp(r'^\S+$').hasMatch(user)) {
          return false;
        }
        final pass = parts.join(':');
        if (!RegExp(r'^\S*$').hasMatch(pass)) {
          return false;
        }
      }
    }

    // check hostname
    final hostname = split.join('@');
    split = hostname.split(':');
    final host = shift(split);
    if (split.isNotEmpty) {
      final portStr = split.join(':');
      final port = int.tryParse(portStr, radix: 10);
      if (!RegExp(r'^[0-9]+$').hasMatch(portStr) ||
          port == null ||
          port <= 0 ||
          port > 65535) {
        return false;
      }
    }

    if (host == null) {
      return false;
    } else if (str!.isIP() && str.isFQDN(options) && host != 'localhost') {
      return false;
    }

    return true;
  }
}



extension Objext on Object{
    bool get isDivisibleBy {
    assert(this is String || this is int);
    final int? number;
    if (this is int) {
      number = this as int;
    } else if (this is String) {
      number = int.tryParse(this as String);
    } else {
      return false;
    }
    if (number == null) return false;
    try {
      return double.parse(toString()) % number == 0;
    } catch (e) {
      return false;
    }
  }
}