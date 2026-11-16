import 'package:bloc_test/bloc_test.dart';
import 'package:cart_four_ways/bloc/cart_bloc.dart';
import 'package:cart_four_ways/bloc/cart_event.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/services/checkout_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  final keyboard = catalog.first;
  final oneKeyboard = [CartLine(product: keyboard, qty: 1)];
  final twoKeyboards = [CartLine(product: keyboard, qty: 2)];

  blocTest<CartBloc, CartState>(
    'two keyboards and SAVE10 emit three states',
    build: () {
      return CartBloc(MockCheckoutApi());
    },
    act: (bloc) {
      bloc
        ..add(CartProductAdded(keyboard))
        ..add(CartProductAdded(keyboard))
        ..add(const CartCouponApplied('SAVE10'));
    },
    expect: () {
      return [
        CartState(lines: oneKeyboard),
        CartState(lines: twoKeyboards),
        CartState(lines: twoKeyboards, coupon: 'SAVE10'),
      ];
    },
    verify: (bloc) {
      expect(bloc.state.total, closeTo(88.2, 0.001));
    },
  );

  blocTest<CartBloc, CartState>(
    'failed checkout emits submitting then failure and keeps the lines',
    build: () {
      final api = MockCheckoutApi();
      when(() => api.submit(any()))
          .thenThrow(const CheckoutException('Card declined'));
      return CartBloc(api);
    },
    act: (bloc) {
      bloc
        ..add(CartProductAdded(keyboard))
        ..add(const CartCheckoutRequested());
    },
    expect: () {
      return [
        CartState(lines: oneKeyboard),
        CartState(lines: oneKeyboard, status: CheckoutStatus.submitting),
        CartState(
          lines: oneKeyboard,
          status: CheckoutStatus.failure,
          checkoutError: 'Card declined',
        ),
      ];
    },
  );

  final slowApi = MockCheckoutApi();

  blocTest<CartBloc, CartState>(
    'two checkout events give only one submitting state',
    build: () {
      when(() => slowApi.submit(any())).thenAnswer((invocation) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 'ORD-1';
      });
      return CartBloc(slowApi);
    },
    act: (bloc) {
      bloc
        ..add(CartProductAdded(keyboard))
        ..add(const CartCheckoutRequested())
        ..add(const CartCheckoutRequested());
    },
    wait: const Duration(milliseconds: 100),
    expect: () {
      return [
        CartState(lines: oneKeyboard),
        CartState(lines: oneKeyboard, status: CheckoutStatus.submitting),
        const CartState(status: CheckoutStatus.success, orderId: 'ORD-1'),
      ];
    },
    verify: (bloc) {
      verify(() => slowApi.submit(any())).called(1);
    },
  );
}
