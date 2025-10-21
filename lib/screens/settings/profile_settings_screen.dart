import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/underwater_theme.dart';
import '../../widgets/frosted_app_bar.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateProfileImage(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
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
              color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SELECT IMAGE SOURCE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UnderwaterTheme.textLight,
                  shadows: UnderwaterTheme.textShadowLight,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(Icons.photo_library, color: UnderwaterTheme.surfaceCyan1),
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(
                    color: UnderwaterTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(Icons.camera_alt, color: UnderwaterTheme.surfaceCyan1),
                ),
                title: const Text(
                  'Camera',
                  style: TextStyle(
                    color: UnderwaterTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: UnderwaterTheme.textCyan,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      side: BorderSide(
                        color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );

        if (image != null && context.mounted) {
          final appProvider = Provider.of<AppProvider>(context, listen: false);
          await appProvider.updateProfileAvatar(image.path);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated!'),
                backgroundColor: AppTheme.colorSuccess,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating image: $e'),
              backgroundColor: AppTheme.colorError,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeProfileImage(BuildContext context) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.updateProfileAvatar(null);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image removed'),
          backgroundColor: AppTheme.colorSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(
        title: 'PROFILE',
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
            final profile = appProvider.userProfile;
            if (profile == null) return const SizedBox();

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
                        children: [
                          // Profile Image Section in Frosted Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: double.infinity,
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
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  border: Border.all(
                                    color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Avatar
                                    GestureDetector(
                                      onTap: () => _updateProfileImage(context),
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: UnderwaterTheme.deepNavy2.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          border: Border.all(
                                            color: UnderwaterTheme.surfaceCyan1,
                                            width: 3,
                                          ),
                                          boxShadow: UnderwaterTheme.glowCyan(opacity: 0.4, blur: 12),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: profile.avatarPath != null && profile.avatarPath!.isNotEmpty
                                            ? Image.file(
                                                File(profile.avatarPath!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.person,
                                                    size: 70,
                                                    color: UnderwaterTheme.textLight,
                                                  );
                                                },
                                              )
                                            : const Icon(
                                                Icons.person,
                                                size: 70,
                                                color: UnderwaterTheme.textLight,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _updateProfileImage(context),
                                          icon: const Icon(Icons.photo_camera, size: 18),
                                          label: const Text('CHANGE PHOTO'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: UnderwaterTheme.surfaceCyan1,
                                            foregroundColor: UnderwaterTheme.deepNavy2,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                            ),
                                          ),
                                        ),
                                        if (profile.avatarPath != null && profile.avatarPath!.isNotEmpty) ...[
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            height: 46,
                                            width: 46,
                                            child: IconButton(
                                              onPressed: () => _removeProfileImage(context),
                                              icon: const Icon(Icons.delete, size: 20),
                                              color: UnderwaterTheme.deepPurplePink1,
                                              tooltip: 'Remove photo',
                                              style: IconButton.styleFrom(
                                                side: BorderSide(
                                                  color: UnderwaterTheme.deepPurplePink1,
                                                  width: 2,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Profile Information Cards
                          _ProfileInfoCard(
                            icon: Icons.person,
                            label: 'NAME',
                            value: profile.name,
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoCard(
                            icon: Icons.location_on,
                            label: 'LOCATION',
                            value: profile.location,
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoCard(
                            icon: Icons.emoji_events,
                            label: 'EXPERIENCE LEVEL',
                            value: profile.experienceLevel.toUpperCase(),
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoCard(
                            icon: Icons.water,
                            label: 'FAVORITE ENVIRONMENTS',
                            value: profile.favoriteEnvironments.join(', '),
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

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Icon(
                icon,
                color: UnderwaterTheme.surfaceCyan1,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: UnderwaterTheme.surfaceCyan1.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: UnderwaterTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
