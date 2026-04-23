import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/decoded_qr.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.result});

  final DecodedQr result;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: result.raw));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final uri = result.uri;
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $uri')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  result.isUrl ? Icons.link : Icons.text_snippet_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  result.isUrl ? 'Link detected' : 'Text detected',
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              result.raw,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
                if (result.isUrl)
                  FilledButton.icon(
                    onPressed: () => _open(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
