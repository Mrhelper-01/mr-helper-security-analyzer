# MR HELPER — Web Application Security Analyzer

<div align="center">
  <h1>🛡️ MR HELPER</h1>
  <p><strong>Web Application Security Analyzer</strong></p>
  <p>A professional mobile cybersecurity tool that analyzes website security headers, DNS/email configuration, TLS certificates and exposed files — then explains the findings and produces a shareable report.</p>
  <p><sub>Version 2.1.0 · Flutter · Android-first</sub></p>
</div>

---

## ✨ Features

### 🔍 Scanning engine
- **Security headers** — CSP (incl. `unsafe-inline`/`unsafe-eval` quality), HSTS (`max-age`-aware), X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, COOP, CORP, COEP
- **DNS & email security** — SPF, DMARC (with policy strength) and MX records via **DNS-over-HTTPS**
- **TLS certificate inspection** — trust/validity, issuer, and expiry warnings (native socket)
- **Exposed-file discovery** — detects publicly accessible `.git`, `.env`, `.htaccess`, plus `security.txt` / `robots.txt`
- **Cookie audit** — Secure, HttpOnly and SameSite flags across all cookies
- **Permissive CORS detection** — flags `Access-Control-Allow-Origin: *`
- **Server disclosure** — flags leaked `Server` / `X-Powered-By` versions
- **SQL injection (error-based)** — non-destructively probes URL query parameters with a single-quote payload and detects database error signatures
- **HTTP/HTTPS handling** — scans HTTP-only sites and automatically falls back from HTTPS to HTTP when needed

### 📊 Results & reporting
- **Normalized 0–100 score** with letter grades (A–F) and Low/Medium/High/Critical risk
- **Severity-ranked findings** — every issue has a severity, description and remediation
- **Historical comparison (diff)** — score delta and new/resolved issues vs. the previous scan
- **PDF reports** — share a full professional report in **English (vector)** or **Kurdish (rendered image with correct shaping)**
- **Statistics dashboard** — risk distribution pie chart, most-scanned sites

### 🔔 Monitoring & security
- **Continuous monitoring** — periodic background rescans that send a **push notification** when a site's score drops
- **Biometric app lock** — protect scan history with **Face ID / fingerprint / device PIN** (whatever the device supports)

### 🌍 Experience
- **App-wide bottom navigation** — Home · History · Scan · Statistics · Settings, with a tabbed report screen (Overview · Headers · Tech · DNS · More)
- **Bilingual (i18n)** — full **Kurdish (Sorani, RTL)** and **English** UI, switchable at runtime
- **Modern dark UI** — Cerebra-style violet aesthetic, aurora glow background, glassmorphism cards, gradient buttons
- **Cloud history** — scans stored in Firebase Firestore

## 📱 Screens

| Screen | Description |
|--------|-------------|
| **Splash** | Animated intro with grid background and neon glow |
| **Main shell** | Persistent bottom navigation hosting the main tabs + centre Scan button |
| **Home** | Dashboard with stats and recent scans |
| **Scanner** | URL input with validation and live scanning status |
| **Report** | Tabbed: Overview (score, comparison, findings), Headers, Tech (server/cert), DNS, More (cookies) — with share + monitor |
| **DNS & Email** | Dedicated page: DNS records (A/MX/NS/TXT) and SPF/DKIM/DMARC results |
| **History** | Scan history with sort/delete (biometric-locked when app lock is on) |
| **Statistics** | Risk distribution chart, most-scanned ranking |
| **Settings** | Language, app lock, app & developer info |
| **About** | Feature list and technical stack |

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter / Dart | Cross-platform UI & logic |
| Firebase Core + Cloud Firestore | Cloud-stored scan history |
| Provider | State management |
| http | Header fetch + DNS-over-HTTPS |
| local_auth | Biometric app lock |
| workmanager + flutter_local_notifications | Background monitoring & alerts |
| shared_preferences | Local monitoring/app-lock state |
| pdf + printing | Report generation & sharing |
| fl_chart | Statistics charts |

## 🔥 Scan Methodology & Scoring

The app performs a **passive** analysis: it fetches the target, inspects HTTP response headers, the TLS certificate, DNS records, and probes a few well-known paths. The score is **normalized to 0–100** — each applicable check contributes weighted points to both the earned and the maximum-possible totals, so a fully-hardened site reaches a true 100 even when it sets no cookies.

| Check | Weight |
|-------|--------|
| HTTPS | 25 |
| Content-Security-Policy | 18 |
| Strict-Transport-Security (HSTS) | 15 |
| X-Frame-Options | 10 |
| X-Content-Type-Options | 10 |
| Referrer-Policy | 7 |
| Permissions-Policy | 5 |
| Cookie Secure / HttpOnly / SameSite | 4 each *(only when cookies are present)* |

