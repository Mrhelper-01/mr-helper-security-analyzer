import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/providers/theme_provider.dart';
import 'package:mr_helper_security_analyzer/providers/locale_provider.dart';
import 'package:mr_helper_security_analyzer/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<ScanProvider>(
          create: (_) => ScanProvider(),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),
      ],
      child: const MrHelperApp(),
    ),
  );
}

class MrHelperApp extends StatelessWidget {
  const MrHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          title: 'MR HELPER - Web Security Analyzer',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData, // ✅ گۆڕدرا بۆ themeData
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
          // Flip the whole UI to RTL when Kurdish is selected.
          builder: (context, child) => Directionality(
            textDirection: localeProvider.textDirection,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
