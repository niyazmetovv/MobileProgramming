import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._api) : super(const CartState()) {
    on<CartProductAdded>(_onProductAdded);
    on<CartProductRemoved>(_onProductRemoved);
    on<CartQtyChanged>(_onQtyChanged);
    on<CartCouponApplied>(_onCouponApplied);
    on<CartCheckoutRequested>(_onCheckoutRequested, transformer: droppable());
    on<CartUndone>(_onUndone);
  }

  final CheckoutApi _api;

  List<CartState> _historyAfter(CartEvent event) {
    switch (event) {
      case CartProductAdded():
      case CartProductRemoved():
      case CartQtyChanged():
      case CartCouponApplied():
        return [...state.history, state];
      case CartCheckoutRequested():
      case CartUndone():
        return state.history;
    }
  }

  void _onProductAdded(CartProductAdded event, Emitter<CartState> emit) {
    emit(state.copyWith(
      lines: state.lines.withProduct(event.product),
      history: _historyAfter(event),
    ));
  }

  void _onProductRemoved(CartProductRemoved event, Emitter<CartState> emit) {
    emit(state.copyWith(
      lines: state.lines.without(event.productId),
      history: _historyAfter(event),
    ));
  }

  void _onQtyChanged(CartQtyChanged event, Emitter<CartState> emit) {
    emit(state.copyWith(
      lines: state.lines.changeQty(event.productId, event.delta),
      history: _historyAfter(event),
    ));
  }

  void _onCouponApplied(CartCouponApplied event, Emitter<CartState> emit) {
    final typed = event.code.trim().toUpperCase();

    if (typed == 'SAVE10') {
      emit(state.copyWith(
        coupon: typed,
        history: _historyAfter(event),
      ));
    } else {
      emit(state.copyWith(
        couponError: 'Invalid coupon code',
        history: _historyAfter(event),
      ));
    }
  }

  void _onUndone(CartUndone event, Emitter<CartState> emit) {
    if (state.history.isEmpty) {
      return;
    }
    final previous = state.history.last;
    emit(previous.copyWith(status: CheckoutStatus.idle));
  }

  Future<void> _onCheckoutRequested(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    if (state.lines.isEmpty) {
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting));

    try {
      final orderId = await _api.submit(state.total);
      if (emit.isDone) {
        return;
      }
      emit(CartState(status: CheckoutStatus.success, orderId: orderId));
    } on CheckoutException catch (e) {
      if (emit.isDone) {
        return;
      }
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        checkoutError: e.message,
      ));
    }
  }
}

// Part 5 notes
// T2. the cubit log shows only the old state and the new state, the bloc transition log also shows which event caused it
// T4. with droppable() the first tap starts checkout and the other two are ignored while it is running so the api is called once, in the cubit every tap would call checkout() and I have to stop it myself with an if on the status
// T5. only add, remove, qty change and coupon go to history because they change the cart, checkout and undo itself are not saved, the switch in _historyAfter decides this
// 1. events are worth it when I need to control or log what happens, checkout is better in Bloc because droppable() is one word and I see every step in the log, but for add and qty change it is just extra code (an event class and a handler for one line)
// 2. only Bloc can do it declaratively with droppable(), in setState, Riverpod and Cubit I do it by hand with if status is submitting return, or by disabling the button
