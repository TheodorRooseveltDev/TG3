import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../providers/app_provider.dart';
import '../models/fish_species.dart';
import '../models/catch_entry.dart';
import '../widgets/frosted_app_bar.dart';
import 'settings_tab.dart';
import '../services/fish_database.dart';
import 'unlock_fish_screen.dart';

class CatchTab extends StatefulWidget {
  const CatchTab({super.key});

  @override
  State<CatchTab> createState() => _CatchTabState();
}

class _CatchTabState extends State<CatchTab> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _notesController = TextEditingController();

  XFile? _imageFile;
  FishSpecies? _selectedFish;
  String _selectedMethod = 'Casting';

  final List<String> _fishingMethods = [
    'Casting',
    'Trolling',
    'Fly Fishing',
    'Jigging',
    'Bottom Fishing',
    'Spinning',
    'Baitcasting',
    'Ice Fishing',
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.lightImpact();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
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
          'Select Image Source',
          style: TextStyle(
            color: UnderwaterTheme.textLight,
            shadows: UnderwaterTheme.textShadowLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: UnderwaterTheme.surfaceCyan1,
              ),
              title: const Text(
                'Camera',
                style: TextStyle(color: UnderwaterTheme.textLight),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: UnderwaterTheme.surfaceCyan1,
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(color: UnderwaterTheme.textLight),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFishSelectionDialog() {
    final allFish = FishDatabase.allFish;

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
            children: [
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
                child: const Row(
                  children: [
                    Icon(Icons.search, color: UnderwaterTheme.textLight),
                    SizedBox(width: 8),
                    Text(
                      'Select Fish Species',
                      style: TextStyle(
                        color: UnderwaterTheme.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: UnderwaterTheme.textShadowLight,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allFish.length,
                  itemBuilder: (context, index) {
                    final fish = allFish[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              UnderwaterTheme.deepNavy2.withOpacity(0.8),
                              UnderwaterTheme.cardPurpleMid.withOpacity(0.7),
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
                        child: Image.asset(
                          fish.imageAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.phishing,
                              color: UnderwaterTheme.surfaceCyan1,
                            );
                          },
                        ),
                      ),
                      title: Text(
                        fish.name,
                        style: const TextStyle(
                          color: UnderwaterTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${fish.scientificName} • ${fish.rarity.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: UnderwaterTheme.textCyan,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.map, size: 20),
                            onPressed: () {
                              Navigator.pop(context);
                              _showFishMapDialog(fish);
                            },
                            color: UnderwaterTheme.surfaceCyan1,
                            tooltip: 'View on map',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            _selectedFish?.id == fish.id
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: _selectedFish?.id == fish.id
                                ? UnderwaterTheme.surfaceCyan1
                                : UnderwaterTheme.textCyan,
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _selectedFish = fish;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFishMapDialog(FishSpecies fish) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700, maxWidth: 600),
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            UnderwaterTheme.deepNavy2.withOpacity(0.8),
                            UnderwaterTheme.cardPurpleMid.withOpacity(0.7),
                          ],
                        ),
                        border: Border.all(
                          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Image.asset(
                        fish.imageAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.phishing,
                            color: UnderwaterTheme.surfaceCyan1,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fish.name,
                            style: const TextStyle(
                              color: UnderwaterTheme.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: UnderwaterTheme.textShadowLight,
                            ),
                          ),
                          Text(
                            fish.scientificName,
                            style: TextStyle(
                              color: UnderwaterTheme.textCyan.withOpacity(0.9),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
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
              // Scrollable Content with Map
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fish Info Summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                UnderwaterTheme.midLavender.withOpacity(0.3),
                                UnderwaterTheme.deepPurplePink1.withOpacity(
                                  0.25,
                                ),
                              ],
                            ),
                            border: Border.all(
                              color: UnderwaterTheme.surfaceCyan1.withOpacity(
                                0.5,
                              ),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                            boxShadow: UnderwaterTheme.glowCyan(
                              opacity: 0.15,
                              blur: 12,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'TYPE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: UnderwaterTheme.textCyan,
                                      ),
                                    ),
                                    Text(
                                      fish.type.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: UnderwaterTheme.surfaceCyan1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'RARITY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: UnderwaterTheme.textCyan,
                                      ),
                                    ),
                                    Container(
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
                                          fontWeight: FontWeight.bold,
                                          color: UnderwaterTheme.deepNavy2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'DIFFICULTY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: UnderwaterTheme.textCyan,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < fish.difficultyRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 12,
                                          color: UnderwaterTheme.surfaceCyan1,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Select Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedFish = fish;
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text(
                              'SELECT THIS FISH',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            style:
                                ElevatedButton.styleFrom(
                                  backgroundColor: UnderwaterTheme.surfaceCyan1,
                                  foregroundColor: UnderwaterTheme.deepNavy2,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium,
                                    ),
                                  ),
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.all(
                                    UnderwaterTheme.surfaceCyan2.withOpacity(
                                      0.3,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFish == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fish species')),
      );
      return;
    }

    // Parse weight and length and convert to metric for storage
    final provider = Provider.of<AppProvider>(context, listen: false);
    final useMetric = provider.preferences.useMetric;

    final weightInput = double.tryParse(_weightController.text);
    final lengthInput = double.tryParse(_lengthController.text);

    if (weightInput == null || lengthInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid weight and length')),
      );
      return;
    }

    // Convert to metric if user entered imperial units (for consistent storage)
    final weight = useMetric
        ? weightInput
        : weightInput / 2.20462; // Convert lbs to kg if needed
    final length = useMetric
        ? lengthInput
        : lengthInput * 2.54; // Convert inches to cm if needed

    // Create catch entry
    final catchEntry = CatchEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fishSpeciesId: _selectedFish!.id,
      fishName: _selectedFish!.name,
      photoPath: _imageFile?.path,
      weight: weight,
      length: length,
      caughtAt: DateTime.now(),
      fishingMethod: _selectedMethod,
      notes: _notesController.text,
    );

    // Add to provider (reuse provider variable from above)
    await provider.addCatch(catchEntry);

    // Haptic feedback on success
    HapticFeedback.heavyImpact();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catch logged successfully! 🎣'),
          backgroundColor: AppTheme.colorSuccess,
        ),
      );

      // Clear form
      setState(() {
        _imageFile = null;
        _selectedFish = null;
        _selectedMethod = 'Casting';
        _weightController.clear();
        _lengthController.clear();
        _notesController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: FrostedAppBar(
            title: 'REGISTER CATCH',
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
                    border: Border.all(
                      color: UnderwaterTheme.textLight.withOpacity(0.6),
                      width: 2,
                    ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          UnderwaterTheme.deepNavy1.withOpacity(0.7),
                          UnderwaterTheme.deepNavy2.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: UnderwaterTheme.glowCyan(
                        opacity: 0.15,
                        blur: 16,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Photo Upload Section
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              width: double.infinity,
                              height: 250,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    UnderwaterTheme.deepNavy1.withOpacity(0.4),
                                    UnderwaterTheme.deepNavy2.withOpacity(0.5),
                                  ],
                                ),
                                border: Border.all(
                                  color: UnderwaterTheme.surfaceCyan1
                                      .withOpacity(0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                                boxShadow: UnderwaterTheme.glowCyan(
                                  opacity: 0.15,
                                  blur: 12,
                                ),
                              ),
                              child: _imageFile != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          File(_imageFile!.path),
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.black54,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _imageFile = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 64,
                                          color: UnderwaterTheme.surfaceCyan1,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to add photo',
                                          style: TextStyle(
                                            color: UnderwaterTheme.textLight,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            shadows:
                                                UnderwaterTheme.textShadowLight,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '(Optional)',
                                          style: TextStyle(
                                            color: UnderwaterTheme.textCyan,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Fish Species Selection
                          const Text(
                            'FISH SPECIES *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: UnderwaterTheme.textLight,
                              shadows: UnderwaterTheme.textShadowLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showFishSelectionDialog,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    UnderwaterTheme.deepNavy1.withOpacity(0.5),
                                    UnderwaterTheme.deepNavy2.withOpacity(0.6),
                                  ],
                                ),
                                border: Border.all(
                                  color: UnderwaterTheme.surfaceCyan1
                                      .withOpacity(0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                                boxShadow: UnderwaterTheme.glowCyan(
                                  opacity: 0.1,
                                  blur: 8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phishing,
                                    color: _selectedFish != null
                                        ? UnderwaterTheme.surfaceCyan1
                                        : UnderwaterTheme.textCyan,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedFish?.name ??
                                          'Select fish species',
                                      style: TextStyle(
                                        color: _selectedFish != null
                                            ? UnderwaterTheme.textLight
                                            : UnderwaterTheme.textCyan,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: UnderwaterTheme.surfaceCyan1,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Weight and Length Row
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<AppProvider>(
                                  builder: (context, appProvider, child) {
                                    final useMetric =
                                        appProvider.preferences.useMetric;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          useMetric
                                              ? 'WEIGHT (KG) *'
                                              : 'WEIGHT (LBS) *',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: UnderwaterTheme.textLight,
                                            shadows:
                                                UnderwaterTheme.textShadowLight,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _weightController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*'),
                                            ),
                                          ],
                                          decoration: const InputDecoration(
                                            hintText: '0.0',
                                            prefixIcon: Icon(Icons.scale),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Invalid';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Consumer<AppProvider>(
                                  builder: (context, appProvider, child) {
                                    final useMetric =
                                        appProvider.preferences.useMetric;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          useMetric
                                              ? 'LENGTH (CM) *'
                                              : 'LENGTH (IN) *',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: UnderwaterTheme.textLight,
                                            shadows:
                                                UnderwaterTheme.textShadowLight,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _lengthController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*'),
                                            ),
                                          ],
                                          decoration: const InputDecoration(
                                            hintText: '0.0',
                                            prefixIcon: Icon(Icons.straighten),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Invalid';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Location Section
                          // Fishing Method
                          const Text(
                            'FISHING METHOD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: UnderwaterTheme.textLight,
                              shadows: UnderwaterTheme.textShadowLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedMethod,
                            style: const TextStyle(
                              color: UnderwaterTheme.textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            dropdownColor: UnderwaterTheme.deepNavy1,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phishing),
                            ),
                            items: _fishingMethods.map((method) {
                              return DropdownMenuItem(
                                value: method,
                                child: Text(
                                  method,
                                  style: const TextStyle(
                                    color: UnderwaterTheme.textLight,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedMethod = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          // Notes
                          const Text(
                            'NOTES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: UnderwaterTheme.textLight,
                              shadows: UnderwaterTheme.textShadowLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText:
                                  'Add any additional details about your catch...',
                              alignLabelWithHint: true,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submitCatch,
                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor:
                                        UnderwaterTheme.surfaceCyan1,
                                    foregroundColor: UnderwaterTheme.deepNavy2,
                                    elevation: 0,
                                    shadowColor: UnderwaterTheme.surfaceCyan1
                                        .withOpacity(0.5),
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.all(
                                      UnderwaterTheme.surfaceCyan2.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                              child: const Text(
                                'LOG CATCH',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // End of form container
                  const SizedBox(height: 100), // Margin at bottom
                ],
              ), // End of Column
            ),
          ),
        );
      },
    );
  }
}
