/// MR HELPER - Web Application Security Analyzer
/// Lightweight, type-safe localization (English + Central Kurdish / Sorani).
///
/// Each string is a getter that returns the right language, so there are no
/// missing-key runtime surprises — if a getter exists it has both languages.
/// Technical security terms (CSP, HSTS, header names, etc.) are intentionally
/// kept in English in both languages.
library;

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/providers/locale_provider.dart';

enum AppLang { en, ckb }

class AppStrings {
  final AppLang lang;
  const AppStrings(this.lang);

  /// Convenience accessor from any widget: `AppStrings.of(context)`.
  static AppStrings of(BuildContext context) =>
      context.watch<LocaleProvider>().strings;

  bool get isRtl => lang == AppLang.ckb;

  String _t(String en, String ckb) => lang == AppLang.ckb ? ckb : en;

  // --- Generic --------------------------------------------------------------
  String get appTagline => _t('Web Security Analyzer', 'شیکارکەری ئەمنیەتی وێب');
  String get tryAgain => _t('TRY AGAIN', 'دووبارە هەوڵبدەوە');
  String get retry => _t('RETRY', 'دووبارە');
  String get cancel => _t('CANCEL', 'هەڵوەشاندنەوە');
  String get delete => _t('DELETE', 'سڕینەوە');
  String get refresh => _t('Refresh', 'نوێکردنەوە');
  String get language => _t('Language', 'زمان');
  String get english => _t('English', 'ئینگلیزی');
  String get kurdish => _t('Kurdish', 'کوردی');

  // --- Risk levels (stored as English constants; translate at display) ------
  String risk(String value) {
    switch (value) {
      case 'Low Risk':
        return _t('Low Risk', 'مەترسی نزم');
      case 'Medium Risk':
        return _t('Medium Risk', 'مەترسی مامناوەند');
      case 'High Risk':
        return _t('High Risk', 'مەترسی بەرز');
      case 'Critical Risk':
        return _t('Critical Risk', 'مەترسی زۆر بەرز');
      default:
        return value;
    }
  }

  // --- Home -----------------------------------------------------------------
  String get startSecurityScan =>
      _t('START SECURITY SCAN', 'دەستپێکردنی سکانی ئەمنیەتی');
  String get enterUrlToAnalyze => _t(
      'Enter a URL to analyze its security posture',
      'ناونیشانێک بنووسە بۆ شیکردنەوەی ئاستی ئەمنیەتی');
  String get overview => _t('OVERVIEW', 'پوختە');
  String get totalScans => _t('Total Scans', 'کۆی سکانەکان');
  String get avgScore => _t('Avg Score', 'تێکڕای نمرە');
  String get recentScans => _t('RECENT SCANS', 'سکانە نوێیەکان');
  String get viewAll => _t('VIEW ALL', 'بینینی هەموو');
  String get noScansYet => _t('No scans yet', 'هێشتا هیچ سکانێک نییە');
  String get startFirstScan =>
      _t('Start your first security scan!', 'یەکەم سکانی ئەمنیەتیت بکە!');
  String get quickActions => _t('QUICK ACTIONS', 'کردارە خێراکان');
  String get history => _t('History', 'مێژوو');
  String get statistics => _t('Statistics', 'ئامارەکان');
  String get about => _t('About', 'دەربارە');

  // --- Scanner screen -------------------------------------------------------
  String get securityScanner => _t('SECURITY SCANNER', 'سکانەری ئەمنیەتی');
  String get enterTargetUrl => _t('ENTER TARGET URL', 'ناونیشانی ئامانج بنووسە');
  String get startScan => _t('START SCAN', 'دەستپێکردنی سکان');
  String get scanning => _t('SCANNING...', 'سکان دەکرێت...');
  String get whatWeCheck => _t('WHAT WE CHECK', 'چی دەپشکنین');
  String get httpsAvailability =>
      _t('HTTPS Availability', 'بەردەستبوونی HTTPS');
  String get securityHeaders => _t(
      'Security Headers (CSP, HSTS, etc.)',
      'هێدەرە ئەمنیەتییەکان (CSP, HSTS, هتد)');
  String get cookieSecurity => _t(
      'Cookie Security (Secure, HttpOnly)',
      'ئەمنیەتی کووکی (Secure, HttpOnly)');
  String get riskClassification =>
      _t('Risk Classification & Scoring', 'پۆلێنکردنی مەترسی و نمرەدان');
  String get scanFailed => _t('SCAN FAILED', 'سکان سەرکەوتوو نەبوو');
  String get scanInProgress =>
      _t('SCANNING IN PROGRESS', 'سکان لە ئارادایە');
  String get analyzingConfig => _t(
      'Analyzing security headers and configuration...',
      'شیکردنەوەی هێدەر و ڕێکخستنە ئەمنیەتییەکان...');
  String get checkingHttps => _t('Checking HTTPS', 'پشکنینی HTTPS');
  String get analyzingHeaders =>
      _t('Analyzing Security Headers', 'شیکردنەوەی هێدەرە ئەمنیەتییەکان');
  String get inspectingCookies =>
      _t('Inspecting Cookies', 'وردبینی کووکییەکان');
  String get calculatingScore =>
      _t('Calculating Security Score', 'هەژمارکردنی نمرەی ئەمنیەتی');
  String get readyToScan => _t('READY TO SCAN', 'ئامادەیە بۆ سکان');
  String get enterUrlAbovePrompt => _t(
      'Enter a URL above and press Start Scan',
      'ناونیشانێک لە سەرەوە بنووسە و دەستپێکردنی سکان دابگرە');

