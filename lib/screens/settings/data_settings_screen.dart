import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/underwater_theme.dart';
import '../../widgets/frosted_app_bar.dart';

class DataSettingsScreen extends StatelessWidget {
  const DataSettingsScreen({super.key});

  Future<void> _exportToJSON(BuildContext context, AppProvider appProvider) async {
    try {
      final data = {
        'userProfile': appProvider.userProfile?.toJson(),
        'catches': appProvider.catches.map((c) => c.toJson()).toList(),
        'achievements': appProvider.achievements.map((a) => a.toJson()).toList(),
        'questHistory': appProvider.questHistory.map((q) => q.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/fishquest_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'FishQuest Data Backup',
          text: 'My FishQuest fishing data backup',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully! ✓'),
            backgroundColor: AppTheme.colorSuccess,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportToCSV(BuildContext context, AppProvider appProvider) async {
    try {
      // Create CSV header
      final csvLines = <String>[];
      csvLines.add('Date,Fish Species,Weight (kg),Length (cm),Location,Method,Weather');

      // Add catch data
      for (final catch_ in appProvider.catches) {
        final row = [
          catch_.caughtAt.toIso8601String(),
          catch_.fishName,
          catch_.weight?.toString() ?? '0',
          catch_.length?.toString() ?? '0',
          (catch_.location ?? '').replaceAll(',', ';'), // Escape commas
          catch_.fishingMethod.replaceAll(',', ';'),
          (catch_.weatherConditions ?? '').replaceAll(',', ';'),
        ];
        csvLines.add(row.join(','));
      }

      final csvString = csvLines.join('\n');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/fishquest_catches_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csvString);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'FishQuest Catches Export',
          text: 'My fishing catches from FishQuest',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exported successfully! ✓'),
            backgroundColor: AppTheme.colorSuccess,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(
        title: 'DATA MANAGEMENT',
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
                          // Stats Section - Title + Content in one Frosted Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      UnderwaterTheme.deepNavy1.withOpacity(0.7),
                                      UnderwaterTheme.deepNavy2.withOpacity(0.6),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      'YOUR DATA',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: UnderwaterTheme.surfaceCyan1,
                                        shadows: [
                                          Shadow(
                                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Stats Grid
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _DataStatCard(
                                            icon: Icons.phishing,
                                            label: 'CATCHES',
                                            value: '${appProvider.totalCatches}',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _DataStatCard(
                                            icon: Icons.emoji_events,
                                            label: 'ACHIEVEMENTS',
                                            value: '${appProvider.unlockedAchievements}',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _DataStatCard(
                                            icon: Icons.stars,
                                            label: 'SPECIES',
                                            value: '${appProvider.uniqueSpecies}',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _DataStatCard(
                                            icon: Icons.task_alt,
                                            label: 'QUESTS',
                                            value: '${appProvider.questHistory.length}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                
                          const SizedBox(height: 24),

                          // Export Section - Title + Content in one Frosted Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            UnderwaterTheme.deepNavy1.withOpacity(0.7),
                            UnderwaterTheme.deepNavy2.withOpacity(0.6),
                          ],
                        ),
                        border: Border.all(
                          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      'EXPORT',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: UnderwaterTheme.surfaceCyan1,
                                        shadows: [
                                          Shadow(
                                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Content
                                    Row(
                                      children: [
                                        const Icon(Icons.download, color: UnderwaterTheme.surfaceCyan1),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Export your fishing data to keep a backup or share your progress.',
                                            style: TextStyle(
                                              color: UnderwaterTheme.textLight.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _exportToJSON(context, appProvider),
                                  icon: const Icon(Icons.code, size: 18),
                                  label: const Text('JSON'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: UnderwaterTheme.surfaceCyan1,
                                    foregroundColor: UnderwaterTheme.deepNavy2,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _exportToCSV(context, appProvider),
                                  icon: const Icon(Icons.table_chart, size: 18),
                                  label: const Text('CSV'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: UnderwaterTheme.surfaceCyan1,
                                    foregroundColor: UnderwaterTheme.deepNavy2,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                          const SizedBox(height: 24),

                          // Danger Zone - Title + Content in one Frosted Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      UnderwaterTheme.deepNavy1.withOpacity(0.7),
                                      UnderwaterTheme.deepNavy2.withOpacity(0.6),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: UnderwaterTheme.deepPurplePink1.withOpacity(0.6),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  boxShadow: [
                                    BoxShadow(
                                      color: UnderwaterTheme.deepPurplePink1.withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      'DANGER ZONE',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: UnderwaterTheme.deepPurplePink1,
                                        shadows: [
                                          Shadow(
                                            color: UnderwaterTheme.deepPurplePink1.withOpacity(0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Content
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning_rounded,
                                          color: UnderwaterTheme.deepPurplePink1,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Permanently delete all your data. This action cannot be undone!',
                                            style: const TextStyle(
                                              color: UnderwaterTheme.textLight,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                title: const Text('DELETE ALL DATA?'),
                                content: const Text(
                                  'This will permanently delete all your catches, progress, and achievements. This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('CANCEL'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.colorError,
                                    ),
                                    child: const Text('DELETE'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await appProvider.deleteAllData();
                              
                              // Navigate back to root and let the app rebuild to show onboarding
                              if (context.mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            }
                          },
                                        icon: const Icon(Icons.delete_forever, size: 20),
                                        label: const Text(
                                          'DELETE ALL DATA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: UnderwaterTheme.deepPurplePink1,
                                          foregroundColor: UnderwaterTheme.textLight,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          ),
                                          elevation: 4,
                                        ),
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
}

class _DataStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UnderwaterTheme.deepNavy2.withOpacity(0.3),
        border: Border.all(
          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: UnderwaterTheme.surfaceCyan1, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: UnderwaterTheme.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: UnderwaterTheme.surfaceCyan1.withOpacity(0.8),
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
