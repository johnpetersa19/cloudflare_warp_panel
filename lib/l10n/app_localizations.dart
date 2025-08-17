import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloudflare WARP Panel'**
  String get appTitle;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legalNotice;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @zeroTrustLogin.
  ///
  /// In en, this message translates to:
  /// **'Zero Trust Login'**
  String get zeroTrustLogin;

  /// No description provided for @pleaseEnterTeamName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your team name.'**
  String get pleaseEnterTeamName;

  /// Error message for failed registration.
  ///
  /// In en, this message translates to:
  /// **'Error registering team: {stderr}'**
  String errorRegisteringTeam(String stderr);

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Please check your browser to continue.'**
  String get registrationSuccessful;

  /// Fatal error message for warp-cli.
  ///
  /// In en, this message translates to:
  /// **'FATAL ERROR: Failed to execute warp-cli command: {error}'**
  String fatalErrorWarpCli(String error);

  /// No description provided for @revertedToFreeMode.
  ///
  /// In en, this message translates to:
  /// **'Reverted to free WARP mode. Please check the main dashboard.'**
  String get revertedToFreeMode;

  /// Error message for reverting to free mode.
  ///
  /// In en, this message translates to:
  /// **'Error reverting to free mode: {error}'**
  String errorReverting(String error);

  /// No description provided for @zeroTrust.
  ///
  /// In en, this message translates to:
  /// **'Zero Trust'**
  String get zeroTrust;

  /// No description provided for @yourTeamName.
  ///
  /// In en, this message translates to:
  /// **'Your team name'**
  String get yourTeamName;

  /// No description provided for @loginViaBrowser.
  ///
  /// In en, this message translates to:
  /// **'Login via browser'**
  String get loginViaBrowser;

  /// No description provided for @revertToFreeWarp.
  ///
  /// In en, this message translates to:
  /// **'Revert to Free WARP'**
  String get revertToFreeWarp;

  /// No description provided for @disconnectedStatus.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTED'**
  String get disconnectedStatus;

  /// No description provided for @notPrivateInternet.
  ///
  /// In en, this message translates to:
  /// **'Your Internet is not private.'**
  String get notPrivateInternet;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @warp.
  ///
  /// In en, this message translates to:
  /// **'WARP'**
  String get warp;

  /// No description provided for @notInstalled.
  ///
  /// In en, this message translates to:
  /// **'NOT INSTALLED'**
  String get notInstalled;

  /// No description provided for @warpCliNotFound.
  ///
  /// In en, this message translates to:
  /// **'WARP-CLI not found.'**
  String get warpCliNotFound;

  /// No description provided for @connectedStatus.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get connectedStatus;

  /// No description provided for @privateInternet.
  ///
  /// In en, this message translates to:
  /// **'Your Internet is private.'**
  String get privateInternet;

  /// No description provided for @connectingStatus.
  ///
  /// In en, this message translates to:
  /// **'CONNECTING...'**
  String get connectingStatus;

  /// No description provided for @attemptingToConnect.
  ///
  /// In en, this message translates to:
  /// **'Attempting to connect.'**
  String get attemptingToConnect;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'STATUS UNKNOWN'**
  String get statusUnknown;

  /// No description provided for @couldNotGetStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not get a valid status.'**
  String get couldNotGetStatus;

  /// No description provided for @errorWarpCliNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Error: warp-cli is not installed.'**
  String get errorWarpCliNotInstalled;

  /// Error message from stderr.
  ///
  /// In en, this message translates to:
  /// **'Error: {stderr}'**
  String errorResultStderr(String stderr);

  /// No description provided for @errorWarpCliFailed.
  ///
  /// In en, this message translates to:
  /// **'Error: The warp-cli command failed.'**
  String get errorWarpCliFailed;

  /// No description provided for @doh.
  ///
  /// In en, this message translates to:
  /// **'DoH'**
  String get doh;

  /// No description provided for @warpDoh.
  ///
  /// In en, this message translates to:
  /// **'WARP + DoH'**
  String get warpDoh;

  /// No description provided for @dot.
  ///
  /// In en, this message translates to:
  /// **'DoT'**
  String get dot;

  /// No description provided for @warpDot.
  ///
  /// In en, this message translates to:
  /// **'WARP + DoT'**
  String get warpDot;

  /// No description provided for @proxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get proxy;

  /// No description provided for @tunnelOnly.
  ///
  /// In en, this message translates to:
  /// **'Tunnel Only'**
  String get tunnelOnly;

  /// No description provided for @aboutCloudflare.
  ///
  /// In en, this message translates to:
  /// **'About Cloudflare'**
  String get aboutCloudflare;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @thirdPartyLicenses.
  ///
  /// In en, this message translates to:
  /// **'Third party licenses'**
  String get thirdPartyLicenses;

  /// Version of the application.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2023 Cloudflare, Inc.'**
  String get copyright;

  /// No description provided for @registrationSettings.
  ///
  /// In en, this message translates to:
  /// **'Registration Settings'**
  String get registrationSettings;

  /// No description provided for @showRegistrationInfo.
  ///
  /// In en, this message translates to:
  /// **'Show registration info'**
  String get showRegistrationInfo;

  /// No description provided for @deleteCurrentRegistration.
  ///
  /// In en, this message translates to:
  /// **'Delete current registration'**
  String get deleteCurrentRegistration;

  /// No description provided for @registerNewClient.
  ///
  /// In en, this message translates to:
  /// **'Register new client'**
  String get registerNewClient;

  /// No description provided for @registrationInfo.
  ///
  /// In en, this message translates to:
  /// **'Registration Info'**
  String get registrationInfo;

  /// No description provided for @dnsSettings.
  ///
  /// In en, this message translates to:
  /// **'DNS Settings'**
  String get dnsSettings;

  /// No description provided for @showDnsStats.
  ///
  /// In en, this message translates to:
  /// **'Show DNS stats'**
  String get showDnsStats;

  /// No description provided for @showDefaultFallbacks.
  ///
  /// In en, this message translates to:
  /// **'Show default fallbacks'**
  String get showDefaultFallbacks;

  /// No description provided for @toggleDnsLogging.
  ///
  /// In en, this message translates to:
  /// **'Toggle DNS logging'**
  String get toggleDnsLogging;

  /// No description provided for @setFallbackDomain.
  ///
  /// In en, this message translates to:
  /// **'Set Fallback Domain'**
  String get setFallbackDomain;

  /// No description provided for @dnsStats.
  ///
  /// In en, this message translates to:
  /// **'DNS Stats'**
  String get dnsStats;

  /// No description provided for @defaultDnsFallbacks.
  ///
  /// In en, this message translates to:
  /// **'Default DNS Fallbacks'**
  String get defaultDnsFallbacks;

  /// No description provided for @proxySettings.
  ///
  /// In en, this message translates to:
  /// **'Proxy Settings'**
  String get proxySettings;

  /// No description provided for @setProxyPort.
  ///
  /// In en, this message translates to:
  /// **'Set Proxy Port'**
  String get setProxyPort;

  /// No description provided for @setPort.
  ///
  /// In en, this message translates to:
  /// **'Set Port'**
  String get setPort;

  /// No description provided for @trustedNetworks.
  ///
  /// In en, this message translates to:
  /// **'Trusted Networks'**
  String get trustedNetworks;

  /// No description provided for @showStatistics.
  ///
  /// In en, this message translates to:
  /// **'Show Statistics'**
  String get showStatistics;

  /// No description provided for @tunnelSettings.
  ///
  /// In en, this message translates to:
  /// **'Tunnel Settings'**
  String get tunnelSettings;

  /// No description provided for @vnetSettings.
  ///
  /// In en, this message translates to:
  /// **'VNet Settings'**
  String get vnetSettings;

  /// No description provided for @debugMenu.
  ///
  /// In en, this message translates to:
  /// **'Debug Menu'**
  String get debugMenu;

  /// No description provided for @showNetworkInfo.
  ///
  /// In en, this message translates to:
  /// **'Show Network Info'**
  String get showNetworkInfo;

  /// No description provided for @showPostureInfo.
  ///
  /// In en, this message translates to:
  /// **'Show Posture Info'**
  String get showPostureInfo;

  /// No description provided for @showDexData.
  ///
  /// In en, this message translates to:
  /// **'Show DEX data'**
  String get showDexData;

  /// No description provided for @toggleConnectivityCheck.
  ///
  /// In en, this message translates to:
  /// **'Toggle connectivity check'**
  String get toggleConnectivityCheck;

  /// No description provided for @networkInfo.
  ///
  /// In en, this message translates to:
  /// **'Network Info'**
  String get networkInfo;

  /// No description provided for @postureInfo.
  ///
  /// In en, this message translates to:
  /// **'Posture Info'**
  String get postureInfo;

  /// No description provided for @dexData.
  ///
  /// In en, this message translates to:
  /// **'DEX Data'**
  String get dexData;

  /// No description provided for @connectivityCheck.
  ///
  /// In en, this message translates to:
  /// **'Connectivity Check'**
  String get connectivityCheck;

  /// No description provided for @tunnelStats.
  ///
  /// In en, this message translates to:
  /// **'Tunnel Stats'**
  String get tunnelStats;

  /// No description provided for @rotateTunnelKeys.
  ///
  /// In en, this message translates to:
  /// **'Rotate Tunnel Keys'**
  String get rotateTunnelKeys;

  /// No description provided for @virtualNetwork.
  ///
  /// In en, this message translates to:
  /// **'Virtual Network (VNet)'**
  String get virtualNetwork;

  /// Current VNet.
  ///
  /// In en, this message translates to:
  /// **'Current Vnet: {vnet}'**
  String currentVnet(String vnet);

  /// No description provided for @setNewVnet.
  ///
  /// In en, this message translates to:
  /// **'Set New Vnet'**
  String get setNewVnet;

  /// No description provided for @setVnet.
  ///
  /// In en, this message translates to:
  /// **'Set VNet'**
  String get setVnet;

  /// No description provided for @vnetSet.
  ///
  /// In en, this message translates to:
  /// **'VNet Set'**
  String get vnetSet;

  /// Confirmation message after setting a new VNet.
  ///
  /// In en, this message translates to:
  /// **'New VNet has been set to {newVnet}'**
  String newVnetSet(String newVnet);

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from Cloudflare Zero Trust?'**
  String get confirmLogout;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'After the logout, you will be disassociated from Cloudflare Zero Trust.'**
  String get logoutDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm logout'**
  String get confirmLogoutButton;

  /// No description provided for @environmentSettings.
  ///
  /// In en, this message translates to:
  /// **'Environment Settings'**
  String get environmentSettings;

  /// No description provided for @setNewEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Set new environment'**
  String get setNewEnvironment;

  /// No description provided for @setButton.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setButton;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @environmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Environment Status'**
  String get environmentStatus;

  /// No description provided for @mdmConfigs.
  ///
  /// In en, this message translates to:
  /// **'MDM Configurations'**
  String get mdmConfigs;

  /// No description provided for @getMdmConfigs.
  ///
  /// In en, this message translates to:
  /// **'Get MDM configs'**
  String get getMdmConfigs;

  /// No description provided for @overrideSettings.
  ///
  /// In en, this message translates to:
  /// **'Override Settings'**
  String get overrideSettings;

  /// No description provided for @showOverrides.
  ///
  /// In en, this message translates to:
  /// **'Show overrides'**
  String get showOverrides;

  /// No description provided for @unlockPolicies.
  ///
  /// In en, this message translates to:
  /// **'Unlock policies'**
  String get unlockPolicies;

  /// No description provided for @localNetworkOverride.
  ///
  /// In en, this message translates to:
  /// **'Local Network Override'**
  String get localNetworkOverride;

  /// No description provided for @overrideStatus.
  ///
  /// In en, this message translates to:
  /// **'Override Status'**
  String get overrideStatus;

  /// No description provided for @targets.
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get targets;

  /// No description provided for @listAllTargets.
  ///
  /// In en, this message translates to:
  /// **'List all targets'**
  String get listAllTargets;

  /// No description provided for @showCertificates.
  ///
  /// In en, this message translates to:
  /// **'Show Certificates'**
  String get showCertificates;

  /// No description provided for @accountCertificates.
  ///
  /// In en, this message translates to:
  /// **'Account Certificates'**
  String get accountCertificates;

  /// No description provided for @allowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get allowAccess;

  /// No description provided for @showAccess.
  ///
  /// In en, this message translates to:
  /// **'Show access'**
  String get showAccess;

  /// No description provided for @stopAccess.
  ///
  /// In en, this message translates to:
  /// **'Stop access'**
  String get stopAccess;

  /// No description provided for @localNetworkStatus.
  ///
  /// In en, this message translates to:
  /// **'Local Network Status'**
  String get localNetworkStatus;

  /// No description provided for @trustedSsids.
  ///
  /// In en, this message translates to:
  /// **'Trusted SSIDs'**
  String get trustedSsids;

  /// No description provided for @listSsids.
  ///
  /// In en, this message translates to:
  /// **'List SSIDs'**
  String get listSsids;

  /// No description provided for @addSsid.
  ///
  /// In en, this message translates to:
  /// **'Add SSID'**
  String get addSsid;

  /// No description provided for @removeSsid.
  ///
  /// In en, this message translates to:
  /// **'Remove SSID'**
  String get removeSsid;

  /// No description provided for @resetSsids.
  ///
  /// In en, this message translates to:
  /// **'Reset SSIDs'**
  String get resetSsids;

  /// No description provided for @enterSsidName.
  ///
  /// In en, this message translates to:
  /// **'Enter SSID Name'**
  String get enterSsidName;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @warpControlScreenText.
  ///
  /// In en, this message translates to:
  /// **'CLOUDFLARE WARP'**
  String get warpControlScreenText;

  /// No description provided for @legalNoticeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice and Confirmation'**
  String get legalNoticeConfirmation;

  /// No description provided for @importantInfoPanel.
  ///
  /// In en, this message translates to:
  /// **'Important Information About the Panel'**
  String get importantInfoPanel;

  /// No description provided for @appDescription1.
  ///
  /// In en, this message translates to:
  /// **'This app is a graphical control panel (GUI) developed by a user to make it easier to interact with the official Cloudflare WARP program on Linux. It is NOT the official Cloudflare application.'**
  String get appDescription1;

  /// No description provided for @appDescription2.
  ///
  /// In en, this message translates to:
  /// **'For this panel to work properly, it is ESSENTIAL that you have the official Cloudflare WARP for Linux installed on your system. This project DOES NOT collect ANY user data. Responsibility for the operation, privacy, and security of your internet traffic lies entirely with Cloudflare, as this panel only sends commands to the already installed official WARP program.'**
  String get appDescription2;

  /// No description provided for @confirmationText.
  ///
  /// In en, this message translates to:
  /// **'By clicking \"I understand\", you confirm that you have read, understood, and accepted the above terms. Your confirmation will be saved locally on your device, and this notice will not be shown again on future launches of the panel.'**
  String get confirmationText;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstand;

  /// No description provided for @savingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Starting the process of saving confirmation...'**
  String get savingConfirmation;

  /// Message with the application support directory path.
  ///
  /// In en, this message translates to:
  /// **'Application support directory found: {path}'**
  String appSupportDirFound(String path);

  /// Message with the preferences directory path.
  ///
  /// In en, this message translates to:
  /// **'Attempting to check if the preferences directory exists: {path}'**
  String checkingPrefsDir(String path);

  /// No description provided for @dirDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Directory does not exist. Attempting to create...'**
  String get dirDoesNotExist;

  /// No description provided for @prefsDirCreated.
  ///
  /// In en, this message translates to:
  /// **'Preferences directory created successfully.'**
  String get prefsDirCreated;

  /// No description provided for @prefsDirExists.
  ///
  /// In en, this message translates to:
  /// **'Preferences directory already exists.'**
  String get prefsDirExists;

  /// No description provided for @hasSeenLegalNoticeSaved.
  ///
  /// In en, this message translates to:
  /// **'The hasSeenLegalNotice preference has been saved successfully.'**
  String get hasSeenLegalNoticeSaved;

  /// No description provided for @navigationInitiated.
  ///
  /// In en, this message translates to:
  /// **'Navigation to the main screen initiated.'**
  String get navigationInitiated;

  /// Fatal error message for saving preferences.
  ///
  /// In en, this message translates to:
  /// **'FATAL ERROR: Failed to save preference or create directory. Details: {error}'**
  String fatalErrorSavePref(String error);

  /// Error message for reading network stats.
  ///
  /// In en, this message translates to:
  /// **'ERROR: Failed to read network statistics files: {error}.'**
  String errorReadNetworkStats(String error);

  /// No description provided for @currentSpeed.
  ///
  /// In en, this message translates to:
  /// **'Current Speed'**
  String get currentSpeed;

  /// No description provided for @totalDataTransferred.
  ///
  /// In en, this message translates to:
  /// **'Total Data Transferred'**
  String get totalDataTransferred;

  /// No description provided for @resetCounters.
  ///
  /// In en, this message translates to:
  /// **'Reset Counters'**
  String get resetCounters;

  /// No description provided for @connectedViaWarp.
  ///
  /// In en, this message translates to:
  /// **'Connected via WARP'**
  String get connectedViaWarp;

  /// No description provided for @notConnectedViaWarp.
  ///
  /// In en, this message translates to:
  /// **'Not connected via WARP'**
  String get notConnectedViaWarp;

  /// Current download speed.
  ///
  /// In en, this message translates to:
  /// **'Download: {speed}'**
  String downloadSpeed(String speed);

  /// Current upload speed.
  ///
  /// In en, this message translates to:
  /// **'Upload: {speed}'**
  String uploadSpeed(String speed);

  /// No description provided for @warpSection.
  ///
  /// In en, this message translates to:
  /// **'WARP'**
  String get warpSection;

  /// Total download data via WARP.
  ///
  /// In en, this message translates to:
  /// **'Download: {data}'**
  String warpDownload(String data);

  /// Total upload data via WARP.
  ///
  /// In en, this message translates to:
  /// **'Upload: {data}'**
  String warpUpload(String data);

  /// No description provided for @outsideWarp.
  ///
  /// In en, this message translates to:
  /// **'Outside WARP'**
  String get outsideWarp;

  /// Total download data outside of WARP.
  ///
  /// In en, this message translates to:
  /// **'Download: {data}'**
  String outsideWarpDownload(String data);

  /// Total upload data outside of WARP.
  ///
  /// In en, this message translates to:
  /// **'Upload: {data}'**
  String outsideWarpUpload(String data);

  /// No description provided for @trustedNetworksDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted Networks'**
  String get trustedNetworksDialogTitle;

  /// No description provided for @manageTrustedSsids.
  ///
  /// In en, this message translates to:
  /// **'Manage trusted SSIDs'**
  String get manageTrustedSsids;

  /// No description provided for @toggleTrustedEthernet.
  ///
  /// In en, this message translates to:
  /// **'Toggle trusted Ethernet'**
  String get toggleTrustedEthernet;

  /// No description provided for @toggleTrustedWifi.
  ///
  /// In en, this message translates to:
  /// **'Toggle trusted Wi-Fi'**
  String get toggleTrustedWifi;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @targetList.
  ///
  /// In en, this message translates to:
  /// **'Target List'**
  String get targetList;

  /// No description provided for @logoutFromZeroTrust.
  ///
  /// In en, this message translates to:
  /// **'Logout from Zero Trust'**
  String get logoutFromZeroTrust;

  /// No description provided for @reauthenticateSession.
  ///
  /// In en, this message translates to:
  /// **'Re-authenticate session'**
  String get reauthenticateSession;

  /// No description provided for @aboutZeroTrust.
  ///
  /// In en, this message translates to:
  /// **'About Zero Trust'**
  String get aboutZeroTrust;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