  // --- Report screen --------------------------------------------------------
  String get securityReport => _t('SECURITY REPORT', 'ڕاپۆرتی ئەمنیەتی');
  String get securityScore => _t('SECURITY SCORE', 'نمرەی ئەمنیەتی');
  String get targetInformation => _t('TARGET INFORMATION', 'زانیاری ئامانج');
  String get securityHeadersTitle =>
      _t('SECURITY HEADERS', 'هێدەرە ئەمنیەتییەکان');
  String get cookieAnalysis => _t('COOKIE ANALYSIS', 'شیکاری کووکی');
  String get serverCertificate =>
      _t('SERVER & CERTIFICATE', 'سێرڤەر و سێرتیفیکەیت');
  String get summary => _t('SUMMARY', 'کورتە');
  String get findings => _t('FINDINGS', 'دۆزراوەکان');
  String get noIssues => _t('Excellent! No security issues were detected.',
      'نایاب! هیچ کێشەیەکی ئەمنیەتی نەدۆزرایەوە.');
  String get shareReport => _t('Share PDF report', 'هاوبەشکردنی ڕاپۆرتی PDF');
  String get generatingPdf =>
      _t('Generating PDF report...', 'دروستکردنی ڕاپۆرتی PDF...');
  String get couldNotPdf =>
      _t('Could not generate PDF', 'نەتوانرا PDF دروست بکرێت');
  String issueCount(int n) => _t('$n issue(s)', '$n کێشە');
  // Target info rows
  String get urlLabel => _t('URL', 'ناونیشان');
  String get domainLabel => _t('Domain', 'دۆمەین');
  String get httpsLabel => _t('HTTPS', 'HTTPS');
  String get enabled => _t('Enabled', 'چالاک');
  String get disabled => _t('Disabled', 'ناچالاک');
  String get scannedLabel => _t('Scanned', 'سکانکراو');
  // Header descriptions
  String get cspDesc => _t('Controls resources the browser is allowed to load',
      'کۆنترۆڵی ئەو سەرچاوانە دەکات کە بڕاوزەر بۆی هەیە بارکردنیان');
  String get hstsDesc =>
      _t('Forces HTTPS connections', 'بەزۆر پەیوەندی HTTPS دەکات');
  String get xFrameDesc => _t('Prevents clickjacking attacks',
      'ڕێگری لە هێرشی clickjacking دەکات');
  String get xContentDesc =>
      _t('Prevents MIME type sniffing', 'ڕێگری لە MIME sniffing دەکات');
  String get referrerDesc => _t('Controls referrer information',
      'کۆنترۆڵی زانیاری referrer دەکات');
  String get permissionsDesc =>
      _t('Controls browser features', 'کۆنترۆڵی تایبەتمەندی بڕاوزەر دەکات');
  // Cookie section
  String get cookiesPresent => _t('Cookies Present', 'کووکی هەیە');
  String cookiesFound(int n) => _t('$n cookie(s) found', '$n کووکی دۆزرایەوە');
  String get noCookiesDetected =>
      _t('No cookies detected', 'هیچ کووکییەک نەدۆزرایەوە');
  String get secureFlag => _t('Secure Flag', 'ئاڵای Secure');
  String get cookiesHttpsOnly =>
      _t('Cookies sent over HTTPS only', 'کووکی تەنها بەسەر HTTPS دەنێردرێت');
  String get missingSecureFlag =>
      _t('Missing Secure flag', 'ئاڵای Secure نییە');
  String get httpOnlyFlag => _t('HttpOnly Flag', 'ئاڵای HttpOnly');
  String get cookiesNoJs => _t('Cookies not accessible via JavaScript',
      'کووکی لەڕێگەی JavaScript دەستناکەوێت');
  String get missingHttpOnly =>
      _t('Missing HttpOnly flag', 'ئاڵای HttpOnly نییە');
  String get sameSitePolicy => _t('SameSite Policy', 'سیاسەتی SameSite');
  // Server section
  String get serverLabel => _t('Server', 'سێرڤەر');
  String get poweredByLabel => _t('Powered By', 'پاڵپشتیکراو بە');
  String get certificateLabel => _t('Certificate', 'سێرتیفیکەیت');
  String get valid => _t('Valid', 'دروست');
  String get invalid => _t('Invalid', 'نادروست');
  String get issuerLabel => _t('Issuer', 'دەرکەر');
  String get expiresInLabel => _t('Expires in', 'بەسەردەچێت لە');
  String daysValue(int n) => _t('$n days', '$n ڕۆژ');
  // Summary
  String get gradeLabel => _t('Grade', 'پلە');
  String get scoreLabel => _t('Score', 'نمرە');
  String get riskLabel => _t('Risk', 'مەترسی');
  String get headersLabel => _t('Headers', 'هێدەرەکان');

