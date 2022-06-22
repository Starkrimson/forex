class Currency {
  late String code;
  late String symbol;
  late String name;
  late String flag;

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

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
