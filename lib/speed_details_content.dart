// lib/speed_details_content.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeedDetailsContent extends StatefulWidget {
  final bool isConnected;

  const SpeedDetailsContent({super.key, required this.isConnected});

  @override
  State<SpeedDetailsContent> createState() => _SpeedDetailsContentState();
}

class _SpeedDetailsContentState extends State<SpeedDetailsContent> {
  Timer? _speedUpdateTimer;

  double _cloudflareDownloadTotal = 0.0;
  double _cloudflareUploadTotal = 0.0;
  double _otherDownloadTotal = 0.0;
  double _otherUploadTotal = 0.0;

  double _currentDownloadSpeed = 0.0;
  double _currentUploadSpeed = 0.0;

  Map<String, int> _rxBytesStart = {};
  Map<String, int> _txBytesStart = {};

  static const _cloudflareDownloadKey = 'cloudflareDownloadTotal';
  static const _cloudflareUploadKey = 'cloudflareUploadTotal';
  static const _otherDownloadKey = 'otherDownloadTotal';
  static const _otherUploadKey = 'otherUploadTotal';

  @override
  void initState() {
    super.initState();
    _loadCounters();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startSpeedListener();
    });
  }

  @override
  void dispose() {
    _speedUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cloudflareDownloadTotal = prefs.getDouble(_cloudflareDownloadKey) ?? 0.0;
      _cloudflareUploadTotal = prefs.getDouble(_cloudflareUploadKey) ?? 0.0;
      _otherDownloadTotal = prefs.getDouble(_otherDownloadKey) ?? 0.0;
      _otherUploadTotal = prefs.getDouble(_otherUploadKey) ?? 0.0;
    });
  }

  Future<void> _saveCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_cloudflareDownloadKey, _cloudflareDownloadTotal);
    await prefs.setDouble(_cloudflareUploadKey, _cloudflareUploadTotal);
    await prefs.setDouble(_otherDownloadKey, _otherDownloadTotal);
    await prefs.setDouble(_otherUploadKey, _otherUploadTotal);
  }

  Future<void> _startSpeedListener() async {
    await _readInitialBytes();
    _speedUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _updateSpeedFromSysFiles();
    });
  }

  Future<void> _readInitialBytes() async {
    try {
      final result = await Process.run('ls', ['/sys/class/net']);
      final interfaces = (result.stdout as String)
          .split('\n')
          .where((iface) => iface.isNotEmpty && iface != 'lo');

      for (var iface in interfaces) {
        final rxBytesFile = File('/sys/class/net/$iface/statistics/rx_bytes');
        final txBytesFile = File('/sys/class/net/$iface/statistics/tx_bytes');
        
        if (await rxBytesFile.exists() && await txBytesFile.exists()) {
          _rxBytesStart[iface] = int.tryParse(await rxBytesFile.readAsString()) ?? 0;
          _txBytesStart[iface] = int.tryParse(await txBytesFile.readAsString()) ?? 0;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ERROR: Failed to read network statistics files: $e.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateSpeedFromSysFiles() async {
    if (!mounted) return;

    double downloadSpeedTotal = 0.0;
    double uploadSpeedTotal = 0.0;

    try {
      final result = await Process.run('ls', ['/sys/class/net']);
      final interfaces = (result.stdout as String)
          .split('\n')
          .where((iface) => iface.isNotEmpty && iface != 'lo');

      for (var iface in interfaces) {
        final rxBytesFile = File('/sys/class/net/$iface/statistics/rx_bytes');
        final txBytesFile = File('/sys/class/net/$iface/statistics/tx_bytes');
        
        if (await rxBytesFile.exists() && await txBytesFile.exists()) {
          final rxBytesEnd = int.tryParse(await rxBytesFile.readAsString()) ?? 0;
          final txBytesEnd = int.tryParse(await txBytesFile.readAsString()) ?? 0;

          final rxDiff = rxBytesEnd - (_rxBytesStart[iface] ?? 0);
          final txDiff = txBytesEnd - (_txBytesStart[iface] ?? 0);

          downloadSpeedTotal += (rxDiff >= 0) ? rxDiff : 0;
          uploadSpeedTotal += (txDiff >= 0) ? txDiff : 0;
          
          _rxBytesStart[iface] = rxBytesEnd;
          _txBytesStart[iface] = txBytesEnd;
        }
      }

      setState(() {
        _currentDownloadSpeed = downloadSpeedTotal;
        _currentUploadSpeed = uploadSpeedTotal;

        if (widget.isConnected) {
          _cloudflareDownloadTotal += downloadSpeedTotal / 1024;
          _cloudflareUploadTotal += uploadSpeedTotal / 1024;
        } else {
          _otherDownloadTotal += downloadSpeedTotal / 1024;
          _otherUploadTotal += uploadSpeedTotal / 1024;
        }
      });
      _saveCounters();
    } catch (e) {
      // Ignora erros silenciosamente
    }
  }

  void _resetCounters() {
    setState(() {
      _cloudflareDownloadTotal = 0.0;
      _cloudflareUploadTotal = 0.0;
      _otherDownloadTotal = 0.0;
      _otherUploadTotal = 0.0;
    });
    _saveCounters();
  }
  
  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)} TB/s';
    }
  }

  String _formatData(double kilobytes) {
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(2)} KB';
    } else if (kilobytes < 1024 * 1024) {
      return '${(kilobytes / 1024).toStringAsFixed(2)} MB';
    } else if (kilobytes < 1024 * 1024 * 1024) {
      return '${(kilobytes / (1024 * 1024)).toStringAsFixed(2)} GB';
    } else {
      return '${(kilobytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} TB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConnectionStatus(),
          const SizedBox(height: 24),
          
          Text(
            'Current Speed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSpeedDisplay(),
          const SizedBox(height: 24),

          Text(
            'Total Data Transferred',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDataCounters(),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _resetCounters,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Counters'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final color = widget.isConnected ? Colors.blue.shade600 : Colors.red.shade600;
    final text = widget.isConnected ? 'Connected via WARP' : 'Not connected via WARP';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            widget.isConnected ? Icons.check_circle : Icons.warning,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_downward, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              'Download: ${_formatSpeed(_currentDownloadSpeed)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.arrow_upward, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Upload: ${_formatSpeed(_currentUploadSpeed)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataCounters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WARP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download: ${_formatData(_cloudflareDownloadTotal)}',
                    style: TextStyle(color: Colors.blue.shade900.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload: ${_formatData(_cloudflareUploadTotal)}',
                    style: TextStyle(color: Colors.blue.shade900.withOpacity(0.8)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Outside WARP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download: ${_formatData(_otherDownloadTotal)}',
                    style: TextStyle(color: Colors.grey.shade900.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload: ${_formatData(_otherUploadTotal)}',
                    style: TextStyle(color: Colors.grey.shade900.withOpacity(0.8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
