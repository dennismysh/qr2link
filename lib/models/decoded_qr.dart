class DecodedQr {
  DecodedQr(this.raw) : uri = _tryParseHttp(raw);

  final String raw;
  final Uri? uri;

  bool get isUrl => uri != null;

  static Uri? _tryParseHttp(String raw) {
    final parsed = Uri.tryParse(raw.trim());
    if (parsed == null || !parsed.hasScheme) return null;
    const webSchemes = {'http', 'https'};
    return webSchemes.contains(parsed.scheme.toLowerCase()) ? parsed : null;
  }
}
