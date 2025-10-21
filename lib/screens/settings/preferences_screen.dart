import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/underwater_theme.dart';
import '../../widgets/frosted_app_bar.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(
        title: 'PREFERENCES',
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            final prefs = appProvider.preferences;
            
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + kToolbarHeight - 32,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  // Units Section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              UnderwaterTheme.deepNavy1.withOpacity(0.7),
                              UnderwaterTheme.deepNavy2.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          border: Border.all(
                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: UnderwaterTheme.glowCyan(opacity: 0.15, blur: 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'UNITS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: UnderwaterTheme.textCyan.withOpacity(0.9),
                                letterSpacing: 1.2,
                                shadows: UnderwaterTheme.textShadowLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    UnderwaterTheme.deepNavy2.withOpacity(0.6),
                                    UnderwaterTheme.cardPurpleMid.withOpacity(0.5),
                                  ],
                                ),
                                border: Border.all(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4), width: 2),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              child: Column(
                                children: [
                                  _buildSwitchTile(
                                    icon: Icons.thermostat,
                                    title: 'Use Metric Units',
                                    subtitle: prefs.useMetric 
                                        ? 'Celsius (°C), Kilograms (kg), Centimeters (cm)'
                                        : 'Fahrenheit (°F), Pounds (lbs), Inches (in)',
                                    value: prefs.useMetric,
                                    onChanged: (value) {
                                      appProvider.updatePreferences(
                                        prefs.copyWith(useMetric: value),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Experience Section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              UnderwaterTheme.deepNavy1.withOpacity(0.7),
                              UnderwaterTheme.deepNavy2.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          border: Border.all(
                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: UnderwaterTheme.glowCyan(opacity: 0.15, blur: 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'EXPERIENCE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: UnderwaterTheme.textCyan.withOpacity(0.9),
                                letterSpacing: 1.2,
                                shadows: UnderwaterTheme.textShadowLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    UnderwaterTheme.deepNavy2.withOpacity(0.6),
                                    UnderwaterTheme.cardPurpleMid.withOpacity(0.5),
                                  ],
                                ),
                                border: Border.all(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4), width: 2),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              child: Column(
                                children: [
                                  _buildSwitchTile(
                                    icon: Icons.vibration,
                                    title: 'Haptic Feedback',
                                    subtitle: 'Feel vibrations on important actions',
                                    value: prefs.hapticsEnabled,
                                    onChanged: (value) {
                                      appProvider.updatePreferences(
                                        prefs.copyWith(hapticsEnabled: value),
                                      );
                                    },
                                  ),
                                  Divider(height: 1, color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3), thickness: 1),
                                  _buildSwitchTile(
                                    icon: Icons.volume_up,
                                    title: 'Sound Effects',
                                    subtitle: 'Play sounds for actions',
                                    value: prefs.soundEnabled,
                                    onChanged: (value) {
                                      appProvider.updatePreferences(
                                        prefs.copyWith(soundEnabled: value),
                                      );
                                    },
                                  ),
                                  Divider(height: 1, color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3), thickness: 1),
                                  _buildSwitchTile(
                                    icon: Icons.notifications,
                                    title: 'Notifications',
                                    subtitle: 'Get notified about quests and achievements',
                                    value: prefs.notificationsEnabled,
                                    onChanged: (value) {
                                      appProvider.updatePreferences(
                                        prefs.copyWith(notificationsEnabled: value),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: UnderwaterTheme.surfaceCyan1),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: UnderwaterTheme.textLight,
          shadows: UnderwaterTheme.textShadowLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: UnderwaterTheme.textCyan,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: UnderwaterTheme.surfaceCyan1,
      activeTrackColor: UnderwaterTheme.surfaceCyan2,
    );
  }
}
