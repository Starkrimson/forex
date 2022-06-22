import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:forex/currencies/model.dart';
import 'package:forex/forex/model.dart';
import 'package:uuid/uuid.dart';

/// ======== Forex State ========
@immutable
abstract class ForexState {}

/// UnInitialized
class UnForexState extends ForexState {}

/// Initialized
class InForexState extends ForexState {
  final List<Convert> convertList;

  InForexState(this.convertList);
}

/// Error
class ErrorForexState extends ForexState {}

/// ======== Forex Cubit ========
class ForexCubit extends Cubit<ForexState> {
  ForexCubit() : super(UnForexState());

  initial() async {
    emit(InForexState([
      Convert(
        const Uuid().v1(),
        Currency(
          code: "CNY",
          symbol: "¥",
          name: "Chinese Yuan",
          flag: "🇨🇳",
        ),
        to: Currency(
          code: "USD",
          symbol: "\$",
          name: "United States Dollar",
          flag: "🇺🇸",
        ),
      )
    ]));
  }

  add(Currency currency) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      list = list + [Convert(const Uuid().v1(), currency)];
      emit(InForexState(list));
    }
  }

  update(String uuid, {Currency? from, Currency? to}) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      final index = list.indexWhere((element) => element.uuid == uuid);
      if (index < 0) {
        return;
      }

      if (from != null) {
        list[index].from = from;
      }

      if (to != null) {
        list[index].to = to;
      }

      emit(InForexState(list));
    }
  }

  remove(String uuid) async {
    if (state is InForexState) {
      var list = (state as InForexState).convertList;
      list.removeWhere((element) => element.uuid == uuid);
      emit(InForexState(list));
    }
  }
}
