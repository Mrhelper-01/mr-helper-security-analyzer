# MR HELPER — Web Application Security Analyzer

<div align="center">
  <img src="assets/animations/placeholder.txt" alt="MR HELPER Logo" width="120"/>
  <h1>🛡️ MR HELPER</h1>
  <p><strong>Web Application Security Analyzer</strong></p>
  <p>A professional mobile cybersecurity tool that analyzes website security headers, checks for vulnerabilities, and provides actionable security recommendations.</p>
</div>

---

## ✨ Features

- **🔍 Security Scanner** — Scan any website's security posture in seconds
- **📋 Header Analysis** — Checks CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy
- **🍪 Cookie Audit** — Analyzes Secure, HttpOnly, and SameSite cookie flags
- **📊 Scoring Engine** — 0–100 security score with letter grades (A–F)
- **⚠️ Risk Classification** — Low, Medium, High, and Critical risk levels
- **🔥 Cloud History** — All scans stored securely in Firebase Firestore
- **📈 Statistics Dashboard** — Pie charts, risk distribution, most scanned websites
- **📝 Detailed Reports** — Full breakdown with actionable recommendations
- **🎨 Modern UI** — Glassmorphism design, neon cyber aesthetic, smooth animations
- **🌙 Dark Theme** — Full dark mode with cyberpunk-inspired color palette

## 📱 Screens

| Screen | Description |
|--------|-------------|
| **Splash** | Animated intro with grid background and neon glow effects |
| **Home** | Dashboard with stats cards, recent scans, quick actions |
| **Scanner** | URL input with validation and real-time scanning status |
| **Report** | Comprehensive report with score, headers, cookies, recommendations |
| **History** | Full scan history with sort and delete functionality |
| **Statistics** | Pie chart risk distribution, most scanned websites ranking |
| **Settings** | Dark mode toggle, app info, developer info |
| **About** | App details, features list, technical stack |

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | Cross-platform UI framework |
| Dart | 3.x | Programming language |
| Firebase Core | ^2.24.2 | Firebase initialization |
| Cloud Firestore | ^4.14.0 | NoSQL cloud database |
| Provider | ^6.1.1 | State management |
| http | ^1.1.2 | HTTP client for scanning |
| fl_chart | ^0.66.2 | Interactive pie charts |

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── core/
│   ├── constants.dart        # App constants, colors, theme values
│   ├── theme.dart            # Dark theme configuration
│   └── routes.dart           # Named routes and navigation
├── models/
│   └── scan_result.dart      # ScanResult data model
├── providers/
│   ├── scan_provider.dart    # Scan operations, history, stats
│   └── theme_provider.dart   # Theme management
├── services/
│   ├── firestore_service.dart    # Firestore CRUD operations
│   └── security_scanner_service.dart  # Website scanning logic
├── utils/
│   └── validators.dart       # URL validation utilities
├── widgets/
│   ├── glassmorphism_card.dart   # Reusable glass card
│   ├── score_indicator.dart      # Circular score gauge
│   ├── risk_badge.dart           # Risk level badge
│   ├── stats_card.dart           # Statistics display card
│   └── header_check_tile.dart    # Header check status tile
└── screens/
    ├── splash_screen.dart     # Animated splash
    ├── home_screen.dart       # Main dashboard
    ├── scanner_screen.dart    # URL scanner
    ├── history_screen.dart    # Scan history
    ├── report_screen.dart     # Detailed report
    ├── statistics_screen.dart # Analytics & charts
    ├── settings_screen.dart   # Settings
    └── about_screen.dart      # About page
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- [Firebase Account](https://console.firebase.google.com)
- Android Studio / VS Code with Flutter extensions

### Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/mr-helper-security-analyzer.git
cd mr-helper-security-analyzer
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Configure Firebase

> **Important:** You must set up your own Firebase project to use Firestore features.

1. Go to the [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or select existing)
3. Add **Android app** with package name `com.mrhelper.securityanalyzer`
4. Add **iOS app** with bundle ID `com.mrhelper.securityanalyzer`
5. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
6. Place them in the respective platform directories:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

#### 4. Generate Firebase Options

In the terminal, run:

```bash
dart run flutterfire configure
```

This will generate the `lib/firebase_options.dart` file with your project credentials.

> **Note:** The existing `lib/firebase_options.dart` contains placeholder values. Running `flutterfire configure` will replace it with real credentials.

#### 5. Enable Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose a location
4. Start in **test mode** (for development)
5. Click **Enable**

#### 6. Run the App

```bash
flutter run
```

## 🔥 Security Scan Methodology

The app performs a passive security analysis by examining HTTP response headers. It checks for:

### Security Headers (70% of total score)
| Header | Weight | Purpose |
|--------|--------|---------|
| HTTPS | 20 pts | Encrypted data transmission |
| Content-Security-Policy | 15 pts | Prevents XSS & data injection |
| Strict-Transport-Security | 15 pts | Enforces HTTPS connections |
| X-Frame-Options | 10 pts | Prevents clickjacking |
| X-Content-Type-Options | 10 pts | Prevents MIME sniffing |
| Referrer-Policy | 10 pts | Controls referrer leakage |
| Permissions-Policy | 10 pts | Restricts browser features |

### Cookie Security (10% of total score)
- **Secure flag** — Cookies sent over HTTPS only (5 pts)
- **HttpOnly flag** — Cookies inaccessible to JavaScript (5 pts)
- **SameSite attribute** — CSRF protection (5 pts, added to total via bonus)

### Scoring
- **A (90-100):** Excellent security posture
- **B (80-89):** Good, minor improvements needed
- **C (70-79):** Fair, several headers missing
- **D (60-69):** Poor, many security gaps
- **F (0-59):** Critical, immediate action required

## 📊 Architecture

```
┌─────────────────────────────────────────────────┐
│                   UI Layer                        │
│  (Screens with Glassmorphism UI components)       │
├─────────────────────────────────────────────────┤
│                Provider Layer                     │
│     (ScanProvider, ThemeProvider)                 │
├─────────────────────────────────────────────────┤
│               Service Layer                       │
│  (FirestoreService, SecurityScannerService)       │
├─────────────────────────────────────────────────┤
│                    Data Layer                     │
│   (ScanResult model, Firebase Firestore)          │
└─────────────────────────────────────────────────┘
```

## 🎨 UI Theme

- **Primary:** `#00D4FF` (Cyber Blue)
- **Background:** `#0A0E1A` (Deep Space)
- **Cards:** `#111827` with glassmorphism effect
- **Accents:** Cyan, Purple, Pink, Green neon colors
- **Font:** JetBrains Mono (monospace for code-like feel)
- **Effects:** Backdrop blur, glow shadows, animated gradients

## 🔧 Development

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

### Run Tests

```bash
flutter test
```

### Code Generation (if applicable)

```bash
flutter pub run build_runner build
```

## 📝 To-Do / Future Enhancements

- [ ] Add light theme support
- [ ] In-app webview for visual inspection
- [ ] SSL certificate chain validation
- [ ] Port scanning functionality
- [ ] WHOIS and DNS lookups
- [ ] Vulnerability database integration (CVE checks)
- [ ] Export reports as PDF
- [ ] Multiple language support (i18n)
- [ ] Biometric authentication for sensitive actions
- [ ] Dark web leak checking

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License — see the LICENSE file for details.

## 👨‍💻 Developer

**MR HELPER**

- Flutter Developer & Cybersecurity Enthusiast
- Built with ❤️ using Flutter & Firebase

---

<div align="center">
  <sub>© 2024 MR HELPER. All rights reserved.</sub>
</div>
