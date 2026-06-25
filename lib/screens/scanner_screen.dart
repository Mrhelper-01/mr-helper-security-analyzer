import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';
import 'package:mr_helper_security_analyzer/widgets/gradient_button.dart';
import 'package:mr_helper_security_analyzer/widgets/section_label.dart';
import 'package:mr_helper_security_analyzer/utils/validators.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureUrl = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _startScan() {
    if (_formKey.currentState!.validate()) {
      final url = _urlController.text.trim();
      final normalizedUrl = UrlValidator.normalizeUrl(url);

      final provider = context.read<ScanProvider>();
      provider.clearError();

      provider.scanUrl(normalizedUrl).then((result) {
        if (result != null && mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.report,
            arguments: {'scanResult': result},
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.securityScanner),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AuroraBackground(
        hero: true,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildUrlInputSection(),
                const SizedBox(height: 24),
                _buildScanInfo(),
                const SizedBox(height: 24),
                Consumer<ScanProvider>(
                  builder: (context, provider, _) {
                    if (provider.isScanning) {
                      return _buildScanningState();
                    }
                    if (provider.scanError != null) {
                      return _buildErrorState(provider.scanError!);
                    }
                    return _buildReadyState();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlInputSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: AppColors.neonBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.of(context).enterTargetUrl,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              obscureText: _obscureUrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                hintText: 'example.com',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureUrl ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscureUrl = !_obscureUrl);
                      },
                    ),
                    if (_urlController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _urlController.clear();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                color: Colors.white,
                fontSize: 14,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                return UrlValidator.validateUrl(value);
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Consumer<ScanProvider>(
              builder: (context, provider, _) {
                return GradientButton(
                  loading: provider.isScanning,
                  onPressed: provider.isScanning ? null : _startScan,
                  icon: Icons.security_rounded,
                  label: provider.isScanning
                      ? AppStrings.of(context).scanning
                      : AppStrings.of(context).startScan,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanInfo() {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(text: s.whatWeCheck),
          const SizedBox(height: 16),
          _buildCheckItem(
              s.httpsAvailability, Icons.lock_rounded, AppColors.success),
          _buildCheckItem(
              s.securityHeaders, Icons.security_rounded, AppColors.primary),
          _buildCheckItem(
              s.cookieSecurity, Icons.cookie_rounded, AppColors.warning),
          _buildCheckItem(s.riskClassification, Icons.analytics_rounded,
              AppColors.neonPurple),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.check_circle_outline_rounded,
              size: 16, color: color.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _buildScanningState() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingXl),
      child: Column(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const Icon(Icons.radar_rounded,
                    size: 36, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.of(context).scanInProgress,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.of(context).analyzingConfig,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildScanStep(AppStrings.of(context).checkingHttps, Icons.lock_outline),
          _buildScanStep(
              AppStrings.of(context).analyzingHeaders, Icons.security_outlined),
          _buildScanStep(
              AppStrings.of(context).inspectingCookies, Icons.cookie_outlined),
          _buildScanStep(
              AppStrings.of(context).calculatingScore, Icons.calculate_outlined),
        ],
      ),
    );
  }

  Widget _buildScanStep(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      glassColor: AppColors.error,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.of(context).scanFailed,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              context.read<ScanProvider>().clearError();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(AppStrings.of(context).tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyState() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.of(context).readyToScan,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.of(context).enterUrlAbovePrompt,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
