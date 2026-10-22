import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_strings.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/extensions.dart';
import 'package:prop_crm/core/utilities/validators.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_text_field.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String? _selectedAvatarUrl;
  File? _imageFile;
  String? _webImagePath;
  bool _isLoading = false;

  final Set<String> _selectedPreferences = {'Hair Styling', 'Spa & Massage'};

  final List<String> _genderOptions = [
    'Female',
    'Male',
    'Non-Binary',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _servicePreferences = [
    'Hair Styling',
    'Facial & Skin Care',
    'Manicure & Pedicure',
    'Spa & Massage',
    'Bridal & Grooming',
  ];

  static const List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final initialDate = _selectedDateOfBirth ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedAvatarUrl = null;
          if (kIsWeb) {
            _webImagePath = picked.path;
            _imageFile = null;
          } else {
            _imageFile = File(picked.path);
            _webImagePath = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Could not pick image: $e');
      }
    }
  }

  void _selectPresetAvatar(String url) {
    Navigator.of(context).pop();
    setState(() {
      _selectedAvatarUrl = url;
      _imageFile = null;
      _webImagePath = null;
    });
  }

  void _removePhoto() {
    Navigator.of(context).pop();
    setState(() {
      _selectedAvatarUrl = null;
      _imageFile = null;
      _webImagePath = null;
    });
  }

  void _showPhotoOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final hasPhoto = _imageFile != null ||
            _webImagePath != null ||
            _selectedAvatarUrl != null;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profile Photo',
                  style: AppTypography.titleLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how you want to add your profile picture (Optional)',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_camera_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text('Take Photo', style: AppTypography.titleSmall),
                  subtitle: Text('Capture with device camera',
                      style: AppTypography.bodySmall),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text('Choose from Gallery',
                      style: AppTypography.titleSmall),
                  subtitle: Text('Select from photo library',
                      style: AppTypography.bodySmall),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 8),
                Text(
                  'Or Choose an Avatar',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final url = _presetAvatars[index];
                      final isSelected = _selectedAvatarUrl == url;
                      return GestureDetector(
                        onTap: () => _selectPresetAvatar(url),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 3 : 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (hasPhoto) ...[
                  const Divider(height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 20),
                    ),
                    title: Text(
                      'Remove Current Photo',
                      style: AppTypography.titleSmall
                          .copyWith(color: AppColors.error),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onTap: _removePhoto,
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPreview() {
    Widget imageContent;

    if (_imageFile != null && !kIsWeb) {
      imageContent = Image.file(
        _imageFile!,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
      );
    } else if (_webImagePath != null) {
      imageContent = Image.network(
        _webImagePath!,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
      );
    } else if (_selectedAvatarUrl != null) {
      imageContent = Image.network(
        _selectedAvatarUrl!,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
      );
    } else {
      final nameText = _nameController.text.trim();
      imageContent = Center(
        child: Text(
          nameText.isNotEmpty ? nameText.initials : 'LX',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final hasPhoto = _imageFile != null ||
        _webImagePath != null ||
        _selectedAvatarUrl != null;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(child: imageContent),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptionsSheet,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showPhotoOptionsSheet,
            child: Text(
              hasPhoto ? 'Change Photo (Optional)' : 'Add Photo (Optional)',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCompleteProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // UI-only prototype: simulate short interaction and navigate to Home / MainNav
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.mainNav,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Profile Setup',
        showBackButton: false,
        showBottomBorder: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.completeProfileTitle,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.completeProfileSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // 1. Profile Photo
                _buildAvatarPreview(),
                const SizedBox(height: 28),

                // 2. Full Name Field (Required)
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name *',
                  hint: 'Enter your full name',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: AppValidators.validateName,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // 3. Mobile Number (Profile Field)
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: AppStrings.phoneHint,
                  prefixText: '+91',
                  prefixIcon: const Icon(
                    Icons.phone_iphone_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      return AppValidators.validatePhone(val);
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // 4. Gender Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender (Optional)',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedGender),
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        hintText: 'Select gender',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.wc_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        suffixIcon: _selectedGender != null
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: AppColors.textTertiary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedGender = null;
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.8,
                          ),
                        ),
                      ),
                      dropdownColor: AppColors.surface,
                      items: _genderOptions.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(
                            gender,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedGender = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. Date of Birth Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth (Optional)',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _selectDateOfBirth,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cake_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDateOfBirth != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_selectedDateOfBirth!)
                                    : 'Select date of birth',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: _selectedDateOfBirth != null
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                            if (_selectedDateOfBirth != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDateOfBirth = null;
                                    _dobController.clear();
                                  });
                                },
                                child: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: AppColors.textTertiary,
                                ),
                              )
                            else
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. Preferred Salon Services (Optional enhancement)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferred Salon Services (Optional)',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select services you are interested in for customized recommendations',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _servicePreferences.map((pref) {
                        final isSelected = _selectedPreferences.contains(pref);
                        return FilterChip(
                          label: Text(pref),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPreferences.add(pref);
                              } else {
                                _selectedPreferences.remove(pref);
                              }
                            });
                          },
                          selectedColor: AppColors.primaryLight,
                          backgroundColor: AppColors.surface,
                          checkmarkColor: AppColors.primary,
                          labelStyle: AppTypography.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Save & Continue Button
                AppButton(
                  text: 'Save & Continue',
                  isLoading: _isLoading,
                  onPressed: _handleCompleteProfile,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