  // --- History --------------------------------------------------------------
  String get scanHistory => _t('SCAN HISTORY', 'مێژووی سکان');
  String get deleteScanTitle => _t('Delete Scan', 'سڕینەوەی سکان');
  String deleteScanConfirm(String url) => _t(
      'Are you sure you want to delete the scan for\n$url?',
      'دڵنیایت دەتەوێت سکانی\n$url بسڕیتەوە؟');
  String get scanDeleted =>
      _t('Scan deleted successfully', 'سکان بە سەرکەوتوویی سڕایەوە');
  String get failedDelete => _t('Failed to delete', 'سڕینەوە سەرکەوتوو نەبوو');
  String get sortByDate => _t('Sort by date', 'ڕیزکردن بەپێی بەروار');
  String get failedLoadHistory =>
      _t('Failed to Load History', 'بارکردنی مێژوو سەرکەوتوو نەبوو');
  String get noScanHistory => _t('No Scan History', 'هیچ مێژوویەکی سکان نییە');
  String get historyWillAppear => _t(
      'Your security scan results will appear here',
      'ئەنجامەکانی سکانی ئەمنیەتیت لێرە دەردەکەون');
  String get startAScan => _t('START A SCAN', 'سکانێک بکە');

  // --- Statistics -----------------------------------------------------------
  String get statisticsTitle => _t('STATISTICS', 'ئامارەکان');
  String get riskDistribution => _t('RISK DISTRIBUTION', 'دابەشبوونی مەترسی');
  String get noRiskData =>
      _t('No risk data available', 'هیچ داتای مەترسی بەردەست نییە');
  String get mostScanned =>
      _t('MOST SCANNED WEBSITES', 'زۆرترین وێبسایتی سکانکراو');
  String get noScanDataYet =>
      _t('No scan data yet', 'هێشتا هیچ داتایەکی سکان نییە');

