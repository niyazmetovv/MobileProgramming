import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../widgets/cart_body.dart';
import '../widgets/checkout_button.dart';
import '../widgets/checkout_messages.dart';
import '../widgets/coupon_field.dart';
import '../widgets/summary_view.dart';
import 'cart_notifier.dart';

class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final canUndo = ref.watch(canUndoProvider);
    final notifier = ref.read(cartProvider.notifier);

    ref.listen(cartProvider, (previous, next) {
      debugPrint('Riverpod cart state changed');
    });

    ref.listen(cartProvider.select((s) => s.status), (previous, next) {
      showCheckoutMessage(context, ref.read(cartProvider));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Riverpod'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: canUndo ? notifier.undo : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CartBody(
              lines: cart.lines,
              onAdd: notifier.add,
              onQtyChanged: notifier.changeQty,
            ),
          ),
          CouponField(
            errorText: cart.couponError,
            appliedCoupon: cart.coupon,
            onApply: notifier.applyCoupon,
          ),
          const RiverpodSummaryCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: CheckoutButton(
              submitting: cart.status == CheckoutStatus.submitting,
              onPressed: cart.lines.isEmpty ? null : notifier.checkout,
            ),
          ),
        ],
      ),
    );
  }
}

class RiverpodSummaryCard extends ConsumerWidget {
  const RiverpodSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartProvider.select((s) => s.itemCount));
    final subtotal = ref.watch(cartProvider.select((s) => s.subtotal));
    final discount = ref.watch(cartProvider.select((s) => s.discount));
    final total = ref.watch(cartProvider.select((s) => s.total));

    debugPrint('Riverpod summary card rebuilt');

    return SummaryView(
      itemCount: itemCount,
      subtotal: subtotal,
      discount: discount,
      total: total,
    );
  }
}

// Part 3 notes
// 1. ref.read is in the page to get the notifier for the buttons, in the ref.listen callback to get the order id or error, and in checkout() to get the api, they all need the value once and should not rebuild anything, ref.watch is in the page and in the summary card because they show data and have to rebuild when it changes (canUndoProvider also watches the cart and reads the notifier)
// 2. in setState the whole page rebuilds on every change, here the summary card watches only its own numbers with select so a coupon error or checkout status does not rebuild it
