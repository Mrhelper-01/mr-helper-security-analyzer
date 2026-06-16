import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('SECURITY SCANNER'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
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
                const Text(
                  'ENTER TARGET URL',
                  style: TextStyle(
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
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Consumer<ScanProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton.icon(
                    onPressed: provider.isScanning ? null : _startScan,
                    icon: provider.isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.security_rounded),
                    label: Text(
                      provider.isScanning ? 'SCANNING...' : 'START SCAN',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanInfo() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT WE CHECK',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem(
              'HTTPS Availability', Icons.lock_outline, AppColors.success),
          _buildCheckItem('Security Headers (CSP, HSTS, etc.)',
              Icons.security_outlined, AppColors.neonBlue),
          _buildCheckItem('Cookie Security (Secure, HttpOnly)',
              Icons.cookie_outlined, AppColors.warning),
          _buildCheckItem('Risk Classification & Scoring',
              Icons.analytics_outlined, AppColors.neonPurple),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
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

  Widget _buildScanningState() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingXl),
      child: Column(
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SCANNING IN PROGRESS',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing security headers and configuration...',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildScanStep('Checking HTTPS', Icons.lock_outline),
          _buildScanStep('Analyzing Security Headers', Icons.security_outlined),
          _buildScanStep('Inspecting Cookies', Icons.cookie_outlined),
          _buildScanStep(
              'Calculating Security Score', Icons.calculate_outlined),
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
          const Text(
            'SCAN FAILED',
            style: TextStyle(
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
            label: const Text('TRY AGAIN'),
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
          const Text(
            'READY TO SCAN',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter a URL above and press Start Scan',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
