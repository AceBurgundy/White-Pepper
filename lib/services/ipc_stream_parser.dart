import 'dart:convert';
import '../models/ipc_event.dart';

class IpcStreamParser {
  static IpcEvent? tryParseJsonLine(String line) {
    final String trimmed = line.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic> && decoded.containsKey('event')) {
        return IpcEvent.fromJson(decoded);
      }
    } catch (_) {
      // Ignore JSON decode errors for standard console output lines
    }
    return null;
  }
}
