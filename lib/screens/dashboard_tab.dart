import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../models/fish_species.dart';
import '../widgets/frosted_app_bar.dart';
import 'quest_history_screen.dart';
import 'settings_tab.dart';
import 'unlock_fish_screen.dart';

class DashboardTab extends StatefulWidget {
  final VoidCallback? onViewAllCatches;

  const DashboardTab({super.key, this.onViewAllCatches});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with TickerProviderStateMixin {
  Timer? _questTimer;

  // Slot machine animation controllers
  late AnimationController _reel1Controller;
  late AnimationController _reel2Controller;
  late AnimationController _reel3Controller;

  bool _isSpinning = false;
  List<String> _selectedFish = [];
  bool _showQuestContent = false; // Add flag to control quest visibility

  // All available fish images
  final List<String> _fishImages = [
    'assets/images/largemouth_bass.png',
    'assets/images/bluegill.png',
    'assets/images/catfish.png',
    'assets/images/crappie.png',
    'assets/images/walleye.png',
    'assets/images/yellow_perch.png',
    'assets/images/northern_pike.png',
    'assets/images/muskellunge.png',
    'assets/images/rainbow_trout.png',
    'assets/images/brook_trout.png',
    'assets/images/striped_mullet.png',
    'assets/images/redfish.png',
    'assets/images/snook.png',
    'assets/images/tarpon.png',
    'assets/images/flounder.png',
    'assets/images/sand_perch.png',
    'assets/images/tuna.png',
    'assets/images/marlin.png',
  ];

  @override
  void initState() {
    super.initState();
    _startQuestTimer();

    // Initialize with 3 random fish
    final shuffled = List<String>.from(_fishImages)..shuffle();
    _selectedFish = shuffled.take(3).toList();

    // Initialize slot machine reel controllers with staggered durations
    _reel1Controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _reel2Controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _reel3Controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // CRITICAL FIX: Show quest content if quest already exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (appProvider.currentQuest != null) {
        setState(() {
          _showQuestContent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _questTimer?.cancel();
    _reel1Controller.dispose();
    _reel2Controller.dispose();
    _reel3Controller.dispose();
    super.dispose();
  }

  Future<void> _spinSlotMachine() async {
    if (_isSpinning) return;

    // Haptic feedback on spin start
    HapticFeedback.mediumImpact();

    setState(() {
      _isSpinning = true;
      _showQuestContent = false; // Hide quest content during spin
    });

    // Shuffle and pick 3 random fish
    final shuffled = List<String>.from(_fishImages)..shuffle();
    _selectedFish = shuffled.take(3).toList();

    // Start all reels spinning
    _reel1Controller.reset();
    _reel2Controller.reset();
    _reel3Controller.reset();

    _reel1Controller.forward();
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 500));
    _reel2Controller.forward();
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 500));
    _reel3Controller.forward();
    HapticFeedback.lightImpact();

    // Wait for all reels to finish spinning
    // Reel 3 starts at 1000ms and has 3000ms duration = finishes at 4000ms
    // We've already waited 1000ms, so wait 3000ms more
    await Future.delayed(const Duration(milliseconds: 3000));

    // Haptic feedback on completion
    HapticFeedback.heavyImpact();

    // Wait a moment with all reels stopped before generating quest
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate quest from selected fish
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.spinForQuest();

