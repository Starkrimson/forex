// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:forex/currencies/model.dart';
import 'package:forex/currencies/popup_menu.dart';
import 'package:forex/forex/amount_dialog.dart';
import 'package:forex/forex/cubit.dart';
import 'package:forex/forex/model.dart';

class ForexPage extends StatelessWidget {
  static String routeName = 'forex';

  const ForexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff202124),
      body: BlocBuilder<ForexCubit, ForexState>(
        builder: (context, state) {
          if (state is UnForexState) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is ErrorForexState) {
            return _ErrorForex(state);
          }
          if (state is InForexState) {
            return _InForex(state);
          }
          return Container();
        },
      ),
    );
  }
}

class _ErrorForex extends StatelessWidget {
  const _ErrorForex(
    this.state, {
    Key? key,
  }) : super(key: key);

  final ErrorForexState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          state.error,
          textAlign: TextAlign.center,
        ),
        Icon(Icons.error, color: Colors.red[300]),
      ],
    );
  }
}

class _InForex extends StatelessWidget {
  const _InForex(
    this.state, {
    Key? key,
  }) : super(key: key);

  final InForexState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _LatestDate(state: state),
        _LatestError(state: state),
        SliverList(
          delegate: SliverChildListDelegate(
            List.generate(state.convertList.length, (index) {
              final item = state.convertList[index];
              return ConvertCell(item: item);
            }),
          ),
        ),
        const _NewConvert()
      ],
    );
  }
}

class _NewConvert extends StatelessWidget {
  const _NewConvert({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CurrencyPopupMenu(
        onSelected: (element) =>
            BlocProvider.of<ForexCubit>(context).add(element),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: _BorderContainer(child: Icon(Icons.add)),
        ),
      ),
    );
  }
}

class _LatestError extends StatelessWidget {
  const _LatestError({
    Key? key,
    required this.state,
  }) : super(key: key);

  final InForexState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: state.latest?.success == false,
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[300]),
            Expanded(child: Text(state.latest?.error?.info ?? "")),
          ],
        ),
      ),
    );
  }
}

class _LatestDate extends StatelessWidget {
  const _LatestDate({
    Key? key,
    required this.state,
  }) : super(key: key);

  final InForexState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              state.latest?.date ?? "",
              style: const TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

class ConvertCell extends StatelessWidget {
  ConvertCell({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Convert item;

  late final one = Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "1 ${item.from.code} =",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xff9aa0a6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${item.from.rateOther(item.to).toStringAsFixed(2)} ${item.to?.code ?? ""}",
            style: const TextStyle(
              fontSize: 36,
              color: Color(0xffe8eaed),
            ),
          ),
        ],
      ),
      const Spacer(),
      _RemoveCurrencyButton(item: item),
    ],
  );

  late final fromAmount = Builder(
    builder: (context) {
      return _CurrencyAmount(
        amount: item.amount,
        onChange: (amount) {
          BlocProvider.of<ForexCubit>(context)
              .setAmount(item.uuid, from: amount);
        },
      );
    },
  );

  late final toAmount = Builder(
    builder: (context) => _CurrencyAmount(
      amount: item.toAmount(),
      onChange: (amount) {
        BlocProvider.of<ForexCubit>(context).setAmount(item.uuid, to: amount);
      },
    ),
  );

  late final fromCode = Builder(
    builder: (context) => CurrencyPopupMenu(
      onSelected: (e) =>
          BlocProvider.of<ForexCubit>(context).update(item.uuid, from: e),
      value: item.from,
      child: _CurrencyName(currency: item.from),
    ),
  );

  late final toCode = Builder(
    builder: (context) => CurrencyPopupMenu(
      onSelected: (e) =>
          BlocProvider.of<ForexCubit>(context).update(item.uuid, to: e),
      value: item.to,
      child: item.to == null
          ? const _BorderContainer(child: Icon(Icons.add))
          : _CurrencyName(currency: item.to),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          one,
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: fromAmount),
              const SizedBox(width: 10),
              Expanded(child: fromCode),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: toAmount),
              const SizedBox(width: 10),
              Expanded(child: toCode),
            ],
          ),
        ],
      ),
    );
  }
}

class _RemoveCurrencyButton extends StatelessWidget {
  const _RemoveCurrencyButton({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Convert item;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      initialValue: false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.remove_circle,
          color: Colors.red[300],
        ),
      ),
      onSelected: (_) {
        BlocProvider.of<ForexCubit>(context).remove(item.uuid);
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
              value: true, child: Center(child: Icon(Icons.delete))),
        ];
      },
    );
  }
}

class _CurrencyAmount extends StatelessWidget {
  const _CurrencyAmount({
    Key? key,
    required this.amount,
    required this.onChange,
  }) : super(key: key);

  final num? amount;
  final Function(double) onChange;

  @override
  Widget build(BuildContext context) {
    return _BorderContainer(
      child: Row(
        children: [
          const SizedBox(width: 30),
          Expanded(
            child: Text(
              amount?.toStringAsFixed(2) ?? "0",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff9aa0a6),
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final text = await showDialog(
                context: context,
                builder: (context) {
                  // return EditAmountDialog(amount: amount ?? 0);
                  return AmountDialog(amount ?? 0);
                },
              );
              onChange(double.parse(text));
              // final a = double.parse(text);
              // BlocProvider.of<ForexCubit>(context).setAmount("uuid", a);
            },
            icon: const Icon(Icons.edit, size: 16),
          )
        ],
      ),
    );
  }
}

class _CurrencyName extends StatelessWidget {
  const _CurrencyName({
    Key? key,
    required this.currency,
  }) : super(key: key);

  final Currency? currency;

  @override
  Widget build(BuildContext context) {
    return _BorderContainer(
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${currency?.flag} ${currency?.name}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff9aa0a6),
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

class _BorderContainer extends StatelessWidget {
  final Widget child;

  const _BorderContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff5f6368)),
        borderRadius: BorderRadius.circular(6),
      ),
      height: 36,
      child: child,
    );
  }
}
