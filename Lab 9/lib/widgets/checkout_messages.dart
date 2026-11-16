import 'package:flutter/material.dart';

import '../models/cart.dart';

void showCheckoutMessage(BuildContext context, CartState state) {
  final messenger = ScaffoldMessenger.of(context);

  if (state.status == CheckoutStatus.submitting) {
    messenger.hideCurrentMaterialBanner();
  }

  if (state.status == CheckoutStatus.success) {
    messenger.showSnackBar(
      SnackBar(content: Text('Order ${state.orderId} placed')),
    );
  }

  if (state.status == CheckoutStatus.failure) {
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text('${state.checkoutError}. Your cart was kept.'),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
