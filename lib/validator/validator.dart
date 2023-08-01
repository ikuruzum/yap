import 'dart:convert';




/// check if the string matches the comparison






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


