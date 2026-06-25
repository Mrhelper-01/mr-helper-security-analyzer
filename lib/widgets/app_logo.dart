// lib/widgets/app_logo.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = isDark ? '#00D4FF' : '#0099CC';
    final bgColor = isDark ? '#0A0E1A' : '#F5F7FA';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.string(
          '''
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
            <circle cx="100" cy="100" r="90" fill="$bgColor" stroke="$mainColor" stroke-width="2"/>
            <circle cx="100" cy="100" r="85" fill="none" stroke="$mainColor" stroke-width="1" opacity="0.3"/>
            <text x="100" y="75" text-anchor="middle" fill="$mainColor" font-family="monospace" font-size="18" font-weight="bold">MR</text>
            <text x="100" y="95" text-anchor="middle" fill="$mainColor" font-family="monospace" font-size="14" font-weight="bold">HELPER</text>
            <line x1="40" y1="105" x2="160" y2="105" stroke="$mainColor" stroke-width="0.5" opacity="0.5"/>
            <text x="100" y="120" text-anchor="middle" fill="$mainColor" font-family="monospace" font-size="8" opacity="0.8">CYBER</text>
            <text x="100" y="132" text-anchor="middle" fill="$mainColor" font-family="monospace" font-size="8" opacity="0.8">HACKER IT</text>
            <text x="100" y="144" text-anchor="middle" fill="$mainColor" font-family="monospace" font-size="8" opacity="0.8">SOLUTIONS</text>
            <text x="100" y="156" text-anchor="middle" fill="$mainColor" font-family="monospace" font-size="8" opacity="0.8">DIGITAL GROWTH</text>
          </svg>
          ''',
          width: size,
          height: size,
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'MR HELPER',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: 2,
            ),
          ),
          Text(
            'CYBER SECURITY ANALYZER',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: size * 0.1,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}
