import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class SpeedDetailsContent extends StatefulWidget {
  final bool isConnected;

  const SpeedDetailsContent({super.key, required this.isConnected});

  @override
  State<SpeedDetailsContent> createState() => _SpeedDetailsContentState();
}

class _SpeedDetailsContentState extends State<SpeedDetailsContent> with SingleTickerProviderStateMixin {
  Timer? _speedUpdateTimer;

  double _cloudflareDownloadTotal = 0.0;
  double _cloudflareUploadTotal = 0.0;
  double _otherDownloadTotal = 0.0;
  double _otherUploadTotal = 0.0;

  double _currentDownloadSpeed = 0.0;
  double _currentUploadSpeed = 0.0;
  double _maxDownloadSpeed = 0.0;
  double _maxUploadSpeed = 0.0;

  DateTime? _lastDownloadPeakTime;
  double _highestDownloadSpeedSinceLastPeak = 0.0;

  DateTime? _lastUploadPeakTime;
  double _highestUploadSpeedSinceLastPeak = 0.0;

  late AnimationController _animationController;
  late Animation<double> _downloadAnimation;
  late Animation<double> _uploadAnimation;
  double _targetDownloadSpeed = 0.0;
  double _targetUploadSpeed = 0.0;

  Map<String, int> _rxBytesStart = {};
  Map<String, int> _txBytesStart = {};

  static const _cloudflareDownloadKey = 'cloudflareDownloadTotal';
  static const _cloudflareUploadKey = 'cloudflareUploadTotal';
  static const _otherDownloadKey = 'otherDownloadTotal';
  static const _otherUploadKey = 'otherUploadTotal';
  static const _maxDownloadSpeedKey = 'maxDownloadSpeed';
  static const _maxUploadSpeedKey = 'maxUploadSpeed';
  static const _lastDownloadPeakTimeKey = 'lastDownloadPeakTime';
  static const _highestDownloadSpeedSinceLastPeakKey = 'highestDownloadSpeedSinceLastPeak';
  static const _lastUploadPeakTimeKey = 'lastUploadPeakTime';
  static const _highestUploadSpeedSinceLastPeakKey = 'highestUploadSpeedSinceLastPeak';

  static const _defaultMaxSpeedMB = 12.5;
  static const _adjustmentPeriodHours = 3;

