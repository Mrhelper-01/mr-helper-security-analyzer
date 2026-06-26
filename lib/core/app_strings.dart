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
import 'package:mr_helper_security_analyzer/models/security_finding.dart';
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
  // App-wide bottom navigation
  String get navHome => _t('Home', 'سەرەتا');
  String get navScan => _t('Scan', 'سکان');
  String get navSettings => _t('Settings', 'ڕێکخستن');
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
  // Report bottom navigation
  String get navOverview => _t('Overview', 'پوختە');
  String get navHeaders => _t('Headers', 'هێدەر');
  String get navTech => _t('Tech', 'تەکنەلۆجیا');
  String get navDns => _t('DNS', 'DNS');
  String get navMore => _t('More', 'زیاتر');
  String get securityScore => _t('SECURITY SCORE', 'نمرەی ئەمنیەتی');
  String get targetInformation => _t('TARGET INFORMATION', 'زانیاری ئامانج');
  String get securityHeadersTitle =>
      _t('SECURITY HEADERS', 'هێدەرە ئەمنیەتییەکان');
  String get cookieAnalysis => _t('COOKIE ANALYSIS', 'شیکاری کووکی');
  String get serverCertificate =>
      _t('SERVER & CERTIFICATE', 'سێرڤەر و سێرتیفیکەیت');
  String get dnsEmailSecurity =>
      _t('DNS & EMAIL SECURITY', 'ئەمنیەتی DNS و ئیمەیڵ');
  String get spfLabel => _t('SPF', 'SPF');
  String get dmarcLabel => _t('DMARC', 'DMARC');
  String get mxLabel => _t('Mail (MX)', 'ئیمەیڵ (MX)');
  String get foundLabel => _t('Found', 'هەیە');
  String get notFoundLabel => _t('Not found', 'نییە');
  String get viewDetails => _t('View details', 'بینینی وردەکاری');
  // DNS & Email detail page
  String get dnsEmailTitle =>
      _t('DNS & Email Security', 'ئەمنیەتی DNS و ئیمەیڵ');
  String get dnsConfiguration => _t('DNS Configuration', 'ڕێکخستنی DNS');
  String get wellConfigured => _t('Well Configured', 'باش ڕێکخراوە');
  String get issuesFound => _t('Issues found', 'کێشە دۆزرایەوە');
  String get aRecord => _t('A Record', 'ڕیکۆردی A');
  String get mxRecord => _t('MX Record', 'ڕیکۆردی MX');
  String get nsRecord => _t('NS Record', 'ڕیکۆردی NS');
  String get txtRecord => _t('TXT Record', 'ڕیکۆردی TXT');
  String get emailSecurity => _t('Email Security', 'ئەمنیەتی ئیمەیڵ');
  String get spfFull =>
      _t('SPF (Sender Policy Framework)', 'SPF (Sender Policy Framework)');
  String get dkimFull =>
      _t('DKIM (DomainKeys Identified Mail)', 'DKIM (DomainKeys Identified Mail)');
  String get dmarcFull => _t(
      'DMARC (Domain-based Message Auth, Reporting & Conformance)',
      'DMARC (Domain-based Message Auth, Reporting & Conformance)');
  String get validSpf => _t('Valid SPF record found', 'ڕیکۆردی SPF ـی دروست هەیە');
  String get noSpf => _t('No SPF record found', 'هیچ ڕیکۆردی SPF نییە');
  String get validDkim =>
      _t('Valid DKIM record found', 'ڕیکۆردی DKIM ـی دروست هەیە');
  String get noDkim => _t('No DKIM record found', 'هیچ ڕیکۆردی DKIM نییە');
  String get validDmarc =>
      _t('Valid DMARC record found', 'ڕیکۆردی DMARC ـی دروست هەیە');
  String get noDmarc => _t('No DMARC record found', 'هیچ ڕیکۆردی DMARC نییە');
  String get pass => _t('PASS', 'سەرکەوتوو');
  String get fail => _t('FAIL', 'شکست');
  String policyLine(String p) => _t('Policy: $p', 'سیاسەت: $p');
  String get domainProtected => _t(
      'Your domain is protected against email spoofing and phishing.',
      'دۆمەینەکەت پارێزراوە بەرامبەر ساختەکاری ئیمەیڵ و فیشینگ.');
  String get domainNotProtected => _t(
      'Your domain may be vulnerable to email spoofing. Configure SPF, DKIM and DMARC.',
      'دۆمەینەکەت لەوانەیە بەرامبەر ساختەکاری ئیمەیڵ لاواز بێت. SPF، DKIM و DMARC ڕێکبخە.');
  String get summary => _t('SUMMARY', 'کورتە');
  String get comparison => _t('COMPARISON', 'بەراورد');
  String get vsPrevious =>
      _t('vs previous scan', 'بەراورد لەگەڵ سکانی پێشوو');
  String get newIssues => _t('New issues', 'کێشەی نوێ');
  String get resolvedIssues => _t('Resolved', 'چارەسەرکراو');
  String get noChange => _t('No change', 'بێ گۆڕان');
  String pointsUp(int n) => _t('+$n points', '+$n خاڵ');
  String pointsDown(int n) => _t('-$n points', '-$n خاڵ');
  String get findings => _t('FINDINGS', 'دۆزراوەکان');
  String get noIssues => _t('Excellent! No security issues were detected.',
      'نایاب! هیچ کێشەیەکی ئەمنیەتی نەدۆزرایەوە.');
  String get shareReport => _t('Share PDF report', 'هاوبەشکردنی ڕاپۆرتی PDF');
  String get monitorSite => _t('Monitor this site', 'چاودێری ئەم سایتە بکە');
  String get monitorStarted => _t(
      'Monitoring on — you will be alerted if security drops.',
      'چاودێری چالاکە — ئاگادار دەکرێیتەوە ئەگەر ئاستی ئەمنیەت دابەزی.');
  String get monitorStopped =>
      _t('Monitoring turned off', 'چاودێری ناچالاک کرا');
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
  String get present => _t('Present', 'هەیە');
  String get missing => _t('Missing', 'نییە');

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
  String get featureDnsTitle =>
      _t('DNS & Email Security', 'ئەمنیەتی DNS و ئیمەیڵ');
  String get featureDnsDesc => _t(
      'Check SPF, DMARC and MX records over DNS-over-HTTPS',
      'پشکنینی ڕیکۆردەکانی SPF، DMARC و MX بە DNS-over-HTTPS');
  String get featureTlsTitle =>
      _t('TLS Certificate Inspection', 'وردبینی سێرتیفیکەیتی TLS');
  String get featureTlsDesc => _t(
      'Validate the certificate, issuer and expiry date',
      'پشتڕاستکردنەوەی سێرتیفیکەیت، دەرکەر و بەرواری بەسەرچوون');
  String get featureDiscoveryTitle =>
      _t('Exposed File Discovery', 'دۆزینەوەی فایلی ئاشکراکراو');
  String get featureDiscoveryDesc => _t(
      'Detect exposed .git, .env and config files',
      'دۆزینەوەی فایلی ئاشکراکراوی .git، .env و ڕێکخستن');
  String get featureMonitorTitle =>
      _t('Continuous Monitoring', 'چاودێری بەردەوام');
  String get featureMonitorDesc => _t(
      'Periodic rescans with alerts when security drops',
      'سکانی دووبارەی کاتی لەگەڵ ئاگادارکردنەوە کاتێک ئەمنیەت دابەزێت');
  String get featureExportTitle =>
      _t('PDF Reports (Kurdish & English)', 'ڕاپۆرتی PDF (کوردی و ئینگلیزی)');
  String get featureExportDesc => _t(
      'Share a full professional report in either language',
      'هاوبەشکردنی ڕاپۆرتێکی پڕۆفیشناڵی تەواو بە هەردوو زمان');
  String get featureLockTitle => _t('Biometric App Lock', 'قوفڵی بایۆمەتری');
  String get featureLockDesc => _t(
      'Protect scan history with fingerprint / PIN',
      'پاراستنی مێژووی سکان بە فینگەرپرینت / PIN');
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

  // --- Findings (localized by code) -----------------------------------------
  String severityLabel(FindingSeverity s) {
    switch (s) {
      case FindingSeverity.critical:
        return _t('Critical', 'مەترسیدار');
      case FindingSeverity.high:
        return _t('High', 'بەرز');
      case FindingSeverity.medium:
        return _t('Medium', 'مامناوەند');
      case FindingSeverity.low:
        return _t('Low', 'نزم');
      case FindingSeverity.info:
        return _t('Info', 'زانیاری');
    }
  }

  String findingTitle(SecurityFinding f) {
    switch (f.code) {
      case FindingCode.noHttps:
        return _t('No HTTPS encryption', 'نهێنیکردنی HTTPS نییە');
      case FindingCode.missingHsts:
        return _t('Missing Strict-Transport-Security (HSTS)',
            'هێدەری HSTS نییە');
      case FindingCode.missingCsp:
        return _t('Missing Content-Security-Policy (CSP)', 'هێدەری CSP نییە');
      case FindingCode.weakCsp:
        return _t('Weak Content-Security-Policy', 'CSP ـی لاواز');
      case FindingCode.missingXFrame:
        return _t('Missing X-Frame-Options', 'هێدەری X-Frame-Options نییە');
      case FindingCode.missingXContent:
        return _t('Missing X-Content-Type-Options',
            'هێدەری X-Content-Type-Options نییە');
      case FindingCode.missingReferrer:
        return _t('Missing Referrer-Policy', 'هێدەری Referrer-Policy نییە');
      case FindingCode.missingPermissions:
        return _t('Missing Permissions-Policy',
            'هێدەری Permissions-Policy نییە');
      case FindingCode.missingCoop:
        return _t('Missing Cross-Origin-Opener-Policy (COOP)',
            'هێدەری COOP نییە');
      case FindingCode.missingCorp:
        return _t('Missing Cross-Origin-Resource-Policy (CORP)',
            'هێدەری CORP نییە');
      case FindingCode.serverDisclosed:
        return _t('Server software disclosed', 'زانیاری سێرڤەر ئاشکراکراوە');
      case FindingCode.cookieNoSecure:
        return _t('Cookie missing Secure flag', 'کووکی ئاڵای Secure ـی نییە');
      case FindingCode.cookieNoHttpOnly:
        return _t('Cookie missing HttpOnly flag',
            'کووکی ئاڵای HttpOnly ـی نییە');
      case FindingCode.cookieSameSiteNone:
        return _t('Cookie SameSite=None', 'کووکی SameSite=None');
      case FindingCode.certInvalid:
        return _t('TLS certificate problem', 'کێشەی سێرتیفیکەیتی TLS');
      case FindingCode.certExpiringSoon:
        return _t('TLS certificate expiring soon',
            'سێرتیفیکەیتی TLS بەمزووانە بەسەردەچێت');
      case FindingCode.missingSpf:
        return _t('Missing SPF record', 'ڕیکۆردی SPF نییە');
      case FindingCode.missingDmarc:
        return _t('Missing DMARC record', 'ڕیکۆردی DMARC نییە');
      case FindingCode.weakDmarc:
        return _t('Weak DMARC policy (p=none)', 'سیاسەتی DMARC ـی لاواز (p=none)');
      case FindingCode.exposedGit:
        return _t('Exposed .git repository', 'مەخزەنی .git ئاشکراکراوە');
      case FindingCode.exposedEnv:
        return _t('Exposed .env file', 'فایلی .env ئاشکراکراوە');
      case FindingCode.exposedConfig:
        return _t('Exposed config file', 'فایلی ڕێکخستن ئاشکراکراوە');
      case FindingCode.missingSecurityTxt:
        return _t('No security.txt', 'فایلی security.txt نییە');
      case FindingCode.permissiveCors:
        return _t('Permissive CORS (Allow-Origin: *)',
            'CORS ـی کراوە (Allow-Origin: *)');
      case FindingCode.missingCoep:
        return _t('Missing Cross-Origin-Embedder-Policy (COEP)',
            'هێدەری COEP نییە');
      case FindingCode.sqlInjection:
        return _t('Possible SQL Injection', 'ئەگەری SQL Injection');
      case FindingCode.other:
        return f.title;
    }
  }

  String findingDescription(SecurityFinding f) {
    switch (f.code) {
      case FindingCode.noHttps:
        return _t(
            'The site is served over plain HTTP. All traffic can be read or modified by anyone on the network.',
            'سایتەکە بەسەر HTTP ـی ساکار خزمەت دەکات. هەموو ترافیکەکە دەتوانرێت لەلایەن هەرکەسێکی سەر تۆڕەکەوە بخوێنرێتەوە یان بگۆڕدرێت.');
      case FindingCode.missingHsts:
        return _t(
            'Without HSTS, browsers may connect over insecure HTTP and are vulnerable to SSL-stripping attacks.',
            'بەبێ HSTS، بڕاوزەرەکان لەوانەیە بەسەر HTTP ـی ناپارێزراو پەیوەندی بکەن و بەرامبەر هێرشی SSL-stripping لاوازن.');
      case FindingCode.missingCsp:
        return _t(
            'CSP is the strongest defense against cross-site scripting (XSS) and data-injection attacks.',
            'CSP بەهێزترین بەرگرییە بەرامبەر هێرشی XSS و تێزڕاندنی داتا.');
      case FindingCode.weakCsp:
        return _t(
            "The CSP allows 'unsafe-inline' or 'unsafe-eval', which largely defeats its protection against XSS.",
            'CSP ـەکە ڕێگە بە unsafe-inline یان unsafe-eval دەدات، کە زۆربەی پاراستنەکەی بەرامبەر XSS بێ کاریگەر دەکات.');
      case FindingCode.missingXFrame:
        return _t(
            'The site can be embedded in an iframe, enabling clickjacking.',
            'سایتەکە دەتوانرێت لە ناو iframe دابنرێت، کە ڕێگە بە هێرشی clickjacking دەدات.');
      case FindingCode.missingXContent:
        return _t('Browsers may MIME-sniff responses, which can lead to XSS.',
            'بڕاوزەرەکان لەوانەیە MIME-sniff بکەن، کە دەبێتە هۆی XSS.');
      case FindingCode.missingReferrer:
        return _t(
            'Full URLs may leak to third-party sites via the Referer header.',
            'ناونیشانی تەواو لەوانەیە بۆ سایتی لایەنی سێیەم بدڕێت لەڕێگەی هێدەری Referer.');
      case FindingCode.missingPermissions:
        return _t(
            'Powerful browser features (camera, geolocation, etc.) are not restricted.',
            'تایبەتمەندییە بەهێزەکانی بڕاوزەر (کامێرا، شوێن، هتد) سنووردار نەکراون.');
      case FindingCode.missingCoop:
        return _t(
            'COOP isolates your window from cross-origin popups, mitigating side-channel attacks.',
            'COOP پەنجەرەکەت لە popup ـە بیانییەکان جیادەکاتەوە و هێرشی side-channel کەم دەکاتەوە.');
      case FindingCode.missingCorp:
        return _t('CORP prevents other sites from embedding your resources.',
            'CORP ڕێگری لە سایتی تر دەکات کە سەرچاوەکانت دابنێن.');
      case FindingCode.serverDisclosed:
        return _t(
            'The server reveals its software/version (${f.param}), helping attackers find matching exploits.',
            'سێرڤەرەکە نەرمەکاڵا/وەشانەکەی ئاشکرا دەکات (${f.param})، کە یارمەتی هێرشبەران دەدات.');
      case FindingCode.cookieNoSecure:
        return _t('One or more cookies can be sent over unencrypted HTTP.',
            'یەک یان زیاتر کووکی دەتوانرێت بەسەر HTTP ـی نهێنینەکراو بنێردرێت.');
      case FindingCode.cookieNoHttpOnly:
        return _t(
            'Cookies are readable by JavaScript, exposing them to XSS theft.',
            'کووکییەکان لەلایەن JavaScript دەخوێنرێنەوە، کە بەرامبەر دزینی XSS لاوازن.');
      case FindingCode.cookieSameSiteNone:
        return _t('Cookies are sent on cross-site requests, enabling CSRF.',
            'کووکییەکان لە داواکاری نێوان سایتەکان دەنێردرێن، کە ڕێگە بە CSRF دەدات.');
      case FindingCode.certInvalid:
        return _t('The TLS certificate could not be validated.',
            'سێرتیفیکەیتی TLS نەتوانرا پشتڕاست بکرێتەوە.');
      case FindingCode.certExpiringSoon:
        return _t('The certificate expires in ${f.param} day(s).',
            'سێرتیفیکەیتەکە لە ${f.param} ڕۆژدا بەسەردەچێت.');
      case FindingCode.missingSpf:
        return _t(
            'Without an SPF record, attackers can more easily spoof emails from this domain.',
            'بەبێ ڕیکۆردی SPF، هێرشبەران بە ئاسانی دەتوانن ئیمەیڵی ساختە بەناوی ئەم دۆمەینەوە بنێرن.');
      case FindingCode.missingDmarc:
        return _t(
            'Without DMARC, there is no policy telling receivers how to handle spoofed mail.',
            'بەبێ DMARC، هیچ سیاسەتێک نییە بۆ ئەوەی وەرگرەکان چۆن مامەڵە لەگەڵ ئیمەیڵی ساختە بکەن.');
      case FindingCode.weakDmarc:
        return _t(
            'DMARC is set to p=none, which only monitors and does not block spoofed mail.',
            'DMARC لەسەر p=none دانراوە، کە تەنها چاودێری دەکات و ئیمەیڵی ساختە بلۆک ناکات.');
      case FindingCode.exposedGit:
        return _t(
            'The /.git directory is publicly accessible, which can leak full source code.',
            'بوخچەی /.git بۆ هەمووان بەردەستە، کە دەتوانێت هەموو سۆرس کۆدەکە بدزرێت.');
      case FindingCode.exposedEnv:
        return _t(
            'The .env file is publicly accessible and may contain secrets/passwords.',
            'فایلی .env بۆ هەمووان بەردەستە و لەوانەیە نهێنی/ووشەی نهێنی تێدابێت.');
      case FindingCode.exposedConfig:
        return _t(
            'A server configuration file is publicly accessible.',
            'فایلێکی ڕێکخستنی سێرڤەر بۆ هەمووان بەردەستە.');
      case FindingCode.missingSecurityTxt:
        return _t(
            'No security.txt was found; researchers have no standard way to report issues.',
            'هیچ security.txt نەدۆزرایەوە؛ توێژەران ڕێگەیەکی ستانداردیان نییە بۆ ڕاپۆرتکردنی کێشە.');
      case FindingCode.permissiveCors:
        return _t(
            'Access-Control-Allow-Origin is set to *, allowing any site to read responses.',
            'Access-Control-Allow-Origin لەسەر * دانراوە، کە ڕێگە بە هەر سایتێک دەدات وەڵامەکان بخوێنێتەوە.');
      case FindingCode.missingCoep:
        return _t(
            'COEP, together with COOP, enables strong cross-origin isolation.',
            'COEP لەگەڵ COOP، جیاکردنەوەی بەهێزی cross-origin چالاک دەکات.');
      case FindingCode.sqlInjection:
        return _t(
            'A database error was triggered by an injected quote in the "${f.param}" parameter, indicating the input is not properly sanitized.',
            'هەڵەیەکی بنکەی داتا دروستبوو بەهۆی تێزڕاندنی واوێژ لە پارامیتەری "${f.param}"، کە ئاماژەیە بۆ ئەوەی داخڵکراوەکە بەدروستی پاک ناکرێتەوە.');
      case FindingCode.other:
        return f.description;
    }
  }

  String? findingRecommendation(SecurityFinding f) {
    switch (f.code) {
      case FindingCode.noHttps:
        return _t(
            'Install a valid SSL/TLS certificate and redirect all HTTP to HTTPS.',
            'سێرتیفیکەیتی SSL/TLS ـی دروست دابمەزرێنە و هەموو HTTP بۆ HTTPS ئاراستە بکە.');
      case FindingCode.missingHsts:
        return _t(
            'Add: Strict-Transport-Security: max-age=63072000; includeSubDomains; preload',
            'زیادی بکە: Strict-Transport-Security: max-age=63072000; includeSubDomains; preload');
      case FindingCode.missingCsp:
        return _t("Define a restrictive policy, e.g. default-src 'self'.",
            "سیاسەتێکی توند دیاری بکە، بۆ نموونە default-src 'self'.");
      case FindingCode.weakCsp:
        return _t(
            "Remove 'unsafe-inline'/'unsafe-eval' and use nonces or hashes.",
            'unsafe-inline/unsafe-eval لاببە و nonce یان hash بەکاربهێنە.');
      case FindingCode.missingXFrame:
        return _t('Add: X-Frame-Options: DENY (or SAMEORIGIN).',
            'زیادی بکە: X-Frame-Options: DENY (یان SAMEORIGIN).');
      case FindingCode.missingXContent:
        return _t('Add: X-Content-Type-Options: nosniff.',
            'زیادی بکە: X-Content-Type-Options: nosniff.');
      case FindingCode.missingReferrer:
        return _t('Add: Referrer-Policy: strict-origin-when-cross-origin.',
            'زیادی بکە: Referrer-Policy: strict-origin-when-cross-origin.');
      case FindingCode.missingPermissions:
        return _t('Add a Permissions-Policy disabling features you do not use.',
            'Permissions-Policy زیاد بکە کە ئەو تایبەتمەندییانە ناچالاک بکات کە بەکارناهێنیت.');
      case FindingCode.missingCoop:
        return _t('Consider: Cross-Origin-Opener-Policy: same-origin.',
            'بیری لێبکەرەوە: Cross-Origin-Opener-Policy: same-origin.');
      case FindingCode.missingCorp:
        return _t('Consider: Cross-Origin-Resource-Policy: same-origin.',
            'بیری لێبکەرەوە: Cross-Origin-Resource-Policy: same-origin.');
      case FindingCode.serverDisclosed:
        return _t('Remove or obfuscate the Server and X-Powered-By headers.',
            'هێدەرەکانی Server و X-Powered-By لاببە یان بیانشارەوە.');
      case FindingCode.cookieNoSecure:
        return _t('Add the Secure attribute to every cookie.',
            'تایبەتمەندی Secure بۆ هەموو کووکییەک زیاد بکە.');
      case FindingCode.cookieNoHttpOnly:
        return _t('Add the HttpOnly attribute to session cookies.',
            'تایبەتمەندی HttpOnly بۆ کووکی session زیاد بکە.');
      case FindingCode.cookieSameSiteNone:
        return _t('Set SameSite=Lax or Strict.',
            'SameSite=Lax یان Strict دابنێ.');
      case FindingCode.certInvalid:
        return _t('Install a valid, trusted certificate.',
            'سێرتیفیکەیتێکی دروست و متمانەپێکراو دابمەزرێنە.');
      case FindingCode.certExpiringSoon:
        return _t('Renew the certificate before it expires.',
            'سێرتیفیکەیتەکە نوێ بکەرەوە پێش بەسەرچوونی.');
      case FindingCode.missingSpf:
        return _t('Publish an SPF TXT record, e.g. v=spf1 include:... -all',
            'ڕیکۆردی SPF بڵاوبکەرەوە، بۆ نموونە v=spf1 include:... -all');
      case FindingCode.missingDmarc:
        return _t(
            'Publish a _dmarc TXT record with at least p=quarantine.',
            'ڕیکۆردی _dmarc بڵاوبکەرەوە بەلایەنی کەمەوە p=quarantine.');
      case FindingCode.weakDmarc:
        return _t('Strengthen DMARC to p=quarantine or p=reject.',
            'DMARC بەهێزتر بکە بۆ p=quarantine یان p=reject.');
      case FindingCode.exposedGit:
        return _t('Block access to /.git or remove it from the web root.',
            'ڕێگری لە دەستگەیشتن بە /.git بکە یان لە web root لایببە.');
      case FindingCode.exposedEnv:
        return _t('Remove .env from the web root and rotate any leaked secrets.',
            'فایلی .env لە web root لاببە و هەر نهێنییەکی دزراو بگۆڕە.');
      case FindingCode.exposedConfig:
        return _t('Restrict access to configuration files.',
            'دەستگەیشتن بە فایلەکانی ڕێکخستن سنووردار بکە.');
      case FindingCode.missingSecurityTxt:
        return _t('Add a /.well-known/security.txt with contact details.',
            'فایلی /.well-known/security.txt زیاد بکە لەگەڵ زانیاری پەیوەندی.');
      case FindingCode.permissiveCors:
        return _t('Restrict Access-Control-Allow-Origin to trusted origins.',
            'Access-Control-Allow-Origin سنووردار بکە بۆ سەرچاوە متمانەپێکراوەکان.');
      case FindingCode.missingCoep:
        return _t('Consider: Cross-Origin-Embedder-Policy: require-corp.',
            'بیری لێبکەرەوە: Cross-Origin-Embedder-Policy: require-corp.');
      case FindingCode.sqlInjection:
        return _t(
            'Use parameterized queries / prepared statements and validate all input.',
            'پرسیاری پارامیتەرکراو (prepared statements) بەکاربهێنە و هەموو داخڵکراوەکان پشتڕاست بکەرەوە.');
      case FindingCode.other:
        return f.recommendation;
    }
  }

  // --- App lock / biometric -------------------------------------------------
  String get security => _t('SECURITY', 'ئاسایش');
  String get appLock => _t('App Lock', 'قوفڵی ئەپ');
  String get appLockDesc => _t(
      'Require Face ID / fingerprint to open History',
      'پێویستی بە Face ID / پەنجەمۆر بۆ کردنەوەی مێژوو');
  String get appLockDescPin => _t(
      'Require device PIN to open History',
      'پێویستی بە PIN ـی ئامێر بۆ کردنەوەی مێژوو');
  String get unlockHistory =>
      _t('Unlock to view scan history', 'بۆ بینینی مێژووی سکان قوفڵ بکەرەوە');
  String get authFailed =>
      _t('Authentication failed', 'سەلماندن سەرکەوتوو نەبوو');
  String get biometricUnavailable => _t(
      'Biometrics are not available on this device',
      'بایۆمەتری لەسەر ئەم ئامێرە بەردەست نییە');

  // --- Settings -------------------------------------------------------------
  String get settings => _t('SETTINGS', 'ڕێکخستنەکان');
  // PDF language dialog
  String get reportLanguageTitle =>
      _t('Report language', 'زمانی ڕاپۆرت');
  String get reportLanguagePrompt => _t(
      'Which language should the PDF report be generated in?',
      'ڕاپۆرتی PDF بە کام زمان دروست بکرێت؟');
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
