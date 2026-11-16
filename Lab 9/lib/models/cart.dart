import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}

const catalog = [
  Product(id: 'p1', name: 'Keyboard', price: 49),
  Product(id: 'p2', name: 'Mouse', price: 25),
  Product(id: 'p3', name: 'Monitor', price: 199),
];

class CartLine extends Equatable {
  const CartLine({required this.product, required this.qty});

  final Product product;
  final int qty;

  double get subtotal => product.price * qty;

  CartLine copyWith({int? qty}) => CartLine(product: product, qty: qty ?? this.qty);

  @override
  List<Object?> get props => [product, qty];
}

extension CartLines on List<CartLine> {
  List<CartLine> withProduct(Product p) {
    final i = indexWhere((l) => l.product.id == p.id);
    if (i == -1) return [...this, CartLine(product: p, qty: 1)];
    return [
      for (final l in this)
        l.product.id == p.id ? l.copyWith(qty: l.qty + 1) : l,
    ];
  }

  List<CartLine> without(String productId) => [
        for (final l in this)
          if (l.product.id != productId) l,
      ];

  List<CartLine> changeQty(String productId, int delta) => [
        for (final l in this)
          if (l.product.id != productId)
            l
          else if (l.qty + delta > 0)
            l.copyWith(qty: l.qty + delta),
      ];

  double get subtotal => fold(0, (s, l) => s + l.subtotal);

  int get itemCount => fold(0, (s, l) => s + l.qty);
}

enum CheckoutStatus { idle, submitting, success, failure }

class CartState extends Equatable {
  const CartState({
    this.lines = const [],
    this.coupon,
    this.couponError,
    this.status = CheckoutStatus.idle,
    this.orderId,
    this.checkoutError,
    this.history = const [],
  });

  final List<CartLine> lines;
  final String? coupon;
  final String? couponError;
  final CheckoutStatus status;
  final String? orderId;
  final String? checkoutError;
  final List<CartState> history;

  int get itemCount => lines.itemCount;
  double get subtotal => lines.subtotal;
  double get discount => coupon == 'SAVE10' ? subtotal * 0.1 : 0;
  double get total => subtotal - discount;
  bool get canUndo => history.isNotEmpty;

  CartState copyWith({
    List<CartLine>? lines,
    String? coupon,
    String? couponError,
    CheckoutStatus? status,
    String? orderId,
    String? checkoutError,
    List<CartState>? history,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      coupon: coupon ?? this.coupon,
      couponError: couponError,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      checkoutError: checkoutError,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        lines,
        coupon,
        couponError,
        status,
        orderId,
        checkoutError,
      ];
}

// Part 1 notes
// 1. CartLine is immutable so every change gives a new object and Riverpod, Cubit and Bloc can notice it, with a mutable qty only setState would still work and that is the trap because the same code would stop updating the screen in the other three
// T3. total is a getter because if I stored it I would have to update it after every change, and if I forget once the screen shows a wrong total
