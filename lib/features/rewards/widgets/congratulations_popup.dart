import 'package:flutter/material.dart';
import '../../../app_tokens.dart';

class CongratulationsPopup extends StatelessWidget {
  final String badgeName;
  final String badgeDescription;
  final VoidCallback onSave;
  final VoidCallback onViewBadge;

  const CongratulationsPopup({
    super.key,
    required this.badgeName,
    required this.badgeDescription,
    required this.onSave,
    required this.onViewBadge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star, color: colors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Congrats',
              style: AppTextStyles.inter20Bold.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'You earned $badgeName',
              textAlign: TextAlign.center,
              style: AppTextStyles.inter14Regular.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  onSave();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save',
                  style: AppTextStyles.inter16SemiBold
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                onViewBadge();
                Navigator.of(context).pop();
              },
              child: Text(
                'View the badge',
                style: AppTextStyles.inter14SemiBold.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
