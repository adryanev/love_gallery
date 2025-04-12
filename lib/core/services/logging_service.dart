import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:love_gallery/core/services/log_export_service.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  late Logger _logger;
  final LogExportService _exportService = LogExportService();

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal() {
    _logger = Logger(
      printer: LogfmtPrinter(),
      level: kDebugMode ? Level.trace : Level.info,
    );
    _exportService.initialize(this);
  }

  void v(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
    _exportService.addLog('VERBOSE', message);
  }

  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    _exportService.addLog('DEBUG', message);
  }

  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _exportService.addLog('INFO', message);
  }

  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _exportService.addLog('WARNING', message);
  }

  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    final errorMsg = error != null ? '$message: $error' : message;
    _exportService.addLog('ERROR', errorMsg);

    if (stackTrace != null) {
      _exportService.addLog('STACKTRACE', stackTrace.toString());
    }
  }

  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    final errorMsg = error != null ? '$message: $error' : message;
    _exportService.addLog('CRITICAL', errorMsg);

    if (stackTrace != null) {
      _exportService.addLog('STACKTRACE', stackTrace.toString());
    }
  }

  // Get in-memory logs
  List<String> getMemoryLogs() {
    return _exportService.getMemoryLogs();
  }

  // Export logs to file
  Future<String> exportLogs() {
    return _exportService.exportLogs();
  }
}
