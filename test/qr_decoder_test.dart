import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qr2link/services/qr_decoder.dart';

void main() {
  const decoder = QrDecoder();

  test('decodes a QR code PNG into a URL', () {
    final bytes = File('test/fixtures/sample_qr.png').readAsBytesSync();
    final results = decoder.decode(bytes);

    expect(results, hasLength(1));
    expect(results.first.raw, 'https://example.com/qr2link');
    expect(results.first.isUrl, isTrue);
    expect(results.first.uri?.host, 'example.com');
  });

  test('returns an empty list when no QR is present', () {
    final blank = img.Image(width: 64, height: 64);
    img.fill(blank, color: img.ColorRgb8(255, 255, 255));
    final bytes = Uint8List.fromList(img.encodePng(blank));
    expect(decoder.decode(bytes), isEmpty);
  });

  test('throws QrDecodeException on non-image bytes', () {
    final junk = Uint8List.fromList(List<int>.generate(64, (i) => i));
    expect(
      () => decoder.decode(junk),
      throwsA(isA<QrDecodeException>()),
    );
  });
}
