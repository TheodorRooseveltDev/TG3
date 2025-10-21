import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/achievement.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';

class AchievementUnlockDialog extends StatefulWidget {
  final List<Achievement> achievements;
  final VoidCallback onDismiss;

  const AchievementUnlockDialog({
    super.key,
    required this.achievements,
    required this.onDismiss,
  });

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Haptic feedback on unlock
    HapticFeedback.heavyImpact();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showNext() {
    if (_currentIndex < widget.achievements.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _controller.reset();
      _controller.forward();
      HapticFeedback.mediumImpact();
    } else {
      widget.onDismiss();
      Navigator.of(context).pop();
    }
  }

  Future<void> _shareAchievement() async {
    HapticFeedback.mediumImpact();
    
    final achievement = widget.achievements[_currentIndex];
    final unlockedDate = achievement.unlockedAt != null
        ? DateFormat('MMMM d, yyyy').format(achievement.unlockedAt!)
        : 'Just now';
    
    final shareText = '''
🏆 Achievement Unlocked! 🏆

${achievement.icon} ${achievement.name}

${achievement.description}

Unlocked: $unlockedDate

Category: ${achievement.category.toUpperCase()}
Progress: ${achievement.currentProgress}/${achievement.requiredCount}

Caught with Big Bass Catcher 🎣
#BigBassCatcher #FishingAchievement #FishingLife
''';

    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        shareText,
        subject: '🏆 Big Bass Catcher Achievement: ${achievement.name}',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievements[_currentIndex];
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      UnderwaterTheme.deepNavy1,
                      UnderwaterTheme.deepNavy2,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: UnderwaterTheme.surfaceCyan1.withOpacity(0.6),
                    width: 3,
                  ),
                  boxShadow: UnderwaterTheme.glowCyan(opacity: 0.4, blur: 24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy icon with glow effect
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                            UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: UnderwaterTheme.surfaceCyan1,
                          width: 2,
                        ),
                        boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 16),
                      ),
                      child: const Center(
                        child: Text(
                          '🏆',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Achievement unlocked text
                    const Text(
                      'ACHIEVEMENT UNLOCKED!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: UnderwaterTheme.surfaceCyan1,
                        letterSpacing: 1.2,
                        shadows: UnderwaterTheme.textShadowLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Achievement icon
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    
                    // Achievement name
                    Text(
                      achievement.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UnderwaterTheme.textLight,
                        shadows: UnderwaterTheme.textShadowLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Achievement description
                    Text(
                      achievement.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: UnderwaterTheme.textCyan,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Progress indicator if multiple achievements
                    if (widget.achievements.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '${_currentIndex + 1} of ${widget.achievements.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: UnderwaterTheme.textCyan.withOpacity(0.7),
                          ),
                        ),
                      ),
                    
                    // Share button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _shareAchievement,
                        icon: const Icon(Icons.share),
                        label: const Text(
                          'SHARE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: UnderwaterTheme.surfaceCyan1,
                          side: BorderSide(
                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.6),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UnderwaterTheme.surfaceCyan1,
                          foregroundColor: UnderwaterTheme.deepNavy2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ).copyWith(
                          shadowColor: WidgetStateProperty.all(
                            UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          _currentIndex < widget.achievements.length - 1
                              ? 'NEXT'
                              : 'AWESOME!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
