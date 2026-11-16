import 'package:flutter/material.dart';

class CouponField extends StatefulWidget {
  const CouponField({
    super.key,
    required this.onApply,
    this.errorText,
    this.appliedCoupon,
  });

  final void Function(String code) onApply;
  final String? errorText;
  final String? appliedCoupon;

  @override
  State<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Coupon code',
                  errorText: widget.errorText,
                  helperText: widget.appliedCoupon == null
                      ? null
                      : '${widget.appliedCoupon} applied, 10% off',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.tonal(
                onPressed: () => widget.onApply(_controller.text),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      );
}
