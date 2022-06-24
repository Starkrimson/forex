// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:forex/currencies/cubit.dart';
import 'package:forex/currencies/model.dart';
import 'package:forex/currencies/page.dart';

class CurrencyPopupMenu extends StatelessWidget {
  final Currency? value;
  final void Function(Currency)? onSelected;
  final Widget? child;

  CurrencyPopupMenu({Key? key, this.onSelected, this.value, this.child})
      : super(key: key);

  late final _child = Builder(builder: (context) {
    if (child != null) {
      return child!;
    }
    if (value == null) {
      return const Icon(Icons.add);
    }
    return CurrencyCell(item: value!);
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesCubit, CurrenciesState>(
      builder: (context, state) {
        if (state is InCurrenciesState) {
          return PopupMenuButton<Currency>(
            tooltip: "",
            initialValue: value,
            child: _child,
            onSelected: (element) {
              onSelected?.call(element);
            },
            itemBuilder: (context) {
              return state.currencies
                  .map(
                    (e) => PopupMenuItem(
                      value: e,
                      child: CurrencyCell(item: e),
                    ),
                  )
                  .toList();
            },
          );
        }
        return Container();
      },
    );
  }
}
