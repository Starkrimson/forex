// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:forex/common/assets_path.dart';
import 'package:forex/currencies/model.dart';
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
class ErrorForexState extends ForexState {}

/// ======== Forex Cubit ========
class ForexCubit extends Cubit<ForexState> {
  ForexCubit() : super(UnForexState());

  initial(context) async {
    final bundle = DefaultAssetBundle.of(context);
    final latestContent = await bundle.loadString(Assets.fixerLatest);
    final latest = Fixer.fromJson(jsonDecode(latestContent));

    final from = Currency(
      code: "CNY",
      symbol: "¥",
      name: "Chinese Yuan",
      flag: "🇨🇳",
      rate: latest.rates?["CNY"] ?? 0,
    );

    final to = Currency(
      code: "USD",
      symbol: "\$",
      name: "United States Dollar",
      flag: "🇺🇸",
      rate: latest.rates?["USD"] ?? 0,
    );

    emit(
      InForexState(
        [Convert(const Uuid().v1(), from, to: to)],
        latest: latest,
      ),
    );
  }

  add(Currency currency) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final latest = (state as InForexState).latest;
      currency.rate = latest?.rates?[currency.code] ?? 0;
      list = list + [Convert(const Uuid().v1(), currency)];
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

      emit(InForexState(list, latest: latest));
    }
  }

  swag(String uuid, Currency from, Currency? to) async {
    if (to == null) {
      return;
    }
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final latest = (state as InForexState).latest;
      final index = list.indexWhere((element) => element.uuid == uuid);
      if (index < 0) {
        return;
      }

      list[index].from = to;
      list[index].to = from;

      emit(InForexState(list, latest: latest));
    }
  }

  remove(String uuid) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final latest = (state as InForexState).latest;
      list.removeWhere((element) => element.uuid == uuid);
      emit(InForexState(list, latest: latest));
    }
  }
}
