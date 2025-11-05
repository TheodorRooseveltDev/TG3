import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';
import '../../models/user_profile.dart';
import '../../utils/app_theme.dart';
import '../../utils/underwater_theme.dart';
import '../../widgets/frosted_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late String _selectedExperience;
  late Set<String> _selectedEnvironments;
  XFile? _newAvatarFile;
  String? _currentAvatarPath;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppProvider>(context, listen: false).userProfile!;
    _nameController.text = profile.name;
    _selectedExperience = profile.experienceLevel;
    _selectedEnvironments = Set<String>.from(profile.favoriteEnvironments);
    _currentAvatarPath = profile.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _newAvatarFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEnvironments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one favorite environment')),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentProfile = appProvider.userProfile!;

    final updatedProfile = UserProfile(
      name: _nameController.text.trim(),
      experienceLevel: _selectedExperience,
      favoriteEnvironments: _selectedEnvironments.toList(),
      avatarPath: _newAvatarFile?.path ?? _currentAvatarPath,
      dailyStreak: currentProfile.dailyStreak,
      weeklyStreak: currentProfile.weeklyStreak,
      baitTokens: currentProfile.baitTokens,
      completedQuests: currentProfile.completedQuests,
      unlockedFishIds: currentProfile.unlockedFishIds,
      createdAt: currentProfile.createdAt,
      lastActive: DateTime.now(),
    );

    await appProvider.updateUserProfile(updatedProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully! ✓'),
          backgroundColor: AppTheme.colorSuccess,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar(
        title: 'EDIT PROFILE',
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: UnderwaterTheme.surfaceCyan1,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: UnderwaterTheme.textShadowLight,
              ),
            ),
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
        child: LayoutBuilder(
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
                      // Frosted Header with Avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
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
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(
                                color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Avatar
                                InkWell(
                                  onTap: _pickAvatar,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: UnderwaterTheme.deepNavy2.withOpacity(0.5),
                                      border: Border.all(
                                        color: UnderwaterTheme.surfaceCyan1,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                      boxShadow: UnderwaterTheme.glowCyan(opacity: 0.4, blur: 12),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: _newAvatarFile != null
                                        ? Image.file(
                                            File(_newAvatarFile!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : _currentAvatarPath != null
                                            ? Image.file(
                                                File(_currentAvatarPath!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: UnderwaterTheme.textLight,
                                                    ),
                                                  );
                                                },
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: UnderwaterTheme.textLight,
                                                ),
                                              ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _pickAvatar,
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  label: const Text('CHANGE AVATAR'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: UnderwaterTheme.surfaceCyan1,
                                    side: const BorderSide(
                                      color: UnderwaterTheme.surfaceCyan1,
                                      width: 2,
                                    ),
                                    backgroundColor: UnderwaterTheme.deepNavy2.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Frosted Content Container with Form
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

              // Name Field
              Text(
                'NAME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: UnderwaterTheme.surfaceCyan1,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: UnderwaterTheme.textLight),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(
                    color: UnderwaterTheme.textLight.withOpacity(0.5),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: UnderwaterTheme.surfaceCyan1,
                  ),
                  filled: true,
                  fillColor: UnderwaterTheme.deepNavy1.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: const BorderSide(
                      color: UnderwaterTheme.surfaceCyan1,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: const BorderSide(
                      color: UnderwaterTheme.surfaceCyan1,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: const BorderSide(
                      color: UnderwaterTheme.deepPurplePink1,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: const BorderSide(
                      color: UnderwaterTheme.deepPurplePink1,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Experience Level
              Text(
                'EXPERIENCE LEVEL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: UnderwaterTheme.surfaceCyan1,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildExperienceOption(
                      'Beginner',
                      Icons.trending_up,
                      'beginner',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExperienceOption(
                      'Intermediate',
                      Icons.bar_chart,
                      'intermediate',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExperienceOption(
                      'Expert',
                      Icons.military_tech,
                      'expert',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Favorite Environments
              Text(
                'FAVORITE ENVIRONMENTS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: UnderwaterTheme.surfaceCyan1,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildEnvironmentChip('Lakes', Icons.water),
                  _buildEnvironmentChip('Rivers', Icons.waves),
                  _buildEnvironmentChip('Sea', Icons.sailing),
                  _buildEnvironmentChip('Ponds', Icons.local_drink),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnderwaterTheme.surfaceCyan1,
                    foregroundColor: UnderwaterTheme.deepNavy2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExperienceOption(String label, IconData icon, String value) {
    final isSelected = _selectedExperience == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedExperience = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    UnderwaterTheme.surfaceCyan1.withOpacity(0.2),
                    UnderwaterTheme.upperAqua1.withOpacity(0.15),
                  ],
                )
              : null,
          color: isSelected ? null : UnderwaterTheme.deepNavy1.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? UnderwaterTheme.surfaceCyan1
                : UnderwaterTheme.textLight.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? UnderwaterTheme.glowCyan(opacity: 0.3, blur: 8)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? UnderwaterTheme.surfaceCyan1
                  : UnderwaterTheme.textLight.withOpacity(0.7),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? UnderwaterTheme.textLight
                    : UnderwaterTheme.textLight.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentChip(String label, IconData icon) {
    final key = label.toLowerCase();
    final isSelected = _selectedEnvironments.contains(key);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedEnvironments.remove(key);
          } else {
            _selectedEnvironments.add(key);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                    UnderwaterTheme.upperAqua1.withOpacity(0.2),
                  ],
                )
              : null,
          color: isSelected ? null : UnderwaterTheme.deepNavy1.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? UnderwaterTheme.surfaceCyan1
                : UnderwaterTheme.textLight.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? UnderwaterTheme.glowCyan(opacity: 0.3, blur: 8)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? UnderwaterTheme.surfaceCyan1
                  : UnderwaterTheme.textLight.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? UnderwaterTheme.textLight
                    : UnderwaterTheme.textLight.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
