import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class WarpControlScreen extends StatefulWidget {
  const WarpControlScreen({super.key});

  @override
  State<WarpControlScreen> createState() => _WarpControlScreenState();
}

class _WarpControlScreenState extends State<WarpControlScreen> {
  bool _isConnected = false;
  String _statusText = 'DISCONNECTED';
  String _privateText = 'Your Internet is not private.';
  String _currentIconPath = 'assets/zero-trust-disconnected.svg';
  String _mainIconPath = 'assets/zero-trust-orange.svg';
  final Color _warpColor = const Color(0xFFF65B54);
  final Color _disconnectColor = Colors.grey[400]!;

  @override
  void initState() {
    super.initState();
    _checkWarpStatus();
  }

  Future<String> _executeWarpCommand(String command, [List<String> arguments = const []]) async {
    try {
      final List<String> cmdArgs = [command, ...arguments];
      print('DEBUG: Comando executado: /usr/bin/warp-cli ${cmdArgs.join(' ')}');
      final result = await Process.run('/usr/bin/warp-cli', cmdArgs);
      if (result.exitCode == 0) {
        print('DEBUG: Saída do comando: ${result.stdout}');
        return result.stdout.toString().trim();
      } else {
        print('Erro ao executar $command: ${result.stderr}');
        return 'Erro: ${result.stderr}';
      }
    } catch (e) {
      print('Exceção ao tentar executar o comando: $e');
      return 'Erro: O comando warp-cli falhou.';
    }
  }

  Future<void> _checkWarpStatus() async {
    final statusOutput = await _executeWarpCommand('status');
    if (statusOutput.contains('Connected')) {
      setState(() {
        _isConnected = true;
        _statusText = 'CONNECTED';
        _privateText = 'Your Internet is private.';
        _currentIconPath = 'assets/zero-trust-connected.svg';
      });
    } else if (statusOutput.contains('Disconnected')) {
      setState(() {
        _isConnected = false;
        _statusText = 'DISCONNECTED';
        _privateText = 'Your Internet is not private.';
        _currentIconPath = 'assets/zero-trust-disconnected.svg';
      });
    } else {
      setState(() {
        _isConnected = false;
        _statusText = 'ERRO';
        _privateText = 'Não foi possível ler o status.';
        _currentIconPath = 'assets/zero-trust-error.svg';
      });
    }
  }

  Future<void> _toggleWarp() async {
    final command = _isConnected ? 'disconnect' : 'connect';
    await _executeWarpCommand(command);
    await Future.delayed(const Duration(seconds: 2));
    await _checkWarpStatus();
  }

  void _showSettingsMenu() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Gateway with DoH'),
                onTap: () async {
                  await _executeWarpCommand('mode', ['doh']);
                  await _checkWarpStatus();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ListTile(
                title: const Text('Gateway with WARP'),
                onTap: () async {
                  await _executeWarpCommand('mode', ['warp']);
                  await _checkWarpStatus();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Logout from Zero Trust'),
                onTap: () async {
                  await _executeWarpCommand('disconnect');
                  await _checkWarpStatus();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ListTile(
                title: const Text('Re-authenticate session'),
                onTap: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ListTile(
                title: const Text('About Zero Trust'),
                onTap: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[900],
      body: Center(
        child: Container(
          width: 350,
          height: 450,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  'WARP',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SvgPicture.asset(
                  _currentIconPath,
                  width: 100,
                ),
              ),
              GestureDetector(
                onTap: _toggleWarp,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  width: 120,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isConnected ? _warpColor : _disconnectColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _isConnected ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isConnected ? _warpColor : _disconnectColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _privateText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        SvgPicture.asset(
                          _mainIconPath,
                          width: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'CLOUDFLARE\nWARP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.network_wifi, color: Colors.grey),
                          onPressed: () {
                            // Adicione a lógica para o ícone de rede aqui
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.grey),
                          onPressed: _showSettingsMenu,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

