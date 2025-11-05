import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedExperience = '';
  final Set<String> _selectedEnvironments = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate() || 
        _selectedExperience.isEmpty ||
        _selectedEnvironments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields'),
          backgroundColor: AppTheme.colorError,
        ),
      );
      return;
    }

    final profile = UserProfile(
      name: _nameController.text.trim(),
      experienceLevel: _selectedExperience,
      favoriteEnvironments: _selectedEnvironments.toList(),
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.createUserProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo Section
                Column(
                  children: [
                    Image.asset(
                      'assets/logo/app_bbc_character_3.png',
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    // Welcome Text with ocean vibe
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                            UnderwaterTheme.surfaceCyan2.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.7),
                          width: 2,
                        ),
                        boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 20),
                      ),
                      child: Text(
                        'WELCOME, ANGLER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Form Section - with transparency
                Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              UnderwaterTheme.upperAqua1.withOpacity(0.3),
                              UnderwaterTheme.upperAqua2.withOpacity(0.25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: UnderwaterTheme.glowCyan(opacity: 0.2, blur: 24),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'YOUR NAME',
                            hintText: 'Enter your name',
                            labelStyle: TextStyle(
                            color: UnderwaterTheme.textLight.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                          hintStyle: TextStyle(
                            color: UnderwaterTheme.textCyan.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: UnderwaterTheme.deepNavy2.withOpacity(0.5),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: UnderwaterTheme.surfaceCyan1,
                              width: 2,
                            ),
                          ),
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.colorError,
                                width: 2,
                              ),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.colorError,
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
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _ExperienceButton(
                                    label: 'BEGINNER',
                                    value: 'beginner',
                                    isSelected: _selectedExperience == 'beginner',
                                    onTap: () {
                                      setState(() => _selectedExperience = 'beginner');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ExperienceButton(
                                    label: 'INTERMEDIATE',
                                    value: 'intermediate',
                                    isSelected: _selectedExperience == 'intermediate',
                                    onTap: () {
                                      setState(() => _selectedExperience = 'intermediate');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ExperienceButton(
                                    label: 'EXPERT',
                                    value: 'expert',
                                    isSelected: _selectedExperience == 'expert',
                                    onTap: () {
                                      setState(() => _selectedExperience = 'expert');
                                    },
                                  ),
                                ),
                                const Expanded(child: SizedBox()), // Empty space for balance
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Favorite Environments
                        Text(
                          'FAVORITE FISHING ENVIRONMENTS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _EnvironmentCheckbox(
                              label: 'Lakes',
                              value: 'lakes',
                              isSelected: _selectedEnvironments.contains('lakes'),
                              onChanged: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedEnvironments.add('lakes');
                                  } else {
                                    _selectedEnvironments.remove('lakes');
                                  }
                                });
                              },
                            ),
                            _EnvironmentCheckbox(
                              label: 'Rivers',
                              value: 'rivers',
                              isSelected: _selectedEnvironments.contains('rivers'),
                              onChanged: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedEnvironments.add('rivers');
                                  } else {
                                    _selectedEnvironments.remove('rivers');
                                  }
                                });
                              },
                            ),
                            _EnvironmentCheckbox(
                              label: 'Sea/Ocean',
                              value: 'sea',
                              isSelected: _selectedEnvironments.contains('sea'),
                              onChanged: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedEnvironments.add('sea');
                                  } else {
                                    _selectedEnvironments.remove('sea');
                                  }
                                });
                              },
                            ),
                            _EnvironmentCheckbox(
                              label: 'Ponds',
                              value: 'ponds',
                              isSelected: _selectedEnvironments.contains('ponds'),
                              onChanged: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedEnvironments.add('ponds');
                                  } else {
                                    _selectedEnvironments.remove('ponds');
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UnderwaterTheme.surfaceCyan1,
                              foregroundColor: UnderwaterTheme.deepNavy2,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              elevation: 0,
                              shadowColor: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                            ),
                            child: const Text(
                              'START YOUR JOURNEY',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                fontSize: 16,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperienceButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExperienceButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    UnderwaterTheme.surfaceCyan1,
                    UnderwaterTheme.surfaceCyan2,
                  ],
                )
              : LinearGradient(
                  colors: [
                    UnderwaterTheme.deepNavy2.withOpacity(0.7),
                    UnderwaterTheme.deepNavy1.withOpacity(0.6),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected 
                ? UnderwaterTheme.surfaceCyan1 
                : UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: isSelected 
              ? UnderwaterTheme.glowCyan(opacity: 0.4, blur: 12)
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? UnderwaterTheme.deepNavy2 
                  : UnderwaterTheme.textLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _EnvironmentCheckbox extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _EnvironmentCheckbox({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    UnderwaterTheme.surfaceCyan1,
                    UnderwaterTheme.surfaceCyan2,
                  ],
                )
              : LinearGradient(
                  colors: [
                    UnderwaterTheme.deepNavy2.withOpacity(0.7),
                    UnderwaterTheme.deepNavy1.withOpacity(0.6),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected 
                ? UnderwaterTheme.surfaceCyan1 
                : UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: isSelected 
              ? UnderwaterTheme.glowCyan(opacity: 0.4, blur: 12)
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected 
                    ? UnderwaterTheme.deepNavy2 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected 
                      ? UnderwaterTheme.deepNavy2 
                      : UnderwaterTheme.textLight.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: UnderwaterTheme.surfaceCyan1)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? UnderwaterTheme.deepNavy2 
                    : UnderwaterTheme.textLight,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
