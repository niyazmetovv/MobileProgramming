import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import '../widgets/checkout_button.dart';
import '../widgets/checkout_messages.dart';
import '../widgets/coupon_field.dart';
import 'cart_cubit.dart';
import 'cart_summary_card.dart';

class CubitCartPage extends StatelessWidget {
  const CubitCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit(CheckoutApi()),
      child: const CubitCartView(),
    );
  }
}

class CubitCartView extends StatelessWidget {
  const CubitCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return BlocListener<CartCubit, CartState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        showCheckoutMessage(context, state);
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cart Cubit'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed: state.canUndo ? cubit.undo : null,
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: CartBody(
                    lines: state.lines,
                    onAdd: cubit.add,
                    onQtyChanged: cubit.changeQty,
                  ),
                ),
                CouponField(
                  errorText: state.couponError,
                  appliedCoupon: state.coupon,
                  onApply: cubit.applyCoupon,
                ),
                const CartSummaryCard<CartCubit>(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CheckoutButton(
                    submitting: state.status == CheckoutStatus.submitting,
                    onPressed: state.lines.isEmpty ? null : cubit.checkout,
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

// Part 4 notes
// 1. if BlocProvider was inside CartBody then the AppBar, coupon field and summary card would be above it and context.read<CartCubit>() would not find the cubit there, also CartBody could not be shared with the other pages anymore
// 2. BlocProvider is like ProviderScope plus the provider itself, BlocBuilder is ref.watch, BlocListener is ref.listen, context.read is ref.read and buildWhen is select
