// Project imports:
import 'package:forex/currencies/model.dart';

class Convert {
  final String uuid;
  Currency from;
  Currency? to;

  Convert(this.uuid, this.from, {this.to});
}

class Fixer {
  bool? success;
  int? timestamp;
  String? base;
  String? date;
  Map<String, num>? rates;

  Fixer({this.success, this.timestamp, this.base, this.date, this.rates});

  Fixer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    timestamp = json['timestamp'];
    base = json['base'];
    date = json['date'];
    rates = Map<String, num>.from(json['rates']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['timestamp'] = timestamp;
    data['base'] = base;
    data['date'] = date;
    data['rates'] = rates;
    return data;
  }
}
