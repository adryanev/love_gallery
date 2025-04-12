import 'package:flutter/material.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'package:love_gallery/core/services/logging_service.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final LoggingService _logger;
  bool _isExportingLogs = false;

  @override
  void initState() {
    super.initState();
    _logger = getLogger();
    _logger.i('Settings screen opened');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.petalPink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Data Management'),
          _buildLogExportOption(),
          const SizedBox(height: 30),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 5),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.dustyMauve,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.dustyMauve,
          ),
        ],
      ),
    );
  }

  Widget _buildLogExportOption() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Application Logs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Export logs for troubleshooting',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (_isExportingLogs)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportAndShareLogs,
              color: AppTheme.dustyMauve,
            ),
        ],
      ),
    );
  }

  Future<void> _exportAndShareLogs() async {
    setState(() {
      _isExportingLogs = true;
    });

    try {
      _logger.i('User requested log export');
      final logFilePath = await _logger.exportLogs();
      _logger.i('Logs exported to: $logFilePath');

      final file = File(logFilePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(logFilePath)],
          subject: 'Love Gallery Logs',
          text: 'Love Gallery application logs for troubleshooting',
        );
        _logger.i('Logs shared successfully');
      } else {
        _logger.e('Log file does not exist: $logFilePath');
        _showErrorSnackBar('Failed to export logs: File not found');
      }
    } catch (e, stackTrace) {
      _logger.e('Error exporting logs', e, stackTrace);
      _showErrorSnackBar('Failed to export logs: $e');
    } finally {
      setState(() {
        _isExportingLogs = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.petalPink.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.roseQuartz, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This App',
            style: TextStyle(
              color: AppTheme.warmCharcoal,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'This app was created with love as a special gift for you. Each memory and whisper is a testament to our journey together.',
            style: TextStyle(
              color: AppTheme.warmCharcoal,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'I hope it brings a smile to your face, today and whenever you revisit it.',
            style: TextStyle(
              color: AppTheme.warmCharcoal,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Icon(Icons.favorite, color: AppTheme.dustyMauve, size: 40),
          ),
        ],
      ),
    );
  }
}
