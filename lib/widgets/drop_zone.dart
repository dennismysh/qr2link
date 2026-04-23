import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

typedef BytesCallback = void Function(Uint8List bytes);

class DropZone extends StatefulWidget {
  const DropZone({
    super.key,
    required this.onBytes,
    required this.onError,
    required this.child,
  });

  final BytesCallback onBytes;
  final void Function(String message) onError;
  final Widget child;

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'qr2link-paste');
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  static const _imageFormats = <FileFormat>[
    Formats.png,
    Formats.jpeg,
    Formats.gif,
    Formats.webp,
    Formats.bmp,
    Formats.tiff,
    Formats.heic,
    Formats.heif,
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.firstOrNull?.bytes;
    if (bytes != null) {
      widget.onBytes(bytes);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      widget.onError('Clipboard is not available on this platform.');
      return;
    }
    final reader = await clipboard.read();
    final format = _imageFormats.firstWhere(
      reader.canProvide,
      orElse: () => _imageFormats.first,
    );
    if (!reader.canProvide(format)) {
      widget.onError('No image found in the clipboard.');
      return;
    }
    final completer = Completer<Uint8List?>();
    reader.getFile(
      format,
      (file) async {
        try {
          completer.complete(await file.readAll());
        } catch (e) {
          completer.complete(null);
        }
      },
      onError: (_) => completer.complete(null),
    );
    final bytes = await completer.future;
    if (bytes == null) {
      widget.onError('Could not read image from clipboard.');
      return;
    }
    widget.onBytes(bytes);
  }

  DropOperation _onDropOver(DropOverEvent event) {
    if (!_isDragOver) setState(() => _isDragOver = true);
    return event.session.allowedOperations.contains(DropOperation.copy)
        ? DropOperation.copy
        : DropOperation.none;
  }

  void _onDropLeave(DropEvent event) {
    if (_isDragOver) setState(() => _isDragOver = false);
  }

  Future<void> _onPerformDrop(PerformDropEvent event) async {
    setState(() => _isDragOver = false);
    for (final item in event.session.items) {
      final reader = item.dataReader;
      if (reader == null) continue;
      final format = _imageFormats.firstWhere(
        reader.canProvide,
        orElse: () => _imageFormats.first,
      );
      if (!reader.canProvide(format)) continue;
      final completer = Completer<Uint8List?>();
      reader.getFile(
        format,
        (file) async {
          try {
            completer.complete(await file.readAll());
          } catch (_) {
            completer.complete(null);
          }
        },
        onError: (_) => completer.complete(null),
      );
      final bytes = await completer.future;
      if (bytes != null) {
        widget.onBytes(bytes);
        return;
      }
    }
    widget.onError('Dropped item did not contain a recognizable image.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): _pasteFromClipboard,
          const SingleActivator(LogicalKeyboardKey.keyV, meta: true): _pasteFromClipboard,
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focusNode.requestFocus(),
          child: DropRegion(
            formats: const [...Formats.standardFormats],
            hitTestBehavior: HitTestBehavior.opaque,
            onDropOver: _onDropOver,
            onDropLeave: _onDropLeave,
            onPerformDrop: _onPerformDrop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isDragOver
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: _isDragOver ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
                color: _isDragOver
                    ? theme.colorScheme.primaryContainer.withOpacity(0.25)
                    : theme.colorScheme.surfaceContainerLow,
              ),
              padding: const EdgeInsets.all(24),
              child: _DropZoneBody(
                onPickFile: _pickFile,
                onPasteFromClipboard: _pasteFromClipboard,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropZoneBody extends StatelessWidget {
  const _DropZoneBody({
    required this.onPickFile,
    required this.onPasteFromClipboard,
    required this.child,
  });

  final VoidCallback onPickFile;
  final VoidCallback onPasteFromClipboard;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.qr_code_2, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          'Drop a screenshot, paste an image, or choose a file',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'QR codes are decoded in your browser — nothing is uploaded.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose image'),
            ),
            OutlinedButton.icon(
              onPressed: onPasteFromClipboard,
              icon: const Icon(Icons.content_paste),
              label: const Text('Paste from clipboard'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
