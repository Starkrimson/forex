import 'package:forex/currencies/model.dart';

class Convert {
  final String uuid;
  Currency from;
  Currency? to;

  Convert(this.uuid, this.from, {this.to});
}
