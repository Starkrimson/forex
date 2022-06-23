// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:forex/currencies/popup_menu.dart';
import 'package:forex/forex/cubit.dart';
import 'package:forex/forex/model.dart';

class ForexPage extends StatelessWidget {
  static String routeName = 'forex';

  const ForexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ForexCubit, ForexState>(
        builder: (context, state) {
          if (state is UnForexState) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is ErrorForexState) {
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
          if (state is InForexState) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Text("Forex"),
                  actions: [
                    Text(
                      state.latest?.date ?? "",
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: state.latest?.success == false,
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[300]),
                        Expanded(child: Text(state.latest?.error?.info ?? "")),
                      ],
                    ),
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                        List.generate(state.convertList.length, (index) {
                  final item = state.convertList[index];
                  return ConvertCell(item: item);
                }))),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Spacer(),
                      CurrencyPopupMenu(
                        onSelected: (element) =>
                            BlocProvider.of<ForexCubit>(context).add(element),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                )
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}

class ConvertCell extends StatelessWidget {
  const ConvertCell({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Convert item;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ForexCubit>(context);
    var from = CurrencyPopupMenu(
      value: item.from,
      onSelected: (e) => bloc.update(item.uuid, from: e),
    );
    var to = CurrencyPopupMenu(
      value: item.to,
      onSelected: (to) => bloc.update(item.uuid, to: to),
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: from),
              IconButton(
                onPressed: () => bloc.swag(item.uuid, item.from, item.to),
                icon: const Icon(
                  Icons.swap_horiz,
                  color: Colors.grey,
                ),
              ),
              Expanded(child: to),
              IconButton(
                onPressed: () => bloc.remove(item.uuid),
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.red[300],
                ),
              )
            ],
          ),
          Text(
              "1${item.from.code} = ${(item.to?.rate ?? 0) / (item.from.rate ?? 0)}${item.to?.code}"),
          Text(
              "1${item.to?.code} = ${(item.from.rate ?? 0) / (item.to?.rate ?? 0)}${item.from.code}")
        ],
      ),
    );
  }
}
