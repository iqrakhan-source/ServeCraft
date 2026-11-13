import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/aesthetic_preferences_request.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _skinToneController;
  late TextEditingController _hairToneController;
  late TextEditingController _allergiesController;

  String _selectedGender = 'female';
  DateTime? _selectedDobDate;
  File? _selectedImageFile;
  bool _isUploadingPhoto = false;

  final List<String> _genders = ['female', 'male', 'other'];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _skinToneController = TextEditingController();
    _hairToneController = TextEditingController();
    _allergiesController = TextEditingController();

    if (user?.gender != null && user!.gender!.isNotEmpty) {
      final g = user.gender!.toLowerCase();
      if (_genders.contains(g)) {
        _selectedGender = g;
      }
    }

    if (user?.dateOfBirth != null && user!.dateOfBirth!.isNotEmpty) {
      final trimmed = user.dateOfBirth!.trim();
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        _selectedDobDate = parsed;
      } else {
        try {
          _selectedDobDate = DateFormat('dd/MM/yyyy').parseStrict(trimmed);
        } catch (_) {
          try {
            _selectedDobDate = DateFormat('dd-MM-yyyy').parseStrict(trimmed);
          } catch (_) {}
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _skinToneController.dispose();
    _hairToneController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initial = _selectedDobDate ?? DateTime(1998, 5, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1920),
      lastDate: now,
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
        _selectedDobDate = picked;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
        _isUploadingPhoto = true;
      });

      final authProvider = context.read<AuthProvider>();
      final photoUrl = await authProvider.uploadProfilePhoto(
        kIsWeb ? picked.path : File(picked.path),
      );

      if (!mounted) return;
      setState(() {
        _isUploadingPhoto = false;
      });

      if (photoUrl != null && photoUrl.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name must be at least 2 characters'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must be exactly 10 digits'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final dobString = _selectedDobDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDobDate!)
        : null;

    final success = await authProvider.completeProfile(
      name: name,
      phone: phone,
      email: email.isNotEmpty ? email : null,
      gender: _selectedGender,
      dateOfBirth: dobString,
    );

    // Save aesthetic preferences if entered
    final skinTone = _skinToneController.text.trim();
    final hairTone = _hairToneController.text.trim();
    final allergiesText = _allergiesController.text.trim();
    if (skinTone.isNotEmpty ||
        hairTone.isNotEmpty ||
        allergiesText.isNotEmpty) {
      final allergies = allergiesText.isNotEmpty
          ? allergiesText
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
          : <String>[];

      await authProvider.updateAestheticPreferences(
        AestheticPreferencesRequest(
          email: email.isNotEmpty ? email : null,
          skinTone: skinTone.isNotEmpty ? skinTone : null,
          hairTone: hairTone.isNotEmpty ? hairTone : null,
          allergies: allergies.isNotEmpty ? allergies : null,
        ),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to update profile',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String? _formatDisplayDob(String? dob) {
    if (dob == null || dob.trim().isEmpty) return null;
    final trimmed = dob.trim();
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return DateFormat('dd/MM/yyyy').format(parsed);
    }
    try {
      final parsedSlash = DateFormat('dd/MM/yyyy').parseStrict(trimmed);
      return DateFormat('dd/MM/yyyy').format(parsedSlash);
    } catch (_) {}
    try {
      final parsedDash = DateFormat('dd-MM-yyyy').parseStrict(trimmed);
      return DateFormat('dd/MM/yyyy').format(parsedDash);
    } catch (_) {}
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final dobDisplay = _selectedDobDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDobDate!)
        : (_formatDisplayDob(user?.dateOfBirth) ?? 'Select Date of Birth');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Edit Salon Profile',
        showBackButton: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: AppButton(text: 'Save Changes', onPressed: _handleSave),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with camera icon
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: _selectedImageFile != null && !kIsWeb
                        ? FileImage(_selectedImageFile!) as ImageProvider
                        : (user?.profileImage != null &&
                              user!.profileImage!.startsWith('http'))
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child:
                        (_selectedImageFile == null &&
                            (user?.profileImage == null ||
                                !user!.profileImage!.startsWith('http')))
                        ? (_isUploadingPhoto
                              ? const CircularProgressIndicator()
                              : Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : 'A',
                                  style: AppTypography.displayMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
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
            ),
            const SizedBox(height: 28),

            // Full Name Field
            AppTextField(
              controller: _nameController,
              label: 'Full Name *',
              hint: 'Ananya Sharma',
            ),
            const SizedBox(height: 16),

            // Email Field
            AppTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'ananya.new@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Phone Field
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number (10 digits) *',
              hint: '9876543210',
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 20),

            // Gender Selection
            Text(
              'Gender *',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _genders.map((gender) {
                final isSelected = _selectedGender == gender;
                return ChoiceChip(
                  label: Text(gender.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date of Birth
            Text(
              'Date of Birth (DD/MM/YYYY) *',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dobDisplay,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Aesthetic Preferences Card (Section 2.5)
            Text(
              'Stylist Consultation & Preferences',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Help your stylist personalize treatments to your skin and hair tone.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _skinToneController,
              label: 'Skin Tone (Optional)',
              hint: 'e.g. Fair, Wheatish, Dusky',
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _hairToneController,
              label: 'Hair Texture / Tone (Optional)',
              hint: 'e.g. Curly, Dry, Straight, Wavy',
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _allergiesController,
              label: 'Allergies (Optional, comma-separated)',
              hint: 'e.g. ammonia, bleach, parabens',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
