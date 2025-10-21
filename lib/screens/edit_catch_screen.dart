import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/catch_entry.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class EditCatchScreen extends StatefulWidget {
  final CatchEntry catchEntry;

  const EditCatchScreen({super.key, required this.catchEntry});

  @override
  State<EditCatchScreen> createState() => _EditCatchScreenState();
}

class _EditCatchScreenState extends State<EditCatchScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _lengthController;
  late TextEditingController _notesController;
  late String _selectedMethod;
  bool _isTrophyCatch = false;

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
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final useMetric = provider.preferences.useMetric;
    
    // Convert stored metric values to user's preferred units for display
    final displayWeight = widget.catchEntry.weight != null
        ? (useMetric ? widget.catchEntry.weight! : widget.catchEntry.weight! * 2.20462)
        : null;
    final displayLength = widget.catchEntry.length != null
        ? (useMetric ? widget.catchEntry.length! : widget.catchEntry.length! / 2.54)
        : null;
    
    _weightController = TextEditingController(
      text: displayWeight?.toStringAsFixed(2) ?? '',
    );
    _lengthController = TextEditingController(
      text: displayLength?.toStringAsFixed(2) ?? '',
    );
    _notesController = TextEditingController(
      text: widget.catchEntry.notes ?? '',
    );
    // Ensure the selected method is in the list, otherwise default to first item
    _selectedMethod = _fishingMethods.contains(widget.catchEntry.fishingMethod)
        ? widget.catchEntry.fishingMethod
        : _fishingMethods.first;
    _isTrophyCatch = widget.catchEntry.isTrophyCatch;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final useMetric = provider.preferences.useMetric;
      
      // Parse user input
      final inputWeight = double.tryParse(_weightController.text);
      final inputLength = double.tryParse(_lengthController.text);
      
      // Convert to metric for storage
      final weightKg = inputWeight != null
          ? (useMetric ? inputWeight : inputWeight / 2.20462)
          : null;
      final lengthCm = inputLength != null
          ? (useMetric ? inputLength : inputLength * 2.54)
          : null;
      
      final updatedCatch = widget.catchEntry.copyWith(
        weight: weightKg,
        length: lengthCm,
        fishingMethod: _selectedMethod,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isTrophyCatch: _isTrophyCatch,
      );

      await provider.updateCatch(updatedCatch);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate changes were saved
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catch updated successfully'),
            backgroundColor: AppTheme.colorSecondary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT CATCH'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChanges,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.colorBorder, width: 2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.catchEntry.photoPath != null && widget.catchEntry.photoPath!.isNotEmpty
                    ? Image.file(
                        File(widget.catchEntry.photoPath!),
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
              const SizedBox(height: 16),

              // Fish Name (Read-only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.colorSurface,
                  border: Border.all(color: AppTheme.colorBorder, width: 2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FISH SPECIES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colorTextMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.catchEntry.fishName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weight Input
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  final useMetric = appProvider.preferences.useMetric;
                  return TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: useMetric ? 'Weight (kg)' : 'Weight (lbs)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: AppTheme.colorSurface,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter weight';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Length Input
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  final useMetric = appProvider.preferences.useMetric;
                  return TextFormField(
                    controller: _lengthController,
                    decoration: InputDecoration(
                      labelText: useMetric ? 'Length (cm)' : 'Length (inches)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: AppTheme.colorSurface,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter length';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Fishing Method Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
                decoration: InputDecoration(
                  labelText: 'Fishing Method',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.colorSurface,
                ),
                items: _fishingMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Trophy Toggle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.colorSurface,
                  border: Border.all(color: AppTheme.colorBorder, width: 2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: SwitchListTile(
                  title: const Text('Mark as Trophy Catch'),
                  subtitle: const Text('This catch deserves special recognition'),
                  value: _isTrophyCatch,
                  onChanged: (value) {
                    setState(() {
                      _isTrophyCatch = value;
                    });
                  },
                  activeThumbColor: AppTheme.colorAccent,
                ),
              ),
              const SizedBox(height: 16),

              // Notes TextArea
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional details...',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.colorSurface,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('SAVE CHANGES'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colorSecondary,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),

              // Cancel Button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('CANCEL'),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
