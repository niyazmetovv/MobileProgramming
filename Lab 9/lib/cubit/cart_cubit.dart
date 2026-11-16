import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._api) : super(const CartState());

  final CheckoutApi _api;

  List<CartState> _historyWithCurrent() {
    return [...state.history, state];
  }

  void add(Product product) {
    emit(state.copyWith(
      lines: state.lines.withProduct(product),
      history: _historyWithCurrent(),
    ));
  }

  void remove(String productId) {
    emit(state.copyWith(
      lines: state.lines.without(productId),
      history: _historyWithCurrent(),
    ));
  }

  void changeQty(String productId, int delta) {
    emit(state.copyWith(
      lines: state.lines.changeQty(productId, delta),
      history: _historyWithCurrent(),
    ));
  }

  void applyCoupon(String code) {
    final typed = code.trim().toUpperCase();

    if (typed == 'SAVE10') {
      emit(state.copyWith(
        coupon: typed,
        history: _historyWithCurrent(),
      ));
    } else {
      emit(state.copyWith(
        couponError: 'Invalid coupon code',
        history: _historyWithCurrent(),
      ));
    }
  }

  void undo() {
    if (state.history.isEmpty) {
      return;
    }
    final previous = state.history.last;
    emit(previous.copyWith(status: CheckoutStatus.idle));
  }

  Future<void> checkout() async {
    if (state.lines.isEmpty) {
      return;
    }
    if (state.status == CheckoutStatus.submitting) {
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting));

    try {
      final orderId = await _api.submit(state.total);
      if (isClosed) {
        return;
      }
      emit(CartState(status: CheckoutStatus.success, orderId: orderId));
    } on CheckoutException catch (e) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        checkoutError: e.message,
      ));
    }
  }

  @override
  void onChange(Change<CartState> change) {
    super.onChange(change);
    debugPrint('CartCubit change, new state is ${change.nextState}');
  }
}

// Part 4 notes
// T2. when I apply SAVE10 twice onChange prints only once, the second state is equal to the current one so emit just drops it
// T4. emit after close() throws a StateError (cannot emit new states after calling close), so after the await I check isClosed and return
// T5. a canUndo getter on the cubit does not rebuild the Undo button because BlocBuilder only reacts to emitted states, so I moved history into CartState and canUndo reads it from there
