import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditCompanyProfilePage extends StatefulWidget {
  final CompanyModel company;

  const EditCompanyProfilePage({super.key, required this.company});

  @override
  State<EditCompanyProfilePage> createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _aboutController;
  bool _isLoading = false;
  String? _imageBase64;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company.name);
    _phoneController = TextEditingController(text: widget.company.phoneNumber);
    _addressController = TextEditingController(text: widget.company.address);
    _aboutController = TextEditingController(text: widget.company.about);
    _imageBase64 =
        widget.company.imageUrl; // Assumindo que imageUrl já está em base64
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _showImageOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.darkGray,
                  ),
                ),
                title: Text(
                  'Galeria',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.darkGray,
                  ),
                ),
                title: Text(
                  'Câmera',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imageBase64 != null || _imageFile != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.delete,
                      color: AppColors.darkGray,
                    ),
                  ),
                  title: Text(
                    'Remover',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageBase64 = null;
                      _imageFile = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      // Converter para base64
      final bytes = await _imageFile!.readAsBytes();
      final base64String = base64Encode(bytes);
      _imageBase64 = 'data:image/jpeg;base64,$base64String';
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        'address': _addressController.text,
        'about': _aboutController.text,
        'imageUrl': _imageBase64,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar perfil')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppColors.lightPurple,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImageOptionsBottomSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_imageBase64 != null
                                  ? MemoryImage(base64Decode(
                                      _imageBase64!.split(',').last))
                                  : const AssetImage(
                                      'assets/images/img-company.png'))
                              as ImageProvider,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.lightPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Empresa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da empresa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o endereço';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(
                  labelText: 'Sobre a Empresa',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição sobre a empresa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text(
                          'Salvar Alterações',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
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
