import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../utils/underwater_theme.dart';
import '../screens/dashboard_tab.dart';
import '../providers/app_provider.dart';
import '../widgets/achievement_unlock_dialog.dart';
import 'catch_tab.dart';
import 'log_tab.dart';
import 'fishpedia_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.add_circle, label: 'Catch'),
    _NavItem(icon: Icons.book, label: 'Log'),
    _NavItem(icon: Icons.waves, label: 'Wiki'),
  ];

  List<Widget> get _tabs => [
    DashboardTab(onViewAllCatches: () {
      setState(() {
        _currentIndex = 2; // Navigate to Log tab
      });
    }),
    const CatchTab(),
    const LogTab(),
    const FishpediaTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Check for newly unlocked achievements after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewAchievements();
    });
  }

  void _checkForNewAchievements() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final newAchievements = appProvider.newlyUnlockedAchievements;
    
    if (newAchievements.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AchievementUnlockDialog(
          achievements: newAchievements,
          onDismiss: () {
            appProvider.clearNewlyUnlockedAchievements();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Check for new achievements whenever the provider updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkForNewAchievements();
        });
        
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          extendBody: true,
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(37.5),
              image: const DecorationImage(
                image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(37.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: UnderwaterTheme.frostGlassDeep(opacity: 0.35, borderOpacity: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      _navItems.length,
                      (index) => _buildNavItem(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: InkWell(
          onTap: () {
            setState(() => _currentIndex = index);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isSelected 
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  size: isSelected ? 28 : 25,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: 0.5,
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

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
