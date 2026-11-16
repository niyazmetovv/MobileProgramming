import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';

final checkoutApiProvider = Provider<CheckoutApi>((ref) {
  return CheckoutApi();
});

class CartNotifier extends Notifier<CartState> {
  final List<CartState> _history = [];

  @override
  CartState build() {
    return const CartState();
  }

  bool get canUndo {
    return _history.isNotEmpty;
  }

  void _saveAndSet(CartState newState) {
    if (newState == state) {
      return;
    }
    _history.add(state);
    state = newState;
  }

  void add(Product product) {
    _saveAndSet(state.copyWith(lines: state.lines.withProduct(product)));
  }

  void remove(String productId) {
    _saveAndSet(state.copyWith(lines: state.lines.without(productId)));
  }

  void changeQty(String productId, int delta) {
    _saveAndSet(
      state.copyWith(lines: state.lines.changeQty(productId, delta)),
    );
  }

  void applyCoupon(String code) {
    final typed = code.trim().toUpperCase();

    if (typed == 'SAVE10') {
      _saveAndSet(state.copyWith(coupon: typed));
    } else {
      _saveAndSet(state.copyWith(couponError: 'Invalid coupon code'));
    }
  }

  void undo() {
    if (_history.isEmpty) {
      return;
    }
    final previous = _history.removeLast();
    state = previous.copyWith(status: CheckoutStatus.idle);
  }

  Future<void> checkout() async {
    if (state.lines.isEmpty) {
      return;
    }
    if (state.status == CheckoutStatus.submitting) {
      return;
    }

    final api = ref.read(checkoutApiProvider);
    state = state.copyWith(status: CheckoutStatus.submitting);

    try {
      final orderId = await api.submit(state.total);
      if (!ref.mounted) {
        return;
      }
      _history.clear();
      state = CartState(status: CheckoutStatus.success, orderId: orderId);
    } on CheckoutException catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: CheckoutStatus.failure,
        checkoutError: e.message,
      );
    }
  }
}

final cartProvider = NotifierProvider.autoDispose<CartNotifier, CartState>(() {
  return CartNotifier();
});

final canUndoProvider = Provider.autoDispose<bool>((ref) {
  ref.watch(cartProvider);
  final notifier = ref.read(cartProvider.notifier);
  return notifier.canUndo;
});

// Part 3 notes
// T2. without == on CartState the same coupon still notifies because copyWith makes a new object, after adding == and hashCode (Equatable) the two states are equal and nothing is notified
// T4. no mounted check because the notifier never touches the page or context, the state sits in the provider, I only check ref.mounted since my provider is autoDispose and can be disposed while checkout is waiting
// T5. after making it autoDispose and coming back to the page the cart and the history were empty, when the page is popped nobody watches the provider so Riverpod throws the notifier away and makes a new one next time
