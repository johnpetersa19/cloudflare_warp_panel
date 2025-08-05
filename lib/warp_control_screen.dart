import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

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
  String _warpCliVersion = 'Carregando...'; // Variável para a versão do warp-cli
  final Color _warpColor = const Color(0xFFF65B54);
  final Color _disconnectColor = Colors.grey[400]!;

  @override
  void initState() {
    super.initState();
    _checkWarpStatus();
    _getWarpCliVersion(); // Chama a função para obter a versão do warp-cli

    // Impede redimensionamento (fixo)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Só funciona para desktop (Windows, Linux, Mac)
      // Use bitsdojo_window para travar tamanho (se disponível)
      // appWindow.minSize = const Size(350, 450);
      // appWindow.maxSize = const Size(350, 450);
    });
  }

// Função para obter a versão do warp-cli usando a flag `--version`
Future<void> _getWarpCliVersion() async {
  // A chamada para o comando deve usar a opção `--version`
  final versionOutput = await _executeWarpCommand('--version');
  
  if (mounted) {
    setState(() {
      _warpCliVersion = versionOutput;
    });
  }
}

  Future<String> _executeWarpCommand(String command, [List<String> arguments = const []]) async {
    try {
      final List<String> cmdArgs = [command, ...arguments];
      final result = await Process.run('/usr/bin/warp-cli', cmdArgs);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      } else {
        return 'Erro: ${result.stderr}';
      }
    } catch (e) {
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
  
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Não foi possível abrir o URL: $url';
    }
  }

// Novo método para mostrar a janela "About Zero Trust"
void _showAboutZeroTrustDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: const Text(
                'About Cloudflare',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        // Envolva o Column em um SingleChildScrollView para evitar o overflow
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/cloudflare-logo.svg',
                width: 100,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _launchUrl('https://www.cloudflare.com/pt-br/application/privacypolicy/'),
                child: const Text(
                  'Privacy policy',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl('https://www.cloudflare.com/pt-br/application/terms/'),
                child: const Text(
                  'Terms of service',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl('https://developers.cloudflare.com/warp-client/legal/3rdparty/'),
                child: const Text(
                  'Third party licenses',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Version $_warpCliVersion'), // Usa a versão do warp-cli
              const SizedBox(height: 8),
              const Text('Copyright © 2023 Cloudflare, Inc.'),
            ],
          ),
        ),
      );
    },
  );
}

  // NOVA JANELA: Registration Settings
  void _showRegistrationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Registration Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            ListTile(
                title: const Text('Show registration info'),
                onTap: () async {
                  final result = await _executeWarpCommand('registration', ['show']);
                  // Fecha a janela de 'Registration Settings' primeiro.
                  if (mounted) Navigator.of(context).pop();
                  // Abre a nova janela com o resultado.
                  _showResultDialog('Registration Info', result);
                },
              ),
              ListTile(
                title: const Text('Delete current registration'),
                onTap: () async {
                  await _executeWarpCommand('registration', ['delete']);
                  await _checkWarpStatus();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Register new client'),
                onTap: () async {
                  await _executeWarpCommand('registration', ['delete']);
                  await _executeWarpCommand('registration', ['new']);
                  await _checkWarpStatus();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              // Adicione mais ListTiles para os outros comandos 'registration' conforme a necessidade
            ],
          ),
        );
      },
    );
  }

  // Função auxiliar para mostrar o resultado de um comando em um AlertDialog
  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

void _showSettingsMenu() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Gateway with DoH'),
                  onTap: () async {
                    await _executeWarpCommand('mode', ['doh']);
                    await _checkWarpStatus();
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Gateway with WARP'),
                  onTap: () async {
                    await _executeWarpCommand('mode', ['warp']);
                    await _checkWarpStatus();
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Logout from Zero Trust'),
                  onTap: () async {
                    await _executeWarpCommand('disconnect');
                    await _checkWarpStatus();
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Re-authenticate session'),
                  onTap: () async {
                    // Comando CORRETO para reautenticar a sessão
                    await _executeWarpCommand('debug', ['access-reauth']);
                    await _checkWarpStatus();
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Registration Settings'),
                  onTap: () {
                    if (mounted) Navigator.of(context).pop();
                    _showRegistrationSettingsDialog();
                  },
                ),
                ListTile(
                  title: const Text('About Zero Trust'),
                  onTap: () {
                    if (mounted) Navigator.of(context).pop();
                    _showAboutZeroTrustDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 350,
          height: 450,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: Text(
                        'WARP',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF65B54),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? _warpColor : _disconnectColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _privateText,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/zero-trust-orange.svg',
                                width: 22,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'CLOUDFLARE\nWARP',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.network_wifi, color: Colors.grey),
                                iconSize: 22,
                                onPressed: () {
                                  // Adicione a lógica para o ícone de rede aqui
                                },
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.grey),
                                iconSize: 22,
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
            ],
          ),
        ),
      ),
    );
  }
}
