// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Painel Cloudflare WARP';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get error => 'Erro';

  @override
  String get legalNotice => 'Aviso Legal';

  @override
  String get dataUsage => 'Uso de Dados';

  @override
  String get ok => 'OK';

  @override
  String get zeroTrustLogin => 'Login Zero Trust';

  @override
  String get pleaseEnterTeamName => 'Por favor, insira o nome da sua equipe.';

  @override
  String errorRegisteringTeam(String stderr) {
    return 'Erro ao registrar a equipe: $stderr';
  }

  @override
  String get registrationSuccessful => 'Registro bem-sucedido. Por favor, verifique seu navegador para continuar.';

  @override
  String fatalErrorWarpCli(String error) {
    return 'ERRO FATAL: Falha ao executar o comando warp-cli: $error';
  }

  @override
  String get revertedToFreeMode => 'Revertido para o modo WARP gratuito. Por favor, verifique o painel principal.';

  @override
  String errorReverting(String error) {
    return 'Erro ao reverter para o modo gratuito: $error';
  }

  @override
  String get zeroTrust => 'Zero Trust';

  @override
  String get yourTeamName => 'Nome da sua equipe';

  @override
  String get loginViaBrowser => 'Entrar via navegador';

  @override
  String get revertToFreeWarp => 'Reverter para o WARP Gratuito';

  @override
  String get disconnectedStatus => 'DESCONECTADO';

  @override
  String get notPrivateInternet => 'Sua Internet não está privada.';

  @override
  String get loading => 'Carregando...';

  @override
  String get warp => 'WARP';

  @override
  String get notInstalled => 'NÃO INSTALADO';

  @override
  String get warpCliNotFound => 'warp-cli não encontrado.';

  @override
  String get connectedStatus => 'CONECTADO';

  @override
  String get privateInternet => 'Sua Internet está privada.';

  @override
  String get connectingStatus => 'CONECTANDO...';

  @override
  String get attemptingToConnect => 'Tentando conectar.';

  @override
  String get statusUnknown => 'STATUS DESCONHECIDO';

  @override
  String get couldNotGetStatus => 'Não foi possível obter um status válido.';

  @override
  String get errorWarpCliNotInstalled => 'Erro: warp-cli não está instalado.';

  @override
  String errorResultStderr(String stderr) {
    return 'Erro: $stderr';
  }

  @override
  String get errorWarpCliFailed => 'Erro: O comando warp-cli falhou.';

  @override
  String get doh => 'DoH';

  @override
  String get warpDoh => 'WARP + DoH';

  @override
  String get dot => 'DoT';

  @override
  String get warpDot => 'WARP + DoT';

  @override
  String get proxy => 'Proxy';

  @override
  String get tunnelOnly => 'Apenas Túnel';

  @override
  String get aboutCloudflare => 'Sobre a Cloudflare';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get termsOfService => 'Termos de serviço';

  @override
  String get thirdPartyLicenses => 'Licenças de terceiros';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get copyright => 'Copyright © 2023 Cloudflare, Inc.';

  @override
  String get registrationSettings => 'Configurações de Registro';

  @override
  String get showRegistrationInfo => 'Mostrar informações de registro';

  @override
  String get deleteCurrentRegistration => 'Excluir registro atual';

  @override
  String get registerNewClient => 'Registrar novo cliente';

  @override
  String get registrationInfo => 'Informações de Registro';

  @override
  String get dnsSettings => 'Configurações de DNS';

  @override
  String get showDnsStats => 'Mostrar estatísticas de DNS';

  @override
  String get showDefaultFallbacks => 'Mostrar fallbacks padrão';

  @override
  String get toggleDnsLogging => 'Alternar registro de DNS';

  @override
  String get setFallbackDomain => 'Definir Domínio de Fallback';

  @override
  String get dnsStats => 'Estatísticas de DNS';

  @override
  String get defaultDnsFallbacks => 'Fallbacks de DNS Padrão';

  @override
  String get proxySettings => 'Configurações de Proxy';

  @override
  String get setProxyPort => 'Definir Porta de Proxy';

  @override
  String get setPort => 'Definir Porta';

  @override
  String get trustedNetworks => 'Redes Confiáveis';

  @override
  String get showStatistics => 'Mostrar Estatísticas';

  @override
  String get tunnelSettings => 'Configurações de Túnel';

  @override
  String get vnetSettings => 'Configurações de VNet';

  @override
  String get debugMenu => 'Menu de Depuração';

  @override
  String get showNetworkInfo => 'Mostrar Informações de Rede';

  @override
  String get showPostureInfo => 'Mostrar Informações de Postura';

  @override
  String get showDexData => 'Mostrar dados DEX';

  @override
  String get toggleConnectivityCheck => 'Alternar verificação de conectividade';

  @override
  String get networkInfo => 'Informações de Rede';

  @override
  String get postureInfo => 'Informações de Postura';

  @override
  String get dexData => 'Dados DEX';

  @override
  String get connectivityCheck => 'Verificação de Conectividade';

  @override
  String get tunnelStats => 'Estatísticas do Túnel';

  @override
  String get rotateTunnelKeys => 'Rotacionar Chaves do Túnel';

  @override
  String get virtualNetwork => 'Rede Virtual (VNet)';

  @override
  String currentVnet(String vnet) {
    return 'VNet Atual: $vnet';
  }

  @override
  String get setNewVnet => 'Definir Nova VNet';

  @override
  String get setVnet => 'Definir VNet';

  @override
  String get vnetSet => 'VNet Definida';

  @override
  String newVnetSet(String newVnet) {
    return 'Nova VNet foi definida para $newVnet';
  }

  @override
  String get confirmLogout => 'Tem certeza de que deseja sair do Cloudflare Zero Trust?';

  @override
  String get logoutDescription => 'Após o logout, você será desassociado do Cloudflare Zero Trust.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmLogoutButton => 'Confirmar logout';

  @override
  String get environmentSettings => 'Configurações de Ambiente';

  @override
  String get setNewEnvironment => 'Definir novo ambiente';

  @override
  String get setButton => 'Definir';

  @override
  String get resetButton => 'Redefinir';

  @override
  String get environmentStatus => 'Status do Ambiente';

  @override
  String get mdmConfigs => 'Configurações MDM';

  @override
  String get getMdmConfigs => 'Obter configurações MDM';

  @override
  String get overrideSettings => 'Configurações de Substituição';

  @override
  String get showOverrides => 'Mostrar substituições';

  @override
  String get unlockPolicies => 'Desbloquear políticas';

  @override
  String get localNetworkOverride => 'Substituição de Rede Local';

  @override
  String get overrideStatus => 'Status de Substituição';

  @override
  String get targets => 'Alvos';

  @override
  String get listAllTargets => 'Listar todos os alvos';

  @override
  String get showCertificates => 'Mostrar Certificados';

  @override
  String get accountCertificates => 'Certificados da Conta';

  @override
  String get allowAccess => 'Permitir acesso';

  @override
  String get showAccess => 'Mostrar acesso';

  @override
  String get stopAccess => 'Parar acesso';

  @override
  String get localNetworkStatus => 'Status da Rede Local';

  @override
  String get trustedSsids => 'SSIDs Confiáveis';

  @override
  String get listSsids => 'Listar SSIDs';

  @override
  String get addSsid => 'Adicionar SSID';

  @override
  String get removeSsid => 'Remover SSID';

  @override
  String get resetSsids => 'Redefinir SSIDs';

  @override
  String get enterSsidName => 'Digite o Nome do SSID';

  @override
  String get addButton => 'Adicionar';

  @override
  String get removeButton => 'Remover';

  @override
  String get warpControlScreenText => 'CLOUDFLARE WARP';

  @override
  String get legalNoticeConfirmation => 'Aviso Legal e Confirmação';

  @override
  String get importantInfoPanel => 'Informações Importantes Sobre o Painel';

  @override
  String get appDescription1 => 'Este aplicativo é um painel de controle gráfico (GUI) desenvolvido por um usuário para facilitar a interação com o programa oficial do Cloudflare WARP no Linux. Ele NÃO é o aplicativo oficial do Cloudflare.';

  @override
  String get appDescription2 => 'Para que este painel funcione corretamente, é ESSENCIAL que você tenha o Cloudflare WARP oficial para Linux instalado em seu sistema. Este projeto NÃO coleta NENHUM dado do usuário. A responsabilidade pela operação, privacidade e segurança do seu tráfego de internet é inteiramente da Cloudflare, pois este painel apenas envia comandos para o programa WARP já instalado.';

  @override
  String get confirmationText => 'Ao clicar em \"Eu entendi\", você confirma que leu, compreendeu e aceitou os termos acima. Sua confirmação será salva localmente em seu dispositivo, e este aviso não será exibido novamente em futuros lançamentos do painel.';

  @override
  String get iUnderstand => 'Eu entendi';

  @override
  String get savingConfirmation => 'Iniciando o processo de salvamento da confirmação...';

  @override
  String appSupportDirFound(String path) {
    return 'Diretório de suporte do aplicativo encontrado: $path';
  }

  @override
  String checkingPrefsDir(String path) {
    return 'Tentando verificar se o diretório de preferências existe: $path';
  }

  @override
  String get dirDoesNotExist => 'O diretório não existe. Tentando criar...';

  @override
  String get prefsDirCreated => 'Diretório de preferências criado com sucesso.';

  @override
  String get prefsDirExists => 'O diretório de preferências já existe.';

  @override
  String get hasSeenLegalNoticeSaved => 'A preferência hasSeenLegalNotice foi salva com sucesso.';

  @override
  String get navigationInitiated => 'Navegação para a tela principal iniciada.';

  @override
  String fatalErrorSavePref(String error) {
    return 'ERRO FATAL: Falha ao salvar a preferência ou criar o diretório. Detalhes: $error';
  }

  @override
  String errorReadNetworkStats(String error) {
    return 'ERRO: Falha ao ler arquivos de estatísticas de rede: $error.';
  }

  @override
  String get currentSpeed => 'Velocidade Atual';

  @override
  String get totalDataTransferred => 'Total de Dados Transferidos';

  @override
  String get resetCounters => 'Redefinir Contadores';

  @override
  String get connectedViaWarp => 'Conectado via WARP';

  @override
  String get notConnectedViaWarp => 'Não conectado via WARP';

  @override
  String downloadSpeed(String speed) {
    return 'Download: $speed';
  }

  @override
  String uploadSpeed(String speed) {
    return 'Upload: $speed';
  }

  @override
  String get warpSection => 'WARP';

  @override
  String warpDownload(String data) {
    return 'Download: $data';
  }

  @override
  String warpUpload(String data) {
    return 'Upload: $data';
  }

  @override
  String get outsideWarp => 'Fora do WARP';

  @override
  String outsideWarpDownload(String data) {
    return 'Download: $data';
  }

  @override
  String outsideWarpUpload(String data) {
    return 'Upload: $data';
  }

  @override
  String get trustedNetworksDialogTitle => 'Redes Confiáveis';

  @override
  String get manageTrustedSsids => 'Gerenciar SSIDs confiáveis';

  @override
  String get toggleTrustedEthernet => 'Alternar Ethernet confiável';

  @override
  String get toggleTrustedWifi => 'Alternar Wi-Fi confiável';

  @override
  String get settings => 'Configurações';

  @override
  String get targetList => 'Lista de Alvos';

  @override
  String get logoutFromZeroTrust => 'Sair do Zero Trust';

  @override
  String get reauthenticateSession => 'Reautenticar sessão';

  @override
  String get aboutZeroTrust => 'Sobre o Zero Trust';
}