  // --- About ----------------------------------------------------------------
  String get aboutTitle => _t('ABOUT', 'دەربارە');
  String get flutterDeveloper => _t('Flutter Developer', 'گەشەپێدەری Flutter');
  String get cyberEnthusiast =>
      _t('Cybersecurity Enthusiast', 'حەزلێبووی ئەمنیەتی سایبەری');
  String get descriptionTitle => _t('DESCRIPTION', 'وەسف');
  String get appDescriptionText => _t(
      'A professional mobile cybersecurity tool that analyzes website security '
          'headers, checks for vulnerabilities, and provides actionable security recommendations.',
      'ئامرازێکی پڕۆفیشناڵی ئەمنیەتی سایبەری مۆبایل کە هێدەرە ئەمنیەتییەکانی '
          'وێبسایت شی دەکاتەوە، بۆ لاوازییەکان دەپشکنێت، و پێشنیاری ئەمنیەتی کرداری دەداتە دەستەوە.');
  String get keyFeatures => _t('KEY FEATURES', 'تایبەتمەندییە سەرەکییەکان');
  String get featureHeadersTitle =>
      _t('Security Header Analysis', 'شیکاری هێدەری ئەمنیەتی');
  String get featureHeadersDesc => _t(
      'Check CSP, HSTS, X-Frame-Options and more',
      'پشکنینی CSP، HSTS، X-Frame-Options و زیاتر');
  String get featureCookieTitle =>
      _t('Cookie Security Audit', 'هەڵسەنگاندنی ئەمنیەتی کووکی');
  String get featureCookieDesc => _t(
      'Analyze Secure, HttpOnly, and SameSite flags',
      'شیکردنەوەی ئاڵاکانی Secure، HttpOnly و SameSite');
  String get featureScoreTitle =>
      _t('Security Scoring Engine', 'بزوێنەری نمرەی ئەمنیەتی');
  String get featureScoreDesc => _t(
      '0-100 score with letter grades A through F',
      'نمرەی ٠-١٠٠ لەگەڵ پلەی پیتی A بۆ F');
  String get featureRiskTitle =>
      _t('Risk Classification', 'پۆلێنکردنی مەترسی');
  String get featureRiskDesc => _t(
      'Low, Medium, High, and Critical risk levels',
      'ئاستەکانی مەترسی نزم، مامناوەند، بەرز و زۆر بەرز');
  String get featureCloudTitle => _t('Cloud History', 'مێژووی هەوری');
  String get featureCloudDesc => _t(
      'All scans stored securely in Firebase Firestore',
      'هەموو سکانەکان بە پارێزراوی لە Firebase Firestore هەڵدەگیرێن');
  String get technicalDetails => _t('TECHNICAL DETAILS', 'وردەکاری تەکنیکی');
  String get frameworkLabel => _t('Framework', 'چوارچێوە');
  String get backendLabel => _t('Backend', 'باکئێند');
  String get stateMgmtLabel => _t('State Management', 'بەڕێوەبردنی دۆخ');
  String get architectureLabel => _t('Architecture', 'تەلارسازی');
  String get chartsLabel => _t('Charts', 'هێڵکارییەکان');
  String get httpClientLabel => _t('HTTP Client', 'HTTP Client');
  String get cleanArchitecture =>
      _t('Clean Architecture', 'Clean Architecture');
  String madeWith(String name) =>
      _t('Made with ❤️ by $name', 'دروستکراوە بە ❤️ لەلایەن $name');
  String get allRightsReserved =>
      _t('All Rights Reserved', 'هەموو مافەکان پارێزراون');

  // --- Splash ---------------------------------------------------------------
  String get webSecurityAnalyzerCaps =>
      _t('WEB SECURITY ANALYZER', 'شیکارکەری ئەمنیەتی وێب');
  String get securingTheWeb => _t('Securing the web, one scan at a time',
      'پاراستنی وێب، سکانێک لە کاتدا');
  String get initializing => _t('INITIALIZING...', 'دەستپێدەکات...');

  // --- Settings -------------------------------------------------------------
  String get settings => _t('SETTINGS', 'ڕێکخستنەکان');
  String get appearance => _t('APPEARANCE', 'ڕووکار');
  String get darkMode => _t('Dark Mode', 'دۆخی تاریک');
  String get toggleDarkTheme =>
      _t('Toggle dark theme', 'گۆڕینی دۆخی تاریک');
  String get application => _t('APPLICATION', 'ئەپلیکەیشن');
  String get aboutSubtitle =>
      _t('App information and version', 'زانیاری ئەپ و وەشان');
  String get versionLabel => _t('Version', 'وەشان');
  String get appPurpose => _t('App Purpose', 'مەبەستی ئەپ');
  String get appPurposeValue =>
      _t('Web Security Analysis Tool', 'ئامرازی شیکاری ئەمنیەتی وێب');
  String get developerSection => _t('DEVELOPER', 'گەشەپێدەر');
  String get developerLabel => _t('Developer', 'گەشەپێدەر');
  String get roleLabel => _t('Role', 'ڕۆڵ');
  String get techStackLabel => _t('Tech Stack', 'تەکنەلۆجیا');
  String get dataSection => _t('DATA', 'داتا');
  String get firebaseSync => _t('Firebase Sync', 'هاوکاتکردنی Firebase');
  String get firebaseSyncValue => _t('Data stored in Firebase Firestore',
      'داتا لە Firebase Firestore هەڵدەگیرێت');
  String get privacyLabel => _t('Privacy', 'تایبەتمەندی');
  String get privacyValue => _t('Only scanned URLs are stored',
      'تەنها ناونیشانە سکانکراوەکان هەڵدەگیرێن');
  String get developerRoleValue => _t(
      'Flutter Developer & Cybersecurity Enthusiast',
      'گەشەپێدەری Flutter و حەزلێبووی ئەمنیەتی سایبەری');
}
