import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../widgets/frosted_app_bar.dart';
import 'settings/profile_settings_screen.dart';
import 'settings/edit_profile_screen.dart';
import 'settings/preferences_screen.dart';
import 'settings/data_settings_screen.dart';
import 'achievements_tab.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final userProfile = appProvider.userProfile;
        
        // If no profile, return empty
        if (userProfile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: const FrostedAppBar(
            title: 'SETTINGS',
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 16),
                // User Header Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnderwaterTheme.deepNavy1.withOpacity(0.8),
                        UnderwaterTheme.deepNavy2.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: UnderwaterTheme.glowCyan(opacity: 0.2, blur: 16),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main Content
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: UnderwaterTheme.cardPurpleMid,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(
                                color: UnderwaterTheme.surfaceCyan1,
                                width: 2,
                              ),
                              boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: userProfile.avatarPath != null && userProfile.avatarPath!.isNotEmpty
                                ? Image.file(
                                    File(userProfile.avatarPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          userProfile.name.isNotEmpty
                                              ? userProfile.name[0].toUpperCase()
                                              : 'A',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            color: UnderwaterTheme.textLight,
                                            shadows: UnderwaterTheme.textShadowLight,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      userProfile.name.isNotEmpty
                                          ? userProfile.name[0].toUpperCase()
                                          : 'A',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: UnderwaterTheme.textLight,
                                        shadows: UnderwaterTheme.textShadowLight,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: UnderwaterTheme.textLight,
                                    shadows: UnderwaterTheme.textShadowLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Experience Badge - Positioned Top Right
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                UnderwaterTheme.surfaceCyan1,
                                UnderwaterTheme.surfaceCyan2,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: UnderwaterTheme.glowCyan(opacity: 0.4, blur: 8),
                          ),
                          child: Text(
                            userProfile.experienceLevel.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: UnderwaterTheme.deepNavy2,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Settings Section with Frosted Background
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: ClipRRect(
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                              child: Text(
                                'SETTINGS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: UnderwaterTheme.textCyan.withOpacity(0.9),
                                  letterSpacing: 1.2,
                                  shadows: UnderwaterTheme.textShadowLight,
                                ),
                              ),
                            ),
                            _buildMenuItem(
                              context,
                              icon: Icons.emoji_events,
                              title: 'Achievements',
                              subtitle: 'View your trophies and unlock rewards',
                              hasNotification: appProvider.hasNewAchievements,
                              notificationText: 'NEW',
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AchievementsTab(),
                                  ),
                                );
                                // Mark achievements as viewed when returning
                                await appProvider.markAchievementsAsViewed();
                              },
                            ),
                            
                            _buildMenuItem(
                              context,
                              icon: Icons.settings_outlined,
                              title: 'Preferences',
                              subtitle: 'Units, haptics, and app settings',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PreferencesScreen(),
                                  ),
                                );
                              },
                            ),
                            
                            _buildMenuItem(
                              context,
                              icon: Icons.person_outline,
                              title: 'Edit Profile',
                              subtitle: 'Update your name, location, and preferences',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            
                            _buildMenuItem(
                              context,
                              icon: Icons.account_circle_outlined,
                              title: 'View Profile',
                              subtitle: 'See your fishing profile',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileSettingsScreen(),
                                  ),
                                );
                              },
                            ),
                            
                            _buildMenuItem(
                              context,
                              icon: Icons.storage_outlined,
                              title: 'Data Management',
                              subtitle: 'Export, import, and manage your data',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DataSettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Legal & Information Section with Frosted Background
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: ClipRRect(
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                              child: Text(
                                'LEGAL & INFORMATION',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: UnderwaterTheme.textCyan.withOpacity(0.9),
                                  letterSpacing: 1.2,
                                  shadows: UnderwaterTheme.textShadowLight,
                                ),
                              ),
                            ),
                            
                            _buildMenuItem(
                              context,
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'How we handle your data',
                              onTap: () {
                                _openWebView(context, 'Privacy Policy', 'https://bigbasscatcher.app/privacy-policy/');
                              },
                            ),
                            
                            _buildMenuItem(
                              context,
                              icon: Icons.description_outlined,
                              title: 'Terms & Conditions',
                              subtitle: 'Terms of service',
                              onTap: () {
                                _openWebView(context, 'Terms & Conditions', 'https://bigbasscatcher.app/terms/');
                              },
                            ),
                            
                            _buildMenuItem(
                              context,
                              icon: Icons.info_outline,
                              title: 'About',
                              subtitle: 'App version and information',
                              onTap: () {
                                _showAboutDialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool hasNotification = false,
    String notificationText = 'NEW',
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UnderwaterTheme.deepNavy1.withOpacity(0.7),
            UnderwaterTheme.deepNavy2.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: UnderwaterTheme.glowCyan(opacity: 0.1, blur: 12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            UnderwaterTheme.surfaceCyan1.withOpacity(0.2),
                            UnderwaterTheme.surfaceCyan2.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: UnderwaterTheme.surfaceCyan1,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: UnderwaterTheme.surfaceCyan1,
                        size: 24,
                      ),
                    ),
                    if (hasNotification)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notificationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: UnderwaterTheme.textLight,
                          shadows: UnderwaterTheme.textShadowLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: UnderwaterTheme.textCyan,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: UnderwaterTheme.surfaceCyan1.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
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
              Image.asset(
                'assets/logo/app_bbc_character_3.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: UnderwaterTheme.textCyan,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Build 100',
                style: TextStyle(
                  fontSize: 14,
                  color: UnderwaterTheme.textCyan,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '© 2025 Big Bass Catcher',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: UnderwaterTheme.textCyan.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnderwaterTheme.surfaceCyan1,
                    foregroundColor: UnderwaterTheme.deepNavy2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ).copyWith(
                    shadowColor: WidgetStateProperty.all(UnderwaterTheme.surfaceCyan1.withOpacity(0.5)),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openWebView(BuildContext context, String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WebViewScreen(title: title, url: url),
      ),
    );
  }

}

// WebView Screen for Privacy Policy and Terms
class _WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const _WebViewScreen({required this.title, required this.url});

  @override
  State<_WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<_WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.colorBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading page: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: UnderwaterTheme.deepNavy1,
      appBar: FrostedAppBar(
        title: widget.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: UnderwaterTheme.surfaceCyan1),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      UnderwaterTheme.deepNavy1.withOpacity(0.95),
                      UnderwaterTheme.deepNavy2.withOpacity(0.95),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                UnderwaterTheme.deepNavy1.withOpacity(0.7),
                                UnderwaterTheme.deepNavy2.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 20),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: UnderwaterTheme.surfaceCyan1,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  color: UnderwaterTheme.textLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  shadows: UnderwaterTheme.textShadowLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}