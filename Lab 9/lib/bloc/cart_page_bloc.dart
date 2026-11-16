import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_summary_card.dart';
import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import '../widgets/checkout_button.dart';
import '../widgets/checkout_messages.dart';
import '../widgets/coupon_field.dart';
import 'cart_bloc.dart';
import 'cart_event.dart';

class BlocCartPage extends StatelessWidget {
  const BlocCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(CheckoutApi()),
      child: const BlocCartView(),
    );
  }
}

class BlocCartView extends StatelessWidget {
  const BlocCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CartBloc>();

    return BlocListener<CartBloc, CartState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        showCheckoutMessage(context, state);
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cart Bloc'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed: state.canUndo
                      ? () {
                          bloc.add(const CartUndone());
                        }
                      : null,
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: CartBody(
                    lines: state.lines,
                    onAdd: (product) {
                      bloc.add(CartProductAdded(product));
                    },
                    onQtyChanged: (productId, delta) {
                      bloc.add(CartQtyChanged(productId, delta));
                    },
                  ),
                ),
                CouponField(
                  errorText: state.couponError,
                  appliedCoupon: state.coupon,
                  onApply: (code) {
                    bloc.add(CartCouponApplied(code));
                  },
                ),
                const CartSummaryCard<CartBloc>(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CheckoutButton(
                    submitting: state.status == CheckoutStatus.submitting,
                    onPressed: state.lines.isEmpty
                        ? null
                        : () {
                            bloc.add(const CartCheckoutRequested());
                          },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
