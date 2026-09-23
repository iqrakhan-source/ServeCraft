import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/utilities/validators.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../data/models/address_model.dart';
import '../providers/address_provider.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? existingAddress;

  const AddAddressScreen({
    super.key,
    this.existingAddress,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedLabelType;
  late final TextEditingController _customLabelController;
  late final TextEditingController _houseNumberController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;
  late bool _isDefault;

  bool get isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAddress;

    final defaultLabels = ['Home', 'Work'];
    if (existing != null) {
      if (defaultLabels.contains(existing.label)) {
        _selectedLabelType = existing.label;
        _customLabelController = TextEditingController();
      } else {
        _selectedLabelType = 'Other';
        _customLabelController = TextEditingController(text: existing.label);
      }
      _houseNumberController =
          TextEditingController(text: existing.houseNumber);
      _addressLineController =
          TextEditingController(text: existing.addressLine);
      _landmarkController =
          TextEditingController(text: existing.landmark ?? '');
      _cityController = TextEditingController(text: existing.city);
      _stateController = TextEditingController(text: existing.state);
      _pincodeController = TextEditingController(text: existing.pincode);
      _isDefault = existing.isDefault;
    } else {
      _selectedLabelType = 'Home';
      _customLabelController = TextEditingController();
      _houseNumberController = TextEditingController();
      _addressLineController = TextEditingController();
      _landmarkController = TextEditingController();
      _cityController = TextEditingController(text: 'Jaipur');
      _stateController = TextEditingController(text: 'Rajasthan');
      _pincodeController = TextEditingController();
      _isDefault = false;
    }
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    _houseNumberController.dispose();
    _addressLineController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  String _getEffectiveLabel() {
    if (_selectedLabelType == 'Other') {
      final custom = _customLabelController.text.trim();
      return custom.isNotEmpty ? custom : 'Other';
    }
    return _selectedLabelType;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final addressProvider = context.read<AddressProvider>();
    final effectiveLabel = _getEffectiveLabel();

    final address = AddressModel(
      id: isEditing ? widget.existingAddress!.id : '',
      userId: isEditing ? widget.existingAddress!.userId : 'usr_current',
      label: effectiveLabel,
      houseNumber: _houseNumberController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      landmark: _landmarkController.text.trim().isNotEmpty
          ? _landmarkController.text.trim()
          : null,
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      latitude: widget.existingAddress?.latitude,
      longitude: widget.existingAddress?.longitude,
      isDefault: _isDefault,
    );

    final success = isEditing
        ? await addressProvider.updateAddress(address)
        : await addressProvider.createAddress(address);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Address updated successfully'
                : 'Address saved successfully',
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(address);
    } else if (mounted && addressProvider.actionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(addressProvider.actionError!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Address' : 'Add New Address',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Label Selector Header
              Text(
                'Save address as',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['Home', 'Work', 'Other'].map((type) {
                  final isSelected = _selectedLabelType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedLabelType = type;
                          });
                        }
                      },
                      selectedColor: AppColors.primaryLight,
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_selectedLabelType == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customLabelController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Label (e.g. Parents, Gym)',
                    hintText: 'Enter label name',
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // House / Flat Number
              TextFormField(
                controller: _houseNumberController,
                validator: (val) =>
                    AppValidators.validateRequired(val, 'House / Flat number'),
                decoration: const InputDecoration(
                  labelText: 'House / Flat / Block No. *',
                  hintText: 'e.g. Flat 402, Block B',
                ),
              ),
              const SizedBox(height: 16),

              // Address Line
              TextFormField(
                controller: _addressLineController,
                validator: (val) =>
                    AppValidators.validateRequired(val, 'Address line'),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Apartment / Road / Locality *',
                  hintText: 'e.g. Royal Palms, Queens Road, Vaishali Nagar',
                ),
              ),
              const SizedBox(height: 16),

              // Landmark
              TextFormField(
                controller: _landmarkController,
                decoration: const InputDecoration(
                  labelText: 'Landmark (Optional)',
                  hintText: 'e.g. Near Vaishali Circle',
                ),
              ),
              const SizedBox(height: 16),

              // City and State in 2-column row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      validator: (val) =>
                          AppValidators.validateRequired(val, 'City'),
                      decoration: const InputDecoration(
                        labelText: 'City *',
                        hintText: 'e.g. Jaipur',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      validator: (val) =>
                          AppValidators.validateRequired(val, 'State'),
                      decoration: const InputDecoration(
                        labelText: 'State *',
                        hintText: 'e.g. Rajasthan',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pincode
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: AppValidators.validatePincode,
                decoration: const InputDecoration(
                  labelText: 'PIN Code *',
                  hintText: 'e.g. 302021',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),

              // Set as default checkbox
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                activeTrackColor: AppColors.primary,
                title: Text(
                  'Set as default address',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'This address will be automatically selected for your bookings.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _isDefault = val;
                  });
                },
              ),
              const SizedBox(height: 28),

              // Save CTA Button
              AppButton(
                text: isEditing ? 'Save Changes' : 'Save Address',
                isLoading: addressProvider.isActionLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