    // Show quest content immediately with animation and re-enable button
    if (mounted) {
      setState(() {
        _showQuestContent = true;
        _isSpinning = false; // Now safe to allow spinning again
      });
    }
  }

  void _startQuestTimer() {
    _questTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: FrostedAppBar(
            title: 'FISHQUEST',
            actions: [
              // Bait Tokens Button
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: UnderwaterTheme.textLight.withOpacity(0.6),
                      width: 2,
                    ),
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
              // Settings button
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDashboardHeader(),
                  _buildQuestSection(),
                  _buildRecentCatches(),
                  _buildQuickAccessSection(),
                  const SizedBox(height: 100), // Bottom nav space
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardHeader() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final profile = appProvider.userProfile;
        if (profile == null) return const SizedBox();

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppTheme.radiusLarge),
            bottomRight: Radius.circular(AppTheme.radiusLarge),
          ),
          child: Container(
            width: double.infinity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.colorSecondary.withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: UnderwaterTheme.surfaceCyan1.withOpacity(
                                0.6,
                              ),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: UnderwaterTheme.surfaceCyan1.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              profile.avatarPath != null &&
                                  profile.avatarPath!.isNotEmpty
                              ? Image.file(
                                  File(profile.avatarPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        profile.userInitial,
                                        style: const TextStyle(
                                          color: AppTheme.colorTextPrimary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    profile.userInitial,
                                    style: const TextStyle(
                                      color: AppTheme.colorTextPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            UnderwaterTheme.midPeriwinkle.withOpacity(0.25),
                            UnderwaterTheme.midLavender.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: UnderwaterTheme.textLight.withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${profile.dailyStreak}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.local_fire_department,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'DAY STREAK',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${profile.weeklyStreak}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'WEEK STREAK',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestSection() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final quest = appProvider.currentQuest;

        if (quest == null) {
          return _buildPreSpinState(appProvider);
        } else {
          // Wrap quest content with animated opacity for smooth fade-in
          return AnimatedOpacity(
            opacity: _showQuestContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            child: AnimatedSlide(
              offset: _showQuestContent ? Offset.zero : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              child: _buildActiveQuestState(appProvider, quest),
            ),
          );
        }
      },
    );
  }

  Widget _buildPreSpinState(AppProvider appProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UnderwaterTheme.upperAqua1.withOpacity(0.25),
                  UnderwaterTheme.upperAqua2.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: UnderwaterTheme.textLight.withOpacity(0.35),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'READY FOR TODAY\'S CHALLENGE?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Spin the reel to discover your three target fish species',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Slot Machine
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        UnderwaterTheme.deepNavy1.withOpacity(0.5),
                        UnderwaterTheme.deepNavy2.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: UnderwaterTheme.deepPurplePink1.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: UnderwaterTheme.glowPurple(
                      opacity: 0.15,
                      blur: 16,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      final totalSpacing = spacing * 2;
                      final reelWidth =
                          ((constraints.maxWidth - totalSpacing) / 3).clamp(
                            60.0,
                            90.0,
                          );
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnimatedSlotReel(
                            _reel1Controller,
                            0,
                            reelWidth,
                          ),
                          const SizedBox(width: spacing),
                          _buildAnimatedSlotReel(
                            _reel2Controller,
                            1,
                            reelWidth,
                          ),
                          const SizedBox(width: spacing),
                          _buildAnimatedSlotReel(
                            _reel3Controller,
                            2,
                            reelWidth,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_isSpinning || appProvider.userProfile!.baitTokens < 1)
                        ? null
                        : _spinSlotMachine,
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: UnderwaterTheme.surfaceCyan1,
                          foregroundColor: UnderwaterTheme.deepNavy2,
                          disabledBackgroundColor: UnderwaterTheme.deepNavy2
                              .withOpacity(0.3),
                          disabledForegroundColor: UnderwaterTheme.textLight
                              .withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          elevation: 0,
                          shadowColor: UnderwaterTheme.surfaceCyan1.withOpacity(
                            0.5,
                          ),
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(
                            UnderwaterTheme.surfaceCyan2.withOpacity(0.3),
                          ),
                        ),
                    child: Text(
                      _isSpinning
                          ? 'SPINNING...'
                          : appProvider.userProfile!.baitTokens < 1
                          ? 'NEED 1 TOKEN'
                          : 'SPIN TO CAST (1 Token)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.token, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${appProvider.userProfile?.baitTokens ?? 0} Bait Tokens',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSlotReel(
    AnimationController controller,
    int reelIndex,
    double reelWidth,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final isSpinning = controller.isAnimating;
        final spinValue = controller.value;
        final reelHeight = reelWidth * (68 / 90);

        // Create a cycling effect through all fish
        final cycleCount = (spinValue * _fishImages.length * 3).floor();
        final currentFishIndex = cycleCount % _fishImages.length;

        return Container(
          width: reelWidth,
          height: reelHeight,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          ),
          clipBehavior: Clip.hardEdge,
          child: ClipRect(
            child: Stack(
              children: [
                // Show cycling fish while spinning
                if (isSpinning)
                  OverflowBox(
                    maxHeight: reelHeight * 2,
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        -reelHeight * (spinValue * _fishImages.length * 3 % 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFishImage(
                            _fishImages[currentFishIndex],
                            reelWidth,
                            reelHeight,
                          ),
                          _buildFishImage(
                            _fishImages[(currentFishIndex + 1) %
                                _fishImages.length],
                            reelWidth,
                            reelHeight,
                          ),
                        ],
                      ),
                    ),
                  )
                // Show selected fish (either from previous spin or initial random)
                else if (_selectedFish.isNotEmpty &&
                    reelIndex < _selectedFish.length)
                  _buildFishImage(
                    _selectedFish[reelIndex],
                    reelWidth,
                    reelHeight,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFishImage(String imagePath, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(width * (8 / 90)),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.set_meal,
                size: 30,
                color: AppTheme.colorPrimary,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQuestState(AppProvider appProvider, quest) {
    final progress = (quest.progress / quest.total * 100).toInt();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UnderwaterTheme.midLavender.withOpacity(0.3),
            UnderwaterTheme.deepPurplePink1.withOpacity(0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: UnderwaterTheme.textLight.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: UnderwaterTheme.glowPurple(opacity: 0.2, blur: 20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TODAY\'S QUEST',
                style: TextStyle(
                  color: UnderwaterTheme.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  shadows: UnderwaterTheme.textShadowLight,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: UnderwaterTheme.surfaceCyan1,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeRemaining(),
                    style: const TextStyle(
                      color: UnderwaterTheme.surfaceCyan1,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: UnderwaterTheme.textShadowLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS',
                style: TextStyle(
                  color: UnderwaterTheme.textLight.withOpacity(0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${quest.progress}/${quest.total}',
                style: const TextStyle(
                  color: UnderwaterTheme.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  shadows: UnderwaterTheme.textShadowLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: UnderwaterTheme.deepNavy2.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      UnderwaterTheme.surfaceCyan1,
                      UnderwaterTheme.surfaceCyan2,
                    ],
                  ),
                  boxShadow: UnderwaterTheme.glowCyan(opacity: 0.4, blur: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...quest.targetFish.map(
            (fish) => _buildTargetFishCard(fish, quest.isFishCaught(fish.id)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleReshuffle(appProvider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UnderwaterTheme.textLight,
                    side: BorderSide(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.7),
                      width: 2,
                    ),
                    backgroundColor: UnderwaterTheme.deepNavy1.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'DELETE QUEST',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                width: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuestHistoryScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.7),
                      width: 2,
                    ),
                    backgroundColor: UnderwaterTheme.deepNavy1.withOpacity(0.5),
                    foregroundColor: UnderwaterTheme.textLight,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(
                    Icons.history,
                    size: 20,
                    color: UnderwaterTheme.surfaceCyan1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetFishCard(FishSpecies fish, bool isCaught) {
    return GestureDetector(
      onTap: () => _showFishDetails(fish),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCaught
                ? [
                    UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                    UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                  ]
                : [
                    UnderwaterTheme.deepNavy1.withOpacity(0.6),
                    UnderwaterTheme.deepNavy2.withOpacity(0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isCaught
                ? UnderwaterTheme.surfaceCyan1
                : UnderwaterTheme.deepPurplePink1.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: isCaught
              ? UnderwaterTheme.glowCyan(opacity: 0.3, blur: 12)
              : UnderwaterTheme.glowPurple(opacity: 0.2, blur: 8),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UnderwaterTheme.deepNavy2.withOpacity(0.8),
                    UnderwaterTheme.cardPurpleMid.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Image.asset(
                fish.imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.waves,
                    size: 32,
                    color: AppTheme.colorSecondary,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: UnderwaterTheme.textLight,
                      shadows: UnderwaterTheme.textShadowLight,
                    ),
                  ),
                  Text(
                    fish.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: UnderwaterTheme.textCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          UnderwaterTheme.surfaceCyan1,
                          UnderwaterTheme.surfaceCyan2,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: UnderwaterTheme.glowCyan(
                        opacity: 0.3,
                        blur: 6,
                      ),
                    ),
                    child: Text(
                      fish.rarity.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: UnderwaterTheme.deepNavy2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isCaught)
              const Icon(
                Icons.check_circle,
                color: UnderwaterTheme.surfaceCyan1,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }

  void _showFishDetails(FishSpecies fish) {
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
              colors: [UnderwaterTheme.deepNavy1, UnderwaterTheme.deepNavy2],
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
              // Title Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                      UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fish.name,
                        style: const TextStyle(
                          color: UnderwaterTheme.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: UnderwaterTheme.textShadowLight,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: UnderwaterTheme.textLight,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fish Image
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                UnderwaterTheme.deepNavy2.withOpacity(0.9),
                                UnderwaterTheme.cardPurpleMid.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Image.asset(
                            fish.imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.waves,
                                size: 64,
                                color: UnderwaterTheme.surfaceCyan1,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Scientific Name
                            const Text(
                              'SCIENTIFIC NAME',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: UnderwaterTheme.textCyan,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fish.scientificName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: UnderwaterTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Type & Rarity
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'TYPE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: UnderwaterTheme.textCyan,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        fish.type.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: UnderwaterTheme.surfaceCyan1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'RARITY',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: UnderwaterTheme.textCyan,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              UnderwaterTheme.surfaceCyan1,
                                              UnderwaterTheme.surfaceCyan2,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          boxShadow: UnderwaterTheme.glowCyan(
                                            opacity: 0.3,
                                            blur: 6,
                                          ),
                                        ),
                                        child: Text(
                                          fish.rarity.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: UnderwaterTheme.deepNavy2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Description
                            const Text(
                              'DESCRIPTION',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: UnderwaterTheme.textCyan,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fish.description,
                              style: const TextStyle(
                                color: UnderwaterTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Habitat
                            const Text(
                              'HABITAT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: UnderwaterTheme.textCyan,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fish.habitat,
                              style: const TextStyle(
                                color: UnderwaterTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Best Baits
                            const Text(
                              'BEST BAITS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: UnderwaterTheme.textCyan,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: fish.bestBaits.map((bait) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        UnderwaterTheme.midPeriwinkle
                                            .withOpacity(0.5),
                                        UnderwaterTheme.midLavender.withOpacity(
                                          0.4,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: UnderwaterTheme.surfaceCyan1
                                          .withOpacity(0.6),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    bait,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: UnderwaterTheme.textLight,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Depth & Season
                            Row(
                              children: [
                                const Icon(
                                  Icons.water,
                                  size: 16,
                                  color: UnderwaterTheme.surfaceCyan1,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Depth: ${fish.depthRange}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: UnderwaterTheme.textLight,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: UnderwaterTheme.surfaceCyan1,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    fish.season,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: UnderwaterTheme.textLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Difficulty
                            Row(
                              children: [
                                const Text(
                                  'Difficulty: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: UnderwaterTheme.textLight,
                                  ),
                                ),
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < fish.difficultyRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: UnderwaterTheme.surfaceCyan1,
                                  );
                                }),
                              ],
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

  Future<void> _handleReshuffle(AppProvider appProvider) async {
    final confirm = await showDialog<bool>(
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
              colors: [UnderwaterTheme.deepNavy1, UnderwaterTheme.deepNavy2],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: UnderwaterTheme.deepPurplePink1.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: UnderwaterTheme.glowPurple(opacity: 0.3, blur: 20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                size: 48,
                color: UnderwaterTheme.deepPurplePink1,
              ),
              const SizedBox(height: 16),
              const Text(
                'DELETE QUEST?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: UnderwaterTheme.textLight,
                  shadows: UnderwaterTheme.textShadowLight,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This will remove your current quest and return you to the spin machine.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: UnderwaterTheme.textCyan),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        foregroundColor: UnderwaterTheme.textCyan,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          side: BorderSide(
                            color: UnderwaterTheme.surfaceCyan1.withOpacity(
                              0.4,
                            ),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: UnderwaterTheme.deepPurplePink1,
                            foregroundColor: UnderwaterTheme.textLight,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                          ).copyWith(
                            shadowColor: WidgetStateProperty.all(
                              UnderwaterTheme.deepPurplePink1.withOpacity(0.5),
                            ),
                          ),
                      child: const Text(
                        'DELETE',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await appProvider.deleteCurrentQuest();
    }
  }

  Widget _buildRecentCatches() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final catches = appProvider.catches.take(3).toList();
        final prefs = appProvider.preferences;

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT CATCHES',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: UnderwaterTheme.textLight,
                      shadows: UnderwaterTheme.textShadowLight,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onViewAllCatches,
                    style: TextButton.styleFrom(
                      foregroundColor: UnderwaterTheme.surfaceCyan1,
                    ),
                    child: const Text('VIEW ALL'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (catches.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnderwaterTheme.deepNavy1.withOpacity(0.6),
                        UnderwaterTheme.deepNavy2.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: UnderwaterTheme.glowCyan(opacity: 0.1, blur: 8),
                  ),
                  child: const Center(
                    child: Text(
                      'No catches yet. Spin the reel and start fishing!',
                      style: TextStyle(
                        color: UnderwaterTheme.textCyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...catches.map((catch_) {
                  final weightStr = catch_.weight != null
                      ? prefs.formatWeight(catch_.weight!)
                      : '';
                  final lengthStr = catch_.length != null
                      ? prefs.formatLength(catch_.length!)
                      : '';
                  final statsStr = [
                    weightStr,
                    lengthStr,
                  ].where((s) => s.isNotEmpty).join(' • ');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UnderwaterTheme.midLavender.withOpacity(0.4),
                          UnderwaterTheme.deepPurplePink1.withOpacity(0.35),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      border: Border.all(
                        color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: UnderwaterTheme.glowPurple(
                        opacity: 0.15,
                        blur: 12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                UnderwaterTheme.deepNavy1.withOpacity(0.5),
                                UnderwaterTheme.deepNavy2.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                            border: Border.all(
                              color: UnderwaterTheme.surfaceCyan1.withOpacity(
                                0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child:
                              catch_.photoPath != null &&
                                  catch_.photoPath!.isNotEmpty
                              ? Image.file(
                                  File(catch_.photoPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/empty.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/empty.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                catch_.fishName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: UnderwaterTheme.textLight,
                                  shadows: UnderwaterTheme.textShadowLight,
                                ),
                              ),
                              if (statsStr.isNotEmpty)
                                Text(
                                  statsStr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: UnderwaterTheme.textCyan,
                                  ),
                                ),
                              Text(
                                DateFormat('MMM d, y').format(catch_.caughtAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: UnderwaterTheme.textCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessSection() {
    return const SizedBox.shrink();
  }
}
