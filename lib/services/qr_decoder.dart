import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import '../models/decoded_qr.dart';

class QrDecoder {
  const QrDecoder();

  List<DecodedQr> decode(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const QrDecodeException('Unsupported or corrupt image.');
    }

    final bitmap = _toBinaryBitmap(decoded);

    try {
      final result = QRCodeReader().decode(bitmap);
      return [DecodedQr(result.text)];
    } on NotFoundException {
      return const [];
    } on ReaderException catch (e) {
      throw QrDecodeException('Could not decode QR: ${e.runtimeType}');
    }
  }

  BinaryBitmap _toBinaryBitmap(img.Image image) {
    // Some PNGs (e.g. 1-bit or palette) don't expand cleanly via getBytes, so
    // build the ARGB Int32 buffer pixel-by-pixel — reliable across all formats.
    final pixels = Int32List(image.width * image.height);
    var offset = 0;
    for (final pixel in image) {
      final a = pixel.a.toInt() & 0xff;
      final r = pixel.r.toInt() & 0xff;
      final g = pixel.g.toInt() & 0xff;
      final b = pixel.b.toInt() & 0xff;
      pixels[offset++] = (a << 24) | (r << 16) | (g << 8) | b;
    }
    final source = RGBLuminanceSource(image.width, image.height, pixels);
    return BinaryBitmap(HybridBinarizer(source));
  }
}

class QrDecodeException implements Exception {
  const QrDecodeException(this.message);
  final String message;

  @override
  String toString() => message;
}
