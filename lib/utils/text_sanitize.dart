/// Utilities to make external text safe for Flutter `Text` rendering.
library text_sanitize;
///
/// Some incoming strings (from BLE advertisements, protobufs, etc.) can contain
/// lone surrogate code units, which cause Flutter to throw
/// "Invalid argument(s): string is not well-formed UTF-16" when painting.
/// These helpers replace malformed sequences with the Unicode replacement
/// character (U+FFFD) while preserving valid characters, including emojis.

/// Returns a safe version of [input] suitable for passing to `Text`.
String safeText(String? input) {
  if (input == null || input.isEmpty) return '';
  final units = input.codeUnits;
  final out = <int>[];
  const replacement = 0xFFFD; // �
  int i = 0;
  while (i < units.length) {
    final u = units[i];
    // High surrogate
    if (u >= 0xD800 && u <= 0xDBFF) {
      if (i + 1 < units.length) {
        final v = units[i + 1];
        if (v >= 0xDC00 && v <= 0xDFFF) {
          // Valid surrogate pair: keep both
          out.add(u);
          out.add(v);
          i += 2;
          continue;
        }
      }
      // Lone high surrogate -> replacement
      out.add(replacement);
      i += 1;
      continue;
    }
    // Low surrogate without preceding high -> replacement
    if (u >= 0xDC00 && u <= 0xDFFF) {
      out.add(replacement);
      i += 1;
      continue;
    }
    // Normal BMP code unit
    out.add(u);
    i += 1;
  }
  return String.fromCharCodes(out);
}

/// Picks a single-character initial from [input], returning a safe fallback.
/// Prefers the first non-whitespace rune that is a letter or digit; if none,
/// returns '?' . The returned string is sanitized.
String safeInitial(String? input) {
  if (input == null || input.isEmpty) return '?';
  for (final r in input.runes) {
    // Skip whitespace and control
    if (r <= 0x20) continue;
    final ch = String.fromCharCode(r);
    final isLetterOrDigit = RegExp(r'^[\p{L}\p{N}]$', unicode: true).hasMatch(ch);
    if (isLetterOrDigit) {
      return safeText(ch);
    }
  }
  return '?';
}