DNS/email, exposed-file, CORS, server-disclosure and **SQL-injection** checks are surfaced as **severity-ranked findings** (the SQL-injection probe only runs on URLs that have query parameters, e.g. `site.com/page.php?id=1`).

**Grades:** A (90–100) · B (80–89) · C (70–79) · D (60–69) · F (0–59)

> ℹ️ **Mobile-first.** Browsers block cross-origin reads (CORS) and never expose `Set-Cookie` to JavaScript, so scanning runs natively on Android/iOS. The web build includes a best-effort proxy fallback but cannot read all headers.

## 📂 Project Structure

```
lib/
├── main.dart                       # App entry, providers, monitoring/notifications init
├── core/
│   ├── constants.dart              # Constants, colors (violet palette), score weights
│   ├── theme.dart                  # Dark theme (UniQAIDAR font)
│   ├── routes.dart                 # Named routes
│   └── app_strings.dart            # Type-safe i18n (English + Kurdish) + finding text
├── models/
│   ├── scan_result.dart            # ScanResult model (headers, cookies, cert, dns, findings)
│   └── security_finding.dart       # SecurityFinding + FindingSeverity/FindingCode
├── providers/
│   ├── scan_provider.dart          # Scan ops, history, stats, diff lookup
│   ├── theme_provider.dart         # Theme (dark-only)
│   ├── locale_provider.dart        # Language + RTL
│   └── app_lock_provider.dart      # Biometric app-lock preference
├── services/
│   ├── firestore_service.dart      # Firestore CRUD
│   ├── security_scanner_service.dart # Headers, DNS-over-HTTPS, discovery, scoring
│   ├── cert_inspector*.dart        # TLS inspection (conditional io/stub for web)
│   ├── report_pdf_service.dart     # English vector PDF + Kurdish image PDF
│   ├── biometric_service.dart      # local_auth wrapper
│   ├── monitor_service.dart        # Periodic-scan scheduling (WorkManager)
│   ├── notification_service.dart   # Local notifications
│   └── background_worker.dart      # WorkManager callback (background isolate)
├── utils/
│   └── validators.dart             # URL validation
├── widgets/
│   ├── aurora_background.dart       # Layered glow background
│   ├── gradient_button.dart         # Pill gradient CTA
│   ├── section_label.dart           # Section headings
│   ├── glassmorphism_card.dart      # Glass card
│   ├── score_indicator.dart         # Animated gradient score gauge
│   ├── printable_report.dart        # Flutter-rendered report for Kurdish PDF
│   ├── risk_badge.dart / stats_card.dart / header_check_tile.dart
└── screens/
    ├── main_shell.dart             # Bottom-navigation shell hosting the tabs
    ├── dns_email_screen.dart       # DNS & email-security detail page
    └── splash / home / scanner / report / history / statistics / settings / about
```

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- A [Firebase](https://console.firebase.google.com) project (for history)
- Android Studio / VS Code with the Flutter extension

### Setup

```bash
git clone https://github.com/Mrhelper-01/mr-helper-security-analyzer.git
cd mr-helper-security-analyzer
flutter pub get
```

**Configure Firebase** (history feature):

```bash
dart run flutterfire configure
```

Then enable **Firestore Database** in the Firebase Console (test mode for development).

**Run on a device** (Android recommended — scanning needs native networking):

```bash
flutter run
```

### Build & test

```bash
flutter test
flutter build apk --release
```

> **Android notes:** `MainActivity` extends `FlutterFragmentActivity` (required by `local_auth`), core-library desugaring is enabled in `android/app/build.gradle.kts` (required by `flutter_local_notifications`), and `usesCleartextTraffic="true"` is set so HTTP-only sites can be scanned. Permissions used: `USE_BIOMETRIC`, `POST_NOTIFICATIONS`, `INTERNET`.

## 🎨 UI Theme

- **Primary:** `#8B6DFF` (violet)
- **Background:** `#0A0814` (deep purple-black) with aurora glow
- **Cards:** violet-tinted glassmorphism
- **Font:** UniQAIDAR (bundled, full Kurdish + Latin support)
- **Effects:** backdrop blur, glow shadows, gradient ring score gauge

## ✅ Roadmap status

**Shipped:** TLS certificate inspection · DNS & email checks (SPF/DKIM/DMARC) · exposed-file discovery · SQL-injection detection · PDF export (English & Kurdish) · multi-language UI · Face ID / fingerprint app lock · continuous monitoring & alerts · historical comparison · app-wide & tabbed navigation.

**Possible next steps:** vulnerability/CVE lookups · WHOIS · in-app webview · TLS cipher grading · dark-web breach checks (these last two and CVE require paid APIs).

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Licensed under the MIT License — see the LICENSE file for details.

## 👨‍💻 Developer

**MR HELPER** — Flutter Developer & Cybersecurity Enthusiast · Built with ❤️ using Flutter & Firebase

---

<div align="center">
  <sub>© 2026 MR HELPER. All rights reserved.</sub>
</div>