import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/decoded_qr.dart';
import '../services/qr_decoder.dart';
import '../widgets/drop_zone.dart';
import '../widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QrDecoder _decoder = const QrDecoder();

  Uint8List? _preview;
  List<DecodedQr> _results = const [];
  String? _status;
  bool _busy = false;

  Future<void> _handleBytes(Uint8List bytes) async {
    setState(() {
      _busy = true;
      _preview = bytes;
      _results = const [];
      _status = null;
    });
    try {
      final decoded = _decoder.decode(bytes);
      setState(() {
        _results = decoded;
        _status = decoded.isEmpty ? 'No QR code found in this image.' : null;
      });
    } on QrDecodeException catch (e) {
      setState(() => _status = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('qr2link'),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropZone(
                  onBytes: _handleBytes,
                  onError: _showError,
                  child: _PreviewArea(
                    preview: _preview,
                    busy: _busy,
                  ),
                ),
                if (_status != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _status!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                for (final result in _results) ...[
                  const SizedBox(height: 16),
                  ResultCard(result: result),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  const _PreviewArea({required this.preview, required this.busy});

  final Uint8List? preview;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (preview == null && !busy) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (preview != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: Image.memory(preview!, fit: BoxFit.contain),
              ),
            if (busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x88000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
