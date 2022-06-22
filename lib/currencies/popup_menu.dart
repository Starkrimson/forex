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

  const CurrencyPopupMenu({Key? key, this.onSelected, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesCubit, CurrenciesState>(
      builder: (context, state) {
        if (state is InCurrenciesState) {
          return PopupMenuButton<Currency>(
            initialValue: value,
            // icon: const Icon(Icons.add),
            child: value != null
                ? CurrencyCell(item: value!)
                : const Icon(Icons.add),
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
