// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cloudflare WARP Panel';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get error => 'Error';

  @override
  String get legalNotice => 'Legal Notice';

  @override
  String get dataUsage => 'Data Usage';

  @override
  String get ok => 'OK';

  @override
  String get zeroTrustLogin => 'Zero Trust Login';

  @override
  String get pleaseEnterTeamName => 'Please enter your team name.';

  @override
  String errorRegisteringTeam(String stderr) {
    return 'Error registering team: $stderr';
  }

  @override
  String get registrationSuccessful => 'Registration successful. Please check your browser to continue.';

  @override
  String fatalErrorWarpCli(String error) {
    return 'FATAL ERROR: Failed to execute warp-cli command: $error';
  }

  @override
  String get revertedToFreeMode => 'Reverted to free WARP mode. Please check the main dashboard.';

  @override
  String errorReverting(String error) {
    return 'Error reverting to free mode: $error';
  }

  @override
  String get zeroTrust => 'Zero Trust';

  @override
  String get yourTeamName => 'Your team name';

  @override
  String get loginViaBrowser => 'Login via browser';

  @override
  String get revertToFreeWarp => 'Revert to Free WARP';

  @override
  String get disconnectedStatus => 'DISCONNECTED';

  @override
  String get notPrivateInternet => 'Your Internet is not private.';

  @override
  String get loading => 'Loading...';

  @override
  String get warp => 'WARP';

  @override
  String get notInstalled => 'NOT INSTALLED';

  @override
  String get warpCliNotFound => 'WARP-CLI not found.';

  @override
  String get connectedStatus => 'CONNECTED';

  @override
  String get privateInternet => 'Your Internet is private.';

  @override
  String get connectingStatus => 'CONNECTING...';

  @override
  String get attemptingToConnect => 'Attempting to connect.';

  @override
  String get statusUnknown => 'STATUS UNKNOWN';

  @override
  String get couldNotGetStatus => 'Could not get a valid status.';

  @override
  String get errorWarpCliNotInstalled => 'Error: warp-cli is not installed.';

  @override
  String errorResultStderr(String stderr) {
    return 'Error: $stderr';
  }

  @override
  String get errorWarpCliFailed => 'Error: The warp-cli command failed.';

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
  String get tunnelOnly => 'Tunnel Only';

  @override
  String get aboutCloudflare => 'About Cloudflare';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get thirdPartyLicenses => 'Third party licenses';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get copyright => 'Copyright © 2023 Cloudflare, Inc.';

  @override
  String get registrationSettings => 'Registration Settings';

  @override
  String get showRegistrationInfo => 'Show registration info';

  @override
  String get deleteCurrentRegistration => 'Delete current registration';

  @override
  String get registerNewClient => 'Register new client';

  @override
  String get registrationInfo => 'Registration Info';

  @override
  String get dnsSettings => 'DNS Settings';

  @override
  String get showDnsStats => 'Show DNS stats';

  @override
  String get showDefaultFallbacks => 'Show default fallbacks';

  @override
  String get toggleDnsLogging => 'Toggle DNS logging';

  @override
  String get setFallbackDomain => 'Set Fallback Domain';

  @override
  String get dnsStats => 'DNS Stats';

  @override
  String get defaultDnsFallbacks => 'Default DNS Fallbacks';

  @override
  String get proxySettings => 'Proxy Settings';

  @override
  String get setProxyPort => 'Set Proxy Port';

  @override
  String get setPort => 'Set Port';

  @override
  String get trustedNetworks => 'Trusted Networks';

  @override
  String get showStatistics => 'Show Statistics';

  @override
  String get tunnelSettings => 'Tunnel Settings';

  @override
  String get vnetSettings => 'VNet Settings';

  @override
  String get debugMenu => 'Debug Menu';

  @override
  String get showNetworkInfo => 'Show Network Info';

  @override
  String get showPostureInfo => 'Show Posture Info';

  @override
  String get showDexData => 'Show DEX data';

  @override
  String get toggleConnectivityCheck => 'Toggle connectivity check';

  @override
  String get networkInfo => 'Network Info';

  @override
  String get postureInfo => 'Posture Info';

  @override
  String get dexData => 'DEX Data';

  @override
  String get connectivityCheck => 'Connectivity Check';

  @override
  String get tunnelStats => 'Tunnel Stats';

  @override
  String get rotateTunnelKeys => 'Rotate Tunnel Keys';

  @override
  String get virtualNetwork => 'Virtual Network (VNet)';

  @override
  String currentVnet(String vnet) {
    return 'Current Vnet: $vnet';
  }

  @override
  String get setNewVnet => 'Set New Vnet';

  @override
  String get setVnet => 'Set VNet';

  @override
  String get vnetSet => 'VNet Set';

  @override
  String newVnetSet(String newVnet) {
    return 'New VNet has been set to $newVnet';
  }

  @override
  String get confirmLogout => 'Are you sure you want to logout from Cloudflare Zero Trust?';

  @override
  String get logoutDescription => 'After the logout, you will be disassociated from Cloudflare Zero Trust.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmLogoutButton => 'Confirm logout';

  @override
  String get environmentSettings => 'Environment Settings';

  @override
  String get setNewEnvironment => 'Set new environment';

  @override
  String get setButton => 'Set';

  @override
  String get resetButton => 'Reset';

  @override
  String get environmentStatus => 'Environment Status';

  @override
  String get mdmConfigs => 'MDM Configurations';

  @override
  String get getMdmConfigs => 'Get MDM configs';

  @override
  String get overrideSettings => 'Override Settings';

  @override
  String get showOverrides => 'Show overrides';

  @override
  String get unlockPolicies => 'Unlock policies';

  @override
  String get localNetworkOverride => 'Local Network Override';

  @override
  String get overrideStatus => 'Override Status';

  @override
  String get targets => 'Targets';

  @override
  String get listAllTargets => 'List all targets';

  @override
  String get showCertificates => 'Show Certificates';

  @override
  String get accountCertificates => 'Account Certificates';

  @override
  String get allowAccess => 'Allow access';

  @override
  String get showAccess => 'Show access';

  @override
  String get stopAccess => 'Stop access';

  @override
  String get localNetworkStatus => 'Local Network Status';

  @override
  String get trustedSsids => 'Trusted SSIDs';

  @override
  String get listSsids => 'List SSIDs';

  @override
  String get addSsid => 'Add SSID';

  @override
  String get removeSsid => 'Remove SSID';

  @override
  String get resetSsids => 'Reset SSIDs';

  @override
  String get enterSsidName => 'Enter SSID Name';

  @override
  String get addButton => 'Add';

  @override
  String get removeButton => 'Remove';

  @override
  String get warpControlScreenText => 'CLOUDFLARE WARP';

  @override
  String get legalNoticeConfirmation => 'Legal Notice and Confirmation';

  @override
  String get importantInfoPanel => 'Important Information About the Panel';

  @override
  String get appDescription1 => 'This app is a graphical control panel (GUI) developed by a user to make it easier to interact with the official Cloudflare WARP program on Linux. It is NOT the official Cloudflare application.';

  @override
  String get appDescription2 => 'For this panel to work properly, it is ESSENTIAL that you have the official Cloudflare WARP for Linux installed on your system. This project DOES NOT collect ANY user data. Responsibility for the operation, privacy, and security of your internet traffic lies entirely with Cloudflare, as this panel only sends commands to the already installed official WARP program.';

  @override
  String get confirmationText => 'By clicking \"I understand\", you confirm that you have read, understood, and accepted the above terms. Your confirmation will be saved locally on your device, and this notice will not be shown again on future launches of the panel.';

  @override
  String get iUnderstand => 'I understand';

  @override
  String get savingConfirmation => 'Starting the process of saving confirmation...';

  @override
  String appSupportDirFound(String path) {
    return 'Application support directory found: $path';
  }

  @override
  String checkingPrefsDir(String path) {
    return 'Attempting to check if the preferences directory exists: $path';
  }

  @override
  String get dirDoesNotExist => 'Directory does not exist. Attempting to create...';

  @override
  String get prefsDirCreated => 'Preferences directory created successfully.';

  @override
  String get prefsDirExists => 'Preferences directory already exists.';

  @override
  String get hasSeenLegalNoticeSaved => 'The hasSeenLegalNotice preference has been saved successfully.';

  @override
  String get navigationInitiated => 'Navigation to the main screen initiated.';

  @override
  String fatalErrorSavePref(String error) {
    return 'FATAL ERROR: Failed to save preference or create directory. Details: $error';
  }

  @override
  String errorReadNetworkStats(String error) {
    return 'ERROR: Failed to read network statistics files: $error.';
  }

  @override
  String get currentSpeed => 'Current Speed';

  @override
  String get totalDataTransferred => 'Total Data Transferred';

  @override
  String get resetCounters => 'Reset Counters';

  @override
  String get connectedViaWarp => 'Connected via WARP';

  @override
  String get notConnectedViaWarp => 'Not connected via WARP';

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
  String get outsideWarp => 'Outside WARP';

  @override
  String outsideWarpDownload(String data) {
    return 'Download: $data';
  }

  @override
  String outsideWarpUpload(String data) {
    return 'Upload: $data';
  }

  @override
  String get trustedNetworksDialogTitle => 'Trusted Networks';

  @override
  String get manageTrustedSsids => 'Manage trusted SSIDs';

  @override
  String get toggleTrustedEthernet => 'Toggle trusted Ethernet';

  @override
  String get toggleTrustedWifi => 'Toggle trusted Wi-Fi';

  @override
  String get settings => 'Settings';

  @override
  String get targetList => 'Target List';

  @override
  String get logoutFromZeroTrust => 'Logout from Zero Trust';

  @override
  String get reauthenticateSession => 'Re-authenticate session';

  @override
  String get aboutZeroTrust => 'About Zero Trust';
}
