// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc/bloc.dart';

// Project imports:
import 'package:forex/common/assets_path.dart';
import 'package:forex/currencies/model.dart';

/// ======== Currencies State ========
@immutable
abstract class CurrenciesState {}

/// UnInitialized
class UnCurrenciesState extends CurrenciesState {}

/// Initialized
class InCurrenciesState extends CurrenciesState {
  final List<Currency> currencies;

  InCurrenciesState({
    required this.currencies,
  });
}

/// Error
class ErrorCurrenciesState extends CurrenciesState {}

/// ======== Currencies Cubit ========
class CurrenciesCubit extends Cubit<CurrenciesState> {
  CurrenciesCubit() : super(UnCurrenciesState());

  loadFromJson(context) async {
    final bundle = DefaultAssetBundle.of(context);

    final content = await bundle.loadString(Assets.currencies);
    List jsonList = jsonDecode(content);
    List<Currency> currencies =
        jsonList.map((e) => Currency.fromJson(e)).toList();
    emit(InCurrenciesState(currencies: currencies));
  }
}
