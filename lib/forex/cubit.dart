// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:forex/currencies/model.dart';
import 'package:forex/forex/client.dart';
import 'package:forex/forex/database.dart';
import 'package:forex/forex/model.dart';

/// ======== Forex State ========
@immutable
abstract class ForexState {}

/// UnInitialized
class UnForexState extends ForexState {}

/// Initialized
class InForexState extends ForexState {
  final List<Convert> convertList;
  final Fixer? latest;

  InForexState(this.convertList, {this.latest});
}

/// Error
class ErrorForexState extends ForexState {
  final String error;

  ErrorForexState(this.error);
}

/// ======== Forex Cubit ========
class ForexCubit extends Cubit<ForexState> {
  final DBProvider _dbProvider = DBProvider();

  ForexCubit() : super(UnForexState());

  initial() async {
    try {
      await _dbProvider.open();
      final convertList = await _dbProvider.getConvertList();

      var latest = await _dbProvider.getLatestFixer();
      final now = DateTime.now().millisecondsSinceEpoch / 1000;

      // database 数据为空或者超过8小时，重新获取
      if (latest == null || now - (latest.timestamp ?? 0) > 60 * 60 * 8) {
        final latestAlt = await FixerClient.latest();
        if (latestAlt.success == true) {
          latest = latestAlt;
          _dbProvider.insertFixer(latest);
        }
      }
      for (var element in convertList) {
        element.from.rate = latest?.rates?[element.from.code] ?? 0;
        element.to?.rate = latest?.rates?[element.to?.code] ?? 0;
      }

      emit(InForexState(convertList, latest: latest));
    } catch (e) {
      emit(ErrorForexState(e.toString()));
    }
  }

  setAmount(String uuid, {num? from, num? to}) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final latest = (state as InForexState).latest;
      final index = list.indexWhere((element) => element.uuid == uuid);
      if (index < 0) return;

      if (from != null) {
        list[index].amount = from;
      } else if (to != null) {
        final convert = list[index];
        list[index].amount = to * (convert.to?.rateOther(convert.from) ?? 0);
      }

      _dbProvider.updateConvert(list[index]);
      emit(InForexState(list, latest: latest));
    }
  }

  add(Currency currency) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final latest = (state as InForexState).latest;
      currency.rate = latest?.rates?[currency.code] ?? 0;
      final convert = Convert(const Uuid().v1(), currency);
      list = list + [convert];
      _dbProvider.insertConvert(convert);
      emit(InForexState(list, latest: latest));
    }
  }

  update(String uuid, {Currency? from, Currency? to}) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final latest = (state as InForexState).latest;
      final index = list.indexWhere((element) => element.uuid == uuid);
      if (index < 0) {
        return;
      }

      if (from != null) {
        from.rate = latest?.rates?[from.code] ?? 0;
        list[index].from = from;
      }

      if (to != null) {
        to.rate = latest?.rates?[to.code] ?? 0;
        list[index].to = to;
      }

      _dbProvider.updateConvert(list[index]);
      emit(InForexState(list, latest: latest));
    }
  }

  swag(String uuid, Currency from, Currency? to) async {
    if (to == null) return;
    update(uuid, from: to, to: from);
  }

  remove(String uuid) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final latest = (state as InForexState).latest;
      list.removeWhere((element) => element.uuid == uuid);
      _dbProvider.deleteConvert(uuid);
      emit(InForexState(list, latest: latest));
    }
  }
}
