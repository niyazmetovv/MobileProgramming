import 'package:flutter_test/flutter_test.dart';
import 'package:tm_classifier/services/classifier.dart';

void main() {
  test('parseLabels handles standard format', () {
    const raw = '0 One Finger\n1 Two Fingers\n';
    final result = parseLabels(raw);
    expect(result, ['One Finger', 'Two Fingers']);
  });

  test('parseLabels handles Windows line endings, trailing blanks, and spaces in labels', () {
    const raw = '0 One Finger\r\n1 Two Fingers\r\n2 Three Fingers\r\n\r\n';
    final result = parseLabels(raw);
    expect(result, ['One Finger', 'Two Fingers', 'Three Fingers']);
  });
}
