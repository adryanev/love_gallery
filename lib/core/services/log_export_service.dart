import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:love_gallery/core/services/logging_service.dart';

class LogExportService {
  static final LogExportService _instance = LogExportService._internal();
  late final LoggingService _logger;
  final List<String> _memoryLogs = [];
  static const int _maxMemoryLogs = 500; // Keep last 500 log entries in memory

  // Private constructor
  LogExportService._internal();

  // Singleton factory
  factory LogExportService() {
    return _instance;
  }

  void initialize(LoggingService logger) {
    _logger = logger;
  }

  // Add a log entry to the in-memory buffer
  void addLog(String logLevel, String message) {
    final timestamp = DateFormat(
      'yyyy-MM-dd HH:mm:ss.SSS',
    ).format(DateTime.now());
    final logEntry = '[$timestamp] $logLevel: $message';

    _memoryLogs.add(logEntry);

    // Keep the buffer size limited
    if (_memoryLogs.length > _maxMemoryLogs) {
      _memoryLogs.removeAt(0);
    }
  }

  // Get the contents of the in-memory log buffer
  List<String> getMemoryLogs() {
    return List.from(_memoryLogs);
  }

  // Export logs to a file
  Future<String> exportLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/logs_$timestamp.txt';

      final file = File(path);
      final sink = file.openWrite();

      sink.writeln('=== LOVE GALLERY LOGS ===');
      sink.writeln(
        'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
      );
      sink.writeln('');

      for (final log in _memoryLogs) {
        sink.writeln(log);
      }

      await sink.flush();
      await sink.close();

      _logger.i('Logs exported to: $path');
      return path;
    } catch (e, stackTrace) {
      _logger.e('Failed to export logs', e, stackTrace);
      rethrow;
    }
  }
}
