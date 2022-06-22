import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forex/currencies/cubit.dart';
import 'package:forex/currencies/model.dart';

class CurrenciesPage extends StatefulWidget {
  static String routeName = 'currencies';

  const CurrenciesPage({Key? key}) : super(key: key);

  @override
  State<CurrenciesPage> createState() => _CurrenciesPageState();
}

class _CurrenciesPageState extends State<CurrenciesPage> {
  final bloc = CurrenciesCubit();

  @override
  void initState() {
    super.initState();

    bloc.loadFromJson(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Currencies")),
      body: BlocBuilder<CurrenciesCubit, CurrenciesState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is UnCurrenciesState) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is ErrorCurrenciesState) {
            return Center(child: Icon(Icons.error, color: Colors.red[300]));
          }
          if (state is InCurrenciesState) {
            return ListView.builder(
              itemCount: state.currencies.length,
              itemBuilder: (context, index) =>
                  CurrencyCell(item: state.currencies[index]),
            );
          }
          return Container();
        },
      ),
    );
  }
}

class CurrencyCell extends StatelessWidget {
  const CurrencyCell({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Currency item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          width: 80,
          child: Center(
            child: Text(
              item.flag,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item.symbol} - ${item.code}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(item.name),
          ],
        ),
      ],
    );
  }
}
