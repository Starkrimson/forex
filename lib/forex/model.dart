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

  FixerError? error;

  Fixer({
    this.success,
    this.timestamp,
    this.base,
    this.date,
    this.rates,
    this.error,
  });

  Fixer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    timestamp = json['timestamp'];
    base = json['base'];
    date = json['date'];
    rates = json['rates'] != null ? Map<String, num>.from(json['rates']) : null;
    error = json['error'] != null ? FixerError.fromJson(json["error"]) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['timestamp'] = timestamp;
    data['base'] = base;
    data['date'] = date;
    data['rates'] = rates;
    if (error != null) {
      data['error'] = error!.toJson();
    }
    return data;
  }
}

class FixerError {
  int? code;
  String? type;
  String? info;

  FixerError({this.code, this.type, this.info});

  FixerError.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    info = json['info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['type'] = type;
    data['info'] = info;
    return data;
  }
}
