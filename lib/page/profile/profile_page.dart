import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/profile/profile_bloc.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  File? _pickedImage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && !_initialized) {
          _nameController.text = state.customer.name ?? '';
          _emailController.text = state.customer.email ?? '';
          _initialized = true;
        } else if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error['message']?.toString() ?? 'Gagal'), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading && !_initialized) return const Center(child: CircularProgressIndicator());
        String? avatarUrl;
        if (state is ProfileLoaded && state.customer.image != null && state.customer.image!.isNotEmpty) {
          avatarUrl = state.customer.image!.startsWith('http') ? state.customer.image : '${AppConfig.STORAGE_AVATAR}${state.customer.image}';
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : (avatarUrl != null ? NetworkImage(avatarUrl) as ImageProvider : null),
                    child: (_pickedImage == null && avatarUrl == null) ? const Icon(Icons.camera_alt, size: 32, color: Colors.orange) : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 14),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 14),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password Baru (Opsional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 14),
              TextField(controller: _confirmController, obscureText: true, decoration: InputDecoration(labelText: 'Konfirmasi Password Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 22),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  context.read<ProfileBloc>().add(UpdateProfile(
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    image: _pickedImage,
                    password: _passwordController.text,
                    passwordConfirmation: _confirmController.text,
                  ));
                },
                child: const Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
