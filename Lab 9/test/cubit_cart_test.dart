import 'package:bloc_test/bloc_test.dart';
import 'package:cart_four_ways/cubit/cart_cubit.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/services/checkout_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  final keyboard = catalog.first;
  final oneKeyboard = [CartLine(product: keyboard, qty: 1)];
  final twoKeyboards = [CartLine(product: keyboard, qty: 2)];

  blocTest<CartCubit, CartState>(
    'two keyboards and SAVE10 emit three states',
    build: () {
      return CartCubit(MockCheckoutApi());
    },
    act: (cubit) {
      cubit.add(keyboard);
      cubit.add(keyboard);
      cubit.applyCoupon('SAVE10');
    },
    expect: () {
      return [
        CartState(lines: oneKeyboard),
        CartState(lines: twoKeyboards),
        CartState(lines: twoKeyboards, coupon: 'SAVE10'),
      ];
    },
    verify: (cubit) {
      expect(cubit.state.total, closeTo(88.2, 0.001));
    },
  );

  blocTest<CartCubit, CartState>(
    'failed checkout emits submitting then failure and keeps the lines',
    build: () {
      final api = MockCheckoutApi();
      when(() => api.submit(any()))
          .thenThrow(const CheckoutException('Card declined'));
      return CartCubit(api);
    },
    act: (cubit) async {
      cubit.add(keyboard);
      await cubit.checkout();
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
}
