// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountDialog extends Dialog {
  final num amount;

  AmountDialog(this.amount, {Key? key}) : super(key: key);

  late final TextEditingController controller = TextEditingController()
    ..text = amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 150,
        color: const Color(0xff202124),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              textAlign: TextAlign.center,
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter(
                  RegExp(r'^\d+\.?\d{0,6}'),
                  allow: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.maybePop(context, controller.text);
              },
              child: const Text("确认"),
            ),
          ],
        ),
      ),
    );
  }
}
