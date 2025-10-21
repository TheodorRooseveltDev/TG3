import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../models/catch_entry.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../widgets/frosted_app_bar.dart';
import 'edit_catch_screen.dart';
import 'settings_tab.dart';
import 'unlock_fish_screen.dart';

// Helper class for building placeholder images
class _PlaceholderImageBuilder {
  static Widget build(String fishName, {double? height}) {
    return SizedBox(
      height: height,
      child: Image.asset(
        'assets/images/empty.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to programmatic placeholder if empty.png fails to load
          return Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.colorSecondaryDark.withOpacity(0.3),
                  AppTheme.colorSecondary.withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phishing,
                    size: height != null ? 60 : 40,
                    color: AppTheme.colorSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Photo',
                    style: TextStyle(
                      color: AppTheme.colorTextMuted,
                      fontSize: height != null ? 14 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (height != null && height > 150)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        fishName,
                        style: TextStyle(
                          color: AppTheme.colorTextSecondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  String _sortBy = 'date'; // 'date', 'weight', 'length', 'species'
  bool _sortAscending = false;
  String _filterBy = 'all'; // 'all', 'today', 'week', 'month', 'trophy'
  String? _filterSpecies; // null or fish species ID
  bool _isGridView = false; // toggle between list and grid

  List<CatchEntry> _getSortedAndFilteredCatches(List<CatchEntry> catches) {
    // Create a copy to avoid modifying the original list
    List<CatchEntry> filteredCatches = List.from(catches);

    // Apply filters
    final now = DateTime.now();
    switch (_filterBy) {
      case 'today':
        filteredCatches = filteredCatches.where((c) {
          return c.caughtAt.year == now.year &&
              c.caughtAt.month == now.month &&
              c.caughtAt.day == now.day;
        }).toList();
        break;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filteredCatches = filteredCatches
            .where((c) => c.caughtAt.isAfter(weekAgo))
            .toList();
        break;
      case 'month':
        filteredCatches = filteredCatches.where((c) {
          return c.caughtAt.year == now.year && c.caughtAt.month == now.month;
        }).toList();
        break;
      case 'trophy':
        filteredCatches = filteredCatches
            .where((c) => c.isTrophyCatch)
            .toList();
        break;
    }

    // Filter by species if selected
    if (_filterSpecies != null) {
      filteredCatches = filteredCatches
          .where((c) => c.fishSpeciesId == _filterSpecies)
          .toList();
    }

    // Sort
    filteredCatches.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.caughtAt.compareTo(b.caughtAt);
          break;
        case 'weight':
          comparison = (a.weight ?? 0).compareTo(b.weight ?? 0);
          break;
        case 'length':
          comparison = (a.length ?? 0).compareTo(b.length ?? 0);
          break;
        case 'species':
          comparison = a.fishName.compareTo(b.fishName);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filteredCatches;
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnderwaterTheme.deepNavy1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: BorderSide(
            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
            width: 2,
          ),
        ),
        title: const Text(
          'SORT BY',
          style: TextStyle(
            color: UnderwaterTheme.textLight,
            shadows: UnderwaterTheme.textShadowLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Date', 'date'),
            _buildSortOption('Weight', 'weight'),
            _buildSortOption('Length', 'length'),
            _buildSortOption('Species', 'species'),
            const Divider(color: UnderwaterTheme.surfaceCyan1),
            SwitchListTile(
              title: const Text(
                'Ascending',
                style: TextStyle(color: UnderwaterTheme.textLight),
              ),
              value: _sortAscending,
              activeColor: UnderwaterTheme.surfaceCyan1,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: const TextStyle(color: UnderwaterTheme.textLight),
      ),
      value: value,
      groupValue: _sortBy,
      activeColor: UnderwaterTheme.surfaceCyan1,
      onChanged: (val) {
        setState(() {
          _sortBy = val!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FILTER BY'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All Catches', 'all'),
            _buildFilterOption('Today', 'today'),
            _buildFilterOption('This Week', 'week'),
            _buildFilterOption('This Month', 'month'),
            _buildFilterOption('Trophies Only', 'trophy'),
            const Divider(),
            ListTile(
              title: Text(
                _filterSpecies == null ? 'By Species' : 'Clear Species Filter',
              ),
              trailing: const Icon(Icons.clear),
              onTap: () {
                setState(() {
                  _filterSpecies = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterBy = 'all';
                _filterSpecies = null;
              });
              Navigator.pop(context);
            },
            child: const Text('CLEAR ALL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterBy == value;
    return InkWell(
      onTap: () {
        setState(() {
          _filterBy = value;
          _filterSpecies = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    UnderwaterTheme.surfaceCyan1.withOpacity(0.8),
                    UnderwaterTheme.surfaceCyan2.withOpacity(0.6),
                  ],
                )
              : null,
          color: isSelected ? null : UnderwaterTheme.deepNavy2.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected
                ? UnderwaterTheme.surfaceCyan1
                : UnderwaterTheme.textLight.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected ? UnderwaterTheme.glowCyan(opacity: 0.3, blur: 8) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? UnderwaterTheme.deepNavy2 : UnderwaterTheme.textLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
            shadows: isSelected ? null : UnderwaterTheme.textShadowLight,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    UnderwaterTheme.midPeriwinkle.withOpacity(0.7),
                    UnderwaterTheme.midLavender.withOpacity(0.6),
                  ],
                )
              : null,
          color: isSelected ? null : UnderwaterTheme.deepNavy2.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected
                ? UnderwaterTheme.midPeriwinkle
                : UnderwaterTheme.textLight.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected ? UnderwaterTheme.glowPurple(opacity: 0.3, blur: 8) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: UnderwaterTheme.textLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
            shadows: UnderwaterTheme.textShadowLight,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _filterBy,
      onChanged: (val) {
        setState(() {
          _filterBy = val!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showCatchDetails(CatchEntry catchEntry) {
    // Debug print to see actual data
    print('=== CATCH DETAILS ===');
    print('Fish: ${catchEntry.fishName}');
    print('Method: "${catchEntry.fishingMethod}"');
    print('Location: "${catchEntry.location}"');
    print('Notes: "${catchEntry.notes}"');
    print('Weather: "${catchEntry.weatherConditions}"');
    print('====================');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                UnderwaterTheme.deepNavy1.withOpacity(0.95),
                UnderwaterTheme.deepNavy2.withOpacity(0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      UnderwaterTheme.surfaceCyan1.withOpacity(0.8),
                      UnderwaterTheme.surfaceCyan2.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                  boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phishing, color: UnderwaterTheme.deepNavy2),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'CATCH DETAILS',
                        style: TextStyle(
                          color: UnderwaterTheme.deepNavy2,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: UnderwaterTheme.deepNavy2),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo - full width
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Container(
                          width: double.infinity,
                          color: AppTheme.colorSurface,
                          child: catchEntry.photoPath != null &&
                                  catchEntry.photoPath!.isNotEmpty
                              ? GestureDetector(
                                  onTap: () =>
                                      _showFullScreenImage(catchEntry.photoPath!),
                                  child: Image.file(
                                    File(catchEntry.photoPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _PlaceholderImageBuilder.build(
                                        catchEntry.fishName,
                                        height: 250,
                                      );
                                    },
                                  ),
                                )
                              : _PlaceholderImageBuilder.build(
                                  catchEntry.fishName,
                                  height: 250,
                                ),
                        ),
                      ),

                      // Details Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fish Name and Badges
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    catchEntry.fishName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: UnderwaterTheme.surfaceCyan1,
                                      shadows: UnderwaterTheme.textShadowLight,
                                    ),
                                  ),
                                ),
                                if (catchEntry.isPersonalBest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      border: Border.all(
                                        color: Colors.amber[700]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Text(
                                      'PB',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                if (catchEntry.isTrophyCatch)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.colorAccent,
                                        border: Border.all(
                                          color: AppTheme.colorAccent,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Text(
                                        '🏆',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: UnderwaterTheme.textLight.withOpacity(0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy • hh:mm a',
                                  ).format(catchEntry.caughtAt),
                                  style: TextStyle(
                                    color: UnderwaterTheme.textLight.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Stats Grid
                            Consumer<AppProvider>(
                              builder: (context, appProvider, child) {
                                final prefs = appProvider.preferences;
                                final weightStr = catchEntry.weight != null
                                    ? prefs.formatWeight(catchEntry.weight!)
                                    : 'N/A';
                                final lengthStr = catchEntry.length != null
                                    ? prefs.formatLength(catchEntry.length!)
                                    : 'N/A';
                                
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        'Weight',
                                        weightStr,
                                        Icons.monitor_weight,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Length',
                                        lengthStr,
                                        Icons.straighten,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Method - Always show if data exists
                            _buildInfoCard(
                              'FISHING METHOD',
                              catchEntry.fishingMethod.isEmpty ? 'Not specified' : catchEntry.fishingMethod,
                              Icons.phishing,
                            ),

                            // Location - Always show if data exists
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              'LOCATION',
                              (catchEntry.location == null || catchEntry.location!.isEmpty) 
                                  ? 'Not specified' 
                                  : catchEntry.location!,
                              Icons.location_on,
                            ),

                            // Notes - Only show if not empty
                            if (catchEntry.notes != null && catchEntry.notes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                'NOTES',
                                catchEntry.notes!,
                                Icons.note,
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditCatchScreen(
                                            catchEntry: catchEntry,
                                          ),
                                        ),
                                      );
                                      if (result == true && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Catch updated successfully',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text(
                                      'EDIT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: UnderwaterTheme.surfaceCyan1,
                                      foregroundColor: UnderwaterTheme.deepNavy2,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      // Get the button's position for iPad popover
                                      final box = context.findRenderObject() as RenderBox?;
                                      await _shareCatch(
                                        catchEntry,
                                        box != null
                                            ? box.localToGlobal(Offset.zero) & box.size
                                            : null,
                                      );
                                    },
                                    icon: const Icon(Icons.share, size: 18),
                                    label: const Text(
                                      'SHARE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: UnderwaterTheme.midPeriwinkle,
                                      foregroundColor: UnderwaterTheme.textLight,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Delete Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteCatch(catchEntry);
                                },
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text(
                                  'DELETE CATCH',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red[400],
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  side: BorderSide(
                                    color: Colors.red[400]!,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UnderwaterTheme.midPeriwinkle.withOpacity(0.3),
            UnderwaterTheme.midLavender.withOpacity(0.25),
          ],
        ),
        border: Border.all(
          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: UnderwaterTheme.glowPurple(opacity: 0.2, blur: 8),
      ),
      child: Column(
        children: [
          Icon(icon, color: UnderwaterTheme.surfaceCyan1, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UnderwaterTheme.textLight,
              shadows: UnderwaterTheme.textShadowLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: UnderwaterTheme.textLight.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UnderwaterTheme.deepNavy1.withOpacity(0.5),
            UnderwaterTheme.deepNavy2.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: UnderwaterTheme.surfaceCyan1, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: UnderwaterTheme.textLight.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: UnderwaterTheme.textLight,
                    fontWeight: FontWeight.w500,
                    shadows: UnderwaterTheme.textShadowLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCatch(CatchEntry catchEntry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        title: const Text('DELETE CATCH'),
        content: Text(
          'Are you sure you want to delete this ${catchEntry.fishName} catch?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.deleteCatch(catchEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catch deleted'),
            backgroundColor: AppTheme.colorSecondary,
          ),
        );
      }
    }
  }

  Future<void> _shareCatch(CatchEntry catchEntry, Rect? sharePositionOrigin) async {
    try {
      // Build share text with catch details
      final dateFormat = DateFormat('MMM d, yyyy h:mm a');
      final formattedDate = dateFormat.format(catchEntry.caughtAt);
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final prefs = appProvider.preferences;

      String shareText = '🎣 Big Bass Catcher - My Catch!\n\n';
      shareText += '🐟 Fish: ${catchEntry.fishName}\n';

      if (catchEntry.weight != null) {
        shareText += '⚖️ Weight: ${prefs.formatWeight(catchEntry.weight!)}\n';
      }

      if (catchEntry.length != null) {
        shareText += '📏 Length: ${prefs.formatLength(catchEntry.length!)}\n';
      }

      if (catchEntry.fishingMethod.isNotEmpty) {
        shareText += '🎯 Method: ${catchEntry.fishingMethod}\n';
      }

      if (catchEntry.isPersonalBest) {
        shareText += '🏆 Personal Best!\n';
      }

      if (catchEntry.isTrophyCatch) {
        shareText += '🏅 Trophy Catch!\n';
      }

      shareText += '📅 Date: $formattedDate\n';

      if (catchEntry.location != null && catchEntry.location!.isNotEmpty) {
        shareText += '📍 Location: ${catchEntry.location}\n';
      }

      if (catchEntry.notes != null && catchEntry.notes!.isNotEmpty) {
        shareText += '\n📝 Notes: ${catchEntry.notes}\n';
      }

      // Share with photo if available
      if (catchEntry.photoPath != null && catchEntry.photoPath!.isNotEmpty) {
        final file = File(catchEntry.photoPath!);
        if (await file.exists()) {
          await Share.shareXFiles(
            [XFile(catchEntry.photoPath!)],
            text: shareText,
            sharePositionOrigin: sharePositionOrigin,
          );
        } else {
          // Photo doesn't exist, share text only
          await Share.share(
            shareText,
            sharePositionOrigin: sharePositionOrigin,
          );
        }
      } else {
        // No photo, share text only
        await Share.share(
          shareText,
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing catch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        clipBehavior: Clip.antiAlias,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: FrostedAppBar(
            title: 'FISH LOG',
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnlockFishScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(color: UnderwaterTheme.textLight.withOpacity(0.6), width: 2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: UnderwaterTheme.glowCyan(opacity: 0.2, blur: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.token, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${appProvider.userProfile?.baitTokens ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsTab(),
                        ),
                      );
                    },
                    tooltip: 'Settings',
                  ),
                  if (appProvider.hasNewAchievements)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Builder(
            builder: (context) {
              final catches = _getSortedAndFilteredCatches(appProvider.catches);

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                // Stats Section
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'TOTAL CATCHES',
                        value: '${appProvider.totalCatches}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'UNIQUE SPECIES',
                        value: '${appProvider.uniqueSpecies}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'TROPHIES',
                        value: '${appProvider.trophyCatches}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Filter and Sort Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        UnderwaterTheme.deepNavy1.withOpacity(0.6),
                        UnderwaterTheme.deepNavy2.withOpacity(0.7),
                      ],
                    ),
                    border: Border.all(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: UnderwaterTheme.glowCyan(opacity: 0.15, blur: 12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FILTER',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: UnderwaterTheme.textLight,
                                    shadows: UnderwaterTheme.textShadowLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildFilterChip('All', 'all'),
                                    _buildFilterChip('Today', 'today'),
                                    _buildFilterChip('Week', 'week'),
                                    _buildFilterChip('Month', 'month'),
                                    _buildFilterChip('Trophies', 'trophy'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SORT BY',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: UnderwaterTheme.textLight,
                                    shadows: UnderwaterTheme.textShadowLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildSortChip('Newest', 'date-desc'),
                                          _buildSortChip('Oldest', 'date-asc'),
                                          _buildSortChip('Heaviest', 'weight-desc'),
                                          _buildSortChip('Longest', 'length-desc'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isGridView = !_isGridView;
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          backgroundColor: UnderwaterTheme.deepNavy2.withOpacity(0.5),
                                          side: BorderSide(
                                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          _isGridView ? Icons.view_list : Icons.grid_view,
                                          size: 20,
                                          color: UnderwaterTheme.surfaceCyan1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Empty State
                if (catches.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          UnderwaterTheme.deepNavy1.withOpacity(0.5),
                          UnderwaterTheme.deepNavy2.withOpacity(0.6),
                        ],
                      ),
                      border: Border.all(
                        color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.phishing,
                            size: 64,
                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your fish log is empty.\nStart catching to build your collection!',
                            style: TextStyle(
                              color: UnderwaterTheme.textLight,
                              shadows: UnderwaterTheme.textShadowLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Sort indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UnderwaterTheme.deepNavy1.withOpacity(0.5),
                          UnderwaterTheme.deepNavy2.withOpacity(0.6),
                        ],
                      ),
                      border: Border.all(
                        color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          size: 16,
                          color: UnderwaterTheme.surfaceCyan1,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sorted by $_sortBy (${_sortAscending ? 'asc' : 'desc'})${_filterBy != 'all' ? ' • Filtered: $_filterBy' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: UnderwaterTheme.textLight,
                            shadows: UnderwaterTheme.textShadowLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Catch List or Grid
                  if (_isGridView)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: catches.length,
                      itemBuilder: (context, index) {
                        final catchEntry = catches[index];
                        return _CatchGridCard(
                          catchEntry: catchEntry,
                          onTap: () => _showCatchDetails(catchEntry),
                        );
                      },
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: catches.length,
                      itemBuilder: (context, index) {
                        final catchEntry = catches[index];
                        return _CatchCard(
                          catchEntry: catchEntry,
                          onTap: () => _showCatchDetails(catchEntry),
                        );
                      },
                    ),
                ],

                const SizedBox(height: 100),
              ],  // End of Column children
                    ),  // End of Column
                  ),  // End of Padding
                ),  // End of ConstrainedBox
              );  // End of return SingleChildScrollView
            },  // End of LayoutBuilder builder
          );  // End of LayoutBuilder
            },  // End of Builder builder
          ),  // End of Builder
            ),  // End of Container child
        );  // End of Scaffold body
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UnderwaterTheme.deepNavy1.withOpacity(0.6),
            UnderwaterTheme.deepNavy2.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: UnderwaterTheme.glowCyan(opacity: 0.15, blur: 12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: UnderwaterTheme.surfaceCyan1,
              shadows: UnderwaterTheme.textShadowLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: UnderwaterTheme.textLight,
              shadows: UnderwaterTheme.textShadowLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CatchCard extends StatelessWidget {
  final CatchEntry catchEntry;
  final VoidCallback onTap;

  const _CatchCard({required this.catchEntry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              UnderwaterTheme.deepNavy1.withOpacity(0.6),
              UnderwaterTheme.deepNavy2.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: catchEntry.isTrophyCatch
                ? UnderwaterTheme.midLavender
                : UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
            width: catchEntry.isTrophyCatch ? 3 : 2,
          ),
          boxShadow: catchEntry.isTrophyCatch
              ? UnderwaterTheme.glowPurple(opacity: 0.3, blur: 16)
              : UnderwaterTheme.glowCyan(opacity: 0.15, blur: 12),
        ),
        child: Row(
          children: [
            // Image Section (Left)
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: catchEntry.photoPath != null &&
                          catchEntry.photoPath!.isNotEmpty
                      ? Image.file(
                          File(catchEntry.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _PlaceholderImageBuilder.build(
                              catchEntry.fishName,
                              height: 120,
                            );
                          },
                        )
                      : _PlaceholderImageBuilder.build(
                          catchEntry.fishName,
                          height: 120,
                        ),
                ),
                // Badges overlay
                if (catchEntry.isPersonalBest || catchEntry.isTrophyCatch)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Row(
                      children: [
                        if (catchEntry.isPersonalBest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              border: Border.all(
                                color: Colors.amber[700]!,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'PB',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (catchEntry.isPersonalBest && catchEntry.isTrophyCatch)
                          const SizedBox(width: 3),
                        if (catchEntry.isTrophyCatch)
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.colorAccent,
                              border: Border.all(
                                color: AppTheme.colorAccent,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              '🏆',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),

            // Details Section (Center)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fish Name
                    Text(
                      catchEntry.fishName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UnderwaterTheme.surfaceCyan1,
                        letterSpacing: 0.5,
                        shadows: UnderwaterTheme.textShadowLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Stats Row
                    Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        final prefs = appProvider.preferences;
                        final weightStr = catchEntry.weight != null
                            ? prefs.formatWeight(catchEntry.weight!)
                            : 'N/A';
                        final lengthStr = catchEntry.length != null
                            ? prefs.formatLength(catchEntry.length!)
                            : 'N/A';
                        return Row(
                          children: [
                            // Weight
                            const Icon(
                              Icons.monitor_weight,
                              size: 14,
                              color: UnderwaterTheme.midPeriwinkle,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              weightStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: UnderwaterTheme.textLight,
                                shadows: UnderwaterTheme.textShadowLight,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Length
                            const Icon(
                              Icons.straighten,
                              size: 14,
                              color: UnderwaterTheme.midPeriwinkle,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              lengthStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: UnderwaterTheme.textLight,
                                shadows: UnderwaterTheme.textShadowLight,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: UnderwaterTheme.textLight.withOpacity(0.7),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(catchEntry.caughtAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: UnderwaterTheme.textLight.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow (Right)
            Container(
              width: 44,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_right,
                  color: UnderwaterTheme.surfaceCyan1,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatchGridCard extends StatelessWidget {
  final CatchEntry catchEntry;
  final VoidCallback onTap;

  const _CatchGridCard({required this.catchEntry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d').format(catchEntry.caughtAt);

    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final prefs = appProvider.preferences;
        final weightStr = prefs.formatWeight(catchEntry.weight!);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UnderwaterTheme.deepNavy1.withOpacity(0.6),
                  UnderwaterTheme.deepNavy2.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: catchEntry.isTrophyCatch
                    ? UnderwaterTheme.midLavender
                    : UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                width: catchEntry.isTrophyCatch ? 3 : 2,
              ),
              boxShadow: catchEntry.isTrophyCatch
                  ? UnderwaterTheme.glowPurple(opacity: 0.3, blur: 16)
                  : UnderwaterTheme.glowCyan(opacity: 0.15, blur: 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey[200],
                    child:
                        catchEntry.photoPath != null &&
                            catchEntry.photoPath!.isNotEmpty
                        ? Image.file(
                            File(catchEntry.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _PlaceholderImageBuilder.build(
                                catchEntry.fishName,
                              );
                            },
                          )
                        : _PlaceholderImageBuilder.build(catchEntry.fishName),
                  ),
                ),
                // Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    catchEntry.fishName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: UnderwaterTheme.surfaceCyan1,
                                      shadows: UnderwaterTheme.textShadowLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (catchEntry.isPersonalBest)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.colorAccent,
                                    ),
                                    child: const Text(
                                      'PB',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                if (catchEntry.isPersonalBest &&
                                    catchEntry.isTrophyCatch)
                                  const SizedBox(width: 2),
                                if (catchEntry.isTrophyCatch)
                                  const Icon(
                                    Icons.emoji_events,
                                    size: 16,
                                    color: AppTheme.colorAccent,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (catchEntry.weight != null)
                              Text(
                                weightStr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: UnderwaterTheme.textLight,
                                  fontWeight: FontWeight.w600,
                                  shadows: UnderwaterTheme.textShadowLight,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: UnderwaterTheme.textLight.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
