// Package imports:
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Project imports:
import 'package:forex/forex/model.dart';

class FixerClient {
  static Future<Fixer> latest() async {
    final dio = Dio();
    dio.interceptors.add(PrettyDioLogger());

    final resp = await dio.get("https://data.fixer.io/api/latest?access_key=x");

    return Fixer.fromJson(resp.data);
  }
}
