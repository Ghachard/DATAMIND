import 'package:flutter/material.dart';
import '../core/theme.dart';

class LogoHeader extends StatelessWidget {
  final bool showDivider;

  const LogoHeader({super.key, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildLogo(
            path: 'assets/images/ispm_logo.png',
            fallbackIcon: Icons.school,
            label: 'ISPM',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  isDark ? AppColors.borderDark : AppColors.borderLight,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          _buildLogo(
            path: 'assets/images/datamind_logo.png',
            fallbackIcon: Icons.analytics,
            label: 'DataMind',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({
    required String path,
    required IconData fallbackIcon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.asset(
            path,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              fallbackIcon,
              size: 28,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
            if (label == 'ISPM')
              Text(
                'Institut Supérieur\nPolytechnique',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: isDark ? const Color(0xFF8899AA) : const Color(0xFF666666),
                  height: 1.2,
                ),
              )
            else
              Text(
                'Statistique\nPédagogique',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: isDark ? const Color(0xFF8899AA) : const Color(0xFF666666),
                  height: 1.2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
