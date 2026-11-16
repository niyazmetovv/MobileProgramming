import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../widgets/summary_view.dart';

class CartSummaryCard<B extends BlocBase<CartState>> extends StatelessWidget {
  const CartSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, CartState>(
      buildWhen: (previous, current) {
        return previous.total != current.total;
      },
      builder: (context, state) {
        debugPrint('$B summary card rebuilt');
        return SummaryView(
          itemCount: state.itemCount,
          subtotal: state.subtotal,
          discount: state.discount,
          total: state.total,
        );
      },
    );
  }
}
