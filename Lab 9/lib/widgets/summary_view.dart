import 'package:flutter/material.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final int itemCount;
  final double subtotal;
  final double discount;
  final double total;

  Widget _row(String label, String value, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _row('Items', '$itemCount'),
              _row('Subtotal', subtotal.toStringAsFixed(2)),
              _row('Discount', '-${discount.toStringAsFixed(2)}'),
              const Divider(),
              _row('Total', total.toStringAsFixed(2), bold: true),
            ],
          ),
        ),
      );
}