  @override
  void initState() {
    super.initState();
    _loadCounters();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startSpeedListener();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _downloadAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          _currentDownloadSpeed = _downloadAnimation.value;
        });
      });
      
    _uploadAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          _currentUploadSpeed = _uploadAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _speedUpdateTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cloudflareDownloadTotal = prefs.getDouble(_cloudflareDownloadKey) ?? 0.0;
      _cloudflareUploadTotal = prefs.getDouble(_cloudflareUploadKey) ?? 0.0;
      _otherDownloadTotal = prefs.getDouble(_otherDownloadKey) ?? 0.0;
      _otherUploadTotal = prefs.getDouble(_otherUploadKey) ?? 0.0;
      
      final defaultMaxBytes = _defaultMaxSpeedMB * 1024 * 1024;
      _maxDownloadSpeed = prefs.getDouble(_maxDownloadSpeedKey) ?? defaultMaxBytes;
      _maxUploadSpeed = prefs.getDouble(_maxUploadSpeedKey) ?? (defaultMaxBytes / 2.0);

      final lastDownloadPeakTimeString = prefs.getString(_lastDownloadPeakTimeKey);
      if (lastDownloadPeakTimeString != null) {
        _lastDownloadPeakTime = DateTime.parse(lastDownloadPeakTimeString);
      }
      _highestDownloadSpeedSinceLastPeak = prefs.getDouble(_highestDownloadSpeedSinceLastPeakKey) ?? 0.0;
      
      final lastUploadPeakTimeString = prefs.getString(_lastUploadPeakTimeKey);
      if (lastUploadPeakTimeString != null) {
        _lastUploadPeakTime = DateTime.parse(lastUploadPeakTimeString);
      }
      _highestUploadSpeedSinceLastPeak = prefs.getDouble(_highestUploadSpeedSinceLastPeakKey) ?? 0.0;
    });
  }

  Future<void> _saveCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_cloudflareDownloadKey, _cloudflareDownloadTotal);
    await prefs.setDouble(_cloudflareUploadKey, _cloudflareUploadTotal);
    await prefs.setDouble(_otherDownloadKey, _otherDownloadTotal);
    await prefs.setDouble(_otherUploadKey, _otherUploadTotal);
    await prefs.setDouble(_maxDownloadSpeedKey, _maxDownloadSpeed);
    await prefs.setDouble(_maxUploadSpeedKey, _maxUploadSpeed);
    
    if (_lastDownloadPeakTime != null) {
      await prefs.setString(_lastDownloadPeakTimeKey, _lastDownloadPeakTime!.toIso8601String());
    } else {
      await prefs.remove(_lastDownloadPeakTimeKey);
    }
    await prefs.setDouble(_highestDownloadSpeedSinceLastPeakKey, _highestDownloadSpeedSinceLastPeak);
    
    if (_lastUploadPeakTime != null) {
      await prefs.setString(_lastUploadPeakTimeKey, _lastUploadPeakTime!.toIso8601String());
    } else {
      await prefs.remove(_lastUploadPeakTimeKey);
    }
    await prefs.setDouble(_highestUploadSpeedSinceLastPeakKey, _highestUploadSpeedSinceLastPeak);
  }

  Future<void> _startSpeedListener() async {
    await _readInitialBytes();
    _speedUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _updateSpeedFromSysFiles();
    });
  }

  Future<void> _readInitialBytes() async {
    final localizations = AppLocalizations.of(context)!;
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
              localizations.errorReadNetworkStats(e.toString()),
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
    final localizations = AppLocalizations.of(context)!;

    try {
      final result = await Process.run('ls', ['/sys/class/net']);
      final interfaces = (result.stdout as String)
          .split('\n')
          .where((iface) => iface.isNotEmpty && iface != 'lo');

      String? warpInterface;
      if (widget.isConnected) {
        warpInterface = interfaces.firstWhere(
          (iface) => iface == 'CloudflareWARP',
          orElse: () => '',
        );
      }
      
      final interfacesToRead = (warpInterface != null && warpInterface.isNotEmpty) ? [warpInterface] : interfaces;

      for (var iface in interfacesToRead) {
        final rxBytesFile = File('/sys/class/net/$iface/statistics/rx_bytes');
        final txBytesFile = File('/sys/class/net/$iface/statistics/tx_bytes');
        
        if (await rxBytesFile.exists() && await txBytesFile.exists()) {
          final rxBytesEnd = int.tryParse(await rxBytesFile.readAsString()) ?? 0;
          final txBytesEnd = int.tryParse(await txBytesFile.readAsString()) ?? 0;

          final rxDiff = rxBytesEnd - (_rxBytesStart[iface] ?? 0);
          final txDiff = txBytesEnd - (_txBytesStart[iface] ?? 0);

          downloadSpeedTotal += (rxDiff >= 0) ? rxDiff : 0;
          uploadSpeedTotal += (txDiff >= 0) ? txDiff : 0;
          
          if (widget.isConnected) {
            _cloudflareDownloadTotal += (rxDiff >= 0) ? rxDiff / 1024.0 : 0.0;
            _cloudflareUploadTotal += (txDiff >= 0) ? txDiff / 1024.0 : 0.0;
          } else {
            _otherDownloadTotal += (rxDiff >= 0) ? rxDiff / 1024.0 : 0.0;
            _otherUploadTotal += (txDiff >= 0) ? txDiff / 1024.0 : 0.0;
          }

          _rxBytesStart[iface] = rxBytesEnd;
          _txBytesStart[iface] = txBytesEnd;
        }
      }
      
      _targetDownloadSpeed = downloadSpeedTotal; 
      _targetUploadSpeed = uploadSpeedTotal;

      if (downloadSpeedTotal > _maxDownloadSpeed) {
        _maxDownloadSpeed = downloadSpeedTotal;
        _lastDownloadPeakTime = DateTime.now();
        _highestDownloadSpeedSinceLastPeak = 0.0;
      } else {
        _lastDownloadPeakTime ??= DateTime.now();
        if (downloadSpeedTotal > _highestDownloadSpeedSinceLastPeak) {
          _highestDownloadSpeedSinceLastPeak = downloadSpeedTotal;
        }
        final timeSinceLastPeak = DateTime.now().difference(_lastDownloadPeakTime!).inHours;
        if (timeSinceLastPeak >= _adjustmentPeriodHours) {
          if (_highestDownloadSpeedSinceLastPeak > 0) {
            _maxDownloadSpeed = _highestDownloadSpeedSinceLastPeak;
          }
          _lastDownloadPeakTime = DateTime.now();
          _highestUploadSpeedSinceLastPeak = 0.0;
        }
      }
      
      if (uploadSpeedTotal > _maxUploadSpeed) {
        _maxUploadSpeed = uploadSpeedTotal;
        _lastUploadPeakTime = DateTime.now();
        _highestUploadSpeedSinceLastPeak = 0.0;
      } else {
        _lastUploadPeakTime ??= DateTime.now();
        if (uploadSpeedTotal > _highestUploadSpeedSinceLastPeak) {
          _highestUploadSpeedSinceLastPeak = uploadSpeedTotal;
        }
        final timeSinceLastPeak = DateTime.now().difference(_lastUploadPeakTime!).inHours;
        if (timeSinceLastPeak >= _adjustmentPeriodHours) {
          if (_highestUploadSpeedSinceLastPeak > 0) {
            _maxUploadSpeed = _highestUploadSpeedSinceLastPeak;
          }
          _lastUploadPeakTime = DateTime.now();
          _highestUploadSpeedSinceLastPeak = 0.0;
        }
      }

      setState(() {
        _downloadAnimation = Tween<double>(begin: _currentDownloadSpeed, end: _targetDownloadSpeed).animate(_animationController);
        _uploadAnimation = Tween<double>(begin: _currentUploadSpeed, end: _targetUploadSpeed).animate(_animationController);
        _animationController.forward(from: 0.0);
      });

      _saveCounters();
    } catch (e) {
    }
  }

  void _resetCounters() {
    setState(() {
      _cloudflareDownloadTotal = 0.0;
      _cloudflareUploadTotal = 0.0;
      _otherDownloadTotal = 0.0;
      _otherUploadTotal = 0.0;
      
      final defaultMaxBytes = _defaultMaxSpeedMB * 1024 * 1024;
      _maxDownloadSpeed = defaultMaxBytes; 
      _maxUploadSpeed = defaultMaxBytes / 2.0;

      _lastDownloadPeakTime = DateTime.now();
      _highestDownloadSpeedSinceLastPeak = 0.0;
      _lastUploadPeakTime = DateTime.now();
      _highestUploadSpeedSinceLastPeak = 0.0;
      
      _targetDownloadSpeed = 0.0;
      _targetUploadSpeed = 0.0;
      _downloadAnimation = Tween<double>(begin: _currentDownloadSpeed, end: 0.0).animate(_animationController);
      _uploadAnimation = Tween<double>(begin: _currentUploadSpeed, end: 0.0).animate(_animationController);
      _animationController.forward(from: 0.0);
    });
    _saveCounters();
  }
  
  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024) * 8).toStringAsFixed(2)} Mb/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024 * 1024) * 8).toStringAsFixed(2)} Gb/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024 * 1024 * 1024) * 8).toStringAsFixed(2)} Tb/s';
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
  
  Widget _buildSpeedBar(double currentSpeed, double maxSpeed) {
    final double progressValue = (maxSpeed > 0) ? (currentSpeed / maxSpeed) : 0.0;

    Color barColor;
    if (progressValue < 0.33) {
      barColor = Colors.yellow;
    } else if (progressValue < 0.66) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: barColor.withOpacity(0.2),
        color: barColor,
        minHeight: 10,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConnectionStatus(localizations),
          const SizedBox(height: 24),
          
          Text(
            localizations.currentSpeed,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSpeedDisplay(localizations),
          const SizedBox(height: 24),

          Text(
            localizations.totalDataTransferred,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDataCounters(localizations),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _resetCounters,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.resetCounters),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(AppLocalizations localizations) {
    final color = widget.isConnected ? Colors.blue.shade600 : Colors.red.shade600;
    final text = widget.isConnected ? localizations.connectedViaWarp : localizations.notConnectedViaWarp;
    
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
  
  Widget _buildSpeedDisplay(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_downward, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              localizations.downloadSpeed(_formatSpeed(_currentDownloadSpeed)),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        _buildSpeedBar(_currentDownloadSpeed, _maxDownloadSpeed),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.arrow_upward, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              localizations.uploadSpeed(_formatSpeed(_currentUploadSpeed)),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        _buildSpeedBar(_currentUploadSpeed, _maxUploadSpeed),
      ],
    );
  }

  Widget _buildDataCounters(AppLocalizations localizations) {
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
                localizations.warpSection,
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
                    localizations.warpDownload(_formatData(_cloudflareDownloadTotal)),
                    style: TextStyle(color: Colors.blue.shade900.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.warpUpload(_formatData(_cloudflareUploadTotal)),
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
                localizations.outsideWarp,
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
                    localizations.outsideWarpDownload(_formatData(_otherDownloadTotal)),
                    style: TextStyle(color: Colors.grey.shade900.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.outsideWarpUpload(_formatData(_otherUploadTotal)),
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

