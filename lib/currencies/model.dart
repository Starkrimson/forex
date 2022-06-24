class Currency {
  late String code;
  late String symbol;
  late String name;
  late String flag;

  num? rate;

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    this.rate,
  });

  num rateOther(Currency? other) {
    return (other?.rate ?? 0) / (rate ?? 0);
  }

  Currency.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? "";
    symbol = json['symbol'] ?? "";
    name = json['name'] ?? "";
    flag = json["flag"] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['symbol'] = symbol;
    data['name'] = name;
    data['flag'] = flag;
    return data;
  }
}
