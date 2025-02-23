import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/user_dto.dart';
import '../widgets/app_drawer.dart';
import 'auth_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/verification_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  final profileService = ProfileService();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final genderController = TextEditingController();
  final birthDateController = TextEditingController();

  String? chefStatus;
  DateTime? birthDate;
  String userFirstName = '';
  String userLastName = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  final Map<String, bool> _fieldErrors = {
    'firstName': false,
    'lastName': false,
  };

  void _updateFieldError(String field, bool isInvalid) {
    setState(() {
      _fieldErrors[field] = isInvalid;
    });
  }

  bool get _isInvalidData {
    return _fieldErrors['firstName']! && _fieldErrors['lastName']!;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    cityController.dispose();
    countryController.dispose();
    genderController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await profileService.getUserProfile();
      setState(() {
        firstNameController.text = user?.firstName ?? '';
        lastNameController.text = user?.lastName ?? '';
        phoneController.text = user?.phone ?? '';
        addressController.text = user?.address ?? '';
        bioController.text = user?.bio ?? '';
        cityController.text = user?.city ?? '';
        countryController.text = user?.country ?? '';
        genderController.text = user?.gender ?? '';
        birthDateController.text = user?.birthDate ?? '';
        chefStatus = ['Новичок', 'Средний', 'Опытный'].contains(user?.chefStatus) ? user?.chefStatus : 'Новичок';
        userFirstName = user?.firstName ?? '';
        userLastName = user?.lastName ?? '';
      });
    } catch (e) {
      VerificationDialog.showVerificationDialog(
        context,
        'Ошибка загрузки профиля: $e',
        isInfo: false,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
        birthDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isInvalidData) return;
      final user = await profileService.getUserProfile();
      if (user == null) throw Exception('Пользователь не авторизован');

      final updatedUser = UserDto(
        id: user.id,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        address: addressController.text,
        bio: bioController.text,
        city: cityController.text,
        country: countryController.text,
        gender: genderController.text,
        birthDate: birthDateController.text,
        chefStatus: chefStatus ?? 'Новичок',
        favoriteRecipes: user.favoriteRecipes,
      );

      await profileService.updateUserProfile(updatedUser);

      setState(() {
        userFirstName = firstNameController.text;
        userLastName = lastNameController.text;
      });

      VerificationDialog.showVerificationDialog(
        context,
        'Профиль успешно обновлён!',
        isInfo: true,
      );
    } catch (e) {
      VerificationDialog.showVerificationDialog(
        context,
        'Ошибка при сохранении профиля: $e',
        isInfo: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await authService.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (Route<dynamic> route) => false,
                );
              } catch (e) {
                VerificationDialog.showVerificationDialog(
                  context,
                  'Ошибка при выходе: $e',
                  isInfo: false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '${userFirstName} ${userLastName}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: firstNameController,
                label: 'Имя',
                enableValidation: true,
                onValidationChanged: (isValid) => _updateFieldError('firstName', !isValid),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: lastNameController,
                label: 'Фамилия',
                enableValidation: true,
                onValidationChanged: (isValid) => _updateFieldError('lastName', !isValid),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: phoneController,
                label: 'Телефон',
                onValidationChanged: (isValid) {},
                pattern: r'^\+?[0-9]{10,15}$',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: addressController,
                label: 'Адрес',
                onValidationChanged: (isValid) {},
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: bioController,
                label: 'О себе',
                onValidationChanged: (isValid) {},
                pattern: r'^.{0,100}$',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: cityController,
                label: 'Город',
                onValidationChanged: (isValid) {},
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: countryController,
                label: 'Страна',
                onValidationChanged: (isValid) {},
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: genderController,
                label: 'Пол',
                onValidationChanged: (isValid) {},
              ),
              const SizedBox(height: 16),
              TextField(
                controller: birthDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Дата рождения',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: chefStatus,
                decoration: const InputDecoration(labelText: 'Статус шефа', border: OutlineInputBorder()),
                items: ['Новичок', 'Средний', 'Опытный'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                onChanged: (value) => setState(() => chefStatus = value),
              ),
              const SizedBox(height: 16),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: !_isInvalidData ? null : _saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isInvalidData ? Colors.grey : Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Сохранить изменения',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
}
