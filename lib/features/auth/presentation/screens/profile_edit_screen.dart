import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth_event.dart';
import '../../../../bloc/profile_bloc.dart';
import '../../../../bloc/profile_event.dart';
import '../../../../bloc/auth_bloc.dart';

import '../../../auth/data/models/app_user.dart';

class ProfileEditScreen extends StatefulWidget {
  final AppUser user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController roleController;
  late final TextEditingController bioController;

  String? selectedAvatar;

  // Local avatars stored under assets/avatars/
  final List<String> avatarList = List.generate(
    10,
    (i) => "assets/avatars/a${i + 1}.jpg",
  );

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    roleController = TextEditingController(text: widget.user.role);
    bioController = TextEditingController(text: widget.user.bio ?? "");

    selectedAvatar = widget.user.photoUrl;
  }

  // -------------------------------------------------------------------------
  // SAVE CHANGES
  // -------------------------------------------------------------------------
  void _saveChanges() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your name")));
      return;
    }

    final updatedData = {
      "name": nameController.text.trim(),
      "bio": bioController.text.trim(),
      "photoUrl": selectedAvatar,
    };

    context.read<ProfileBloc>().add(
      UpdateUserProfileRequested(widget.user.uid, updatedData),
    );

    // Refresh global auth user model
    context.read<AuthBloc>().add(AuthCheckRequested());

    // SUCCESS SNACKBAR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Changes saved successfully!")),
    );

    // ❗ DO NOT POP — user stays on Edit Profile
  }

  // -------------------------------------------------------------------------
  // AVATAR PICKER MODAL
  // -------------------------------------------------------------------------
  void _openAvatarPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Choose Avatar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: avatarList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                    itemBuilder: (context, i) {
                      final isSelected = selectedAvatar == avatarList[i];

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedAvatar = avatarList[i]);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF5B7FFF),
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(avatarList[i]),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),
                  CupertinoButton(
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // TEXT FIELD BUILDER
  // -------------------------------------------------------------------------
  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),

          TextField(
            controller: ctrl,
            readOnly: readOnly,
            maxLines: maxLines,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Edit Profile"),
          trailing: GestureDetector(
            onTap: _saveChanges,
            child: const Text(
              "Save",
              style: TextStyle(color: Color(0xFF5B7FFF), fontSize: 16),
            ),
          ),
        ),
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: selectedAvatar != null
                        ? AssetImage(selectedAvatar!)
                        : null,
                    child: selectedAvatar == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: _openAvatarPicker,
                    child: const Text(
                      "Select Avatar",
                      style: TextStyle(
                        color: Color(0xFF5B7FFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  if (selectedAvatar != null)
                    GestureDetector(
                      onTap: () => setState(() => selectedAvatar = null),
                      child: const Text(
                        "Remove Avatar",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  // -----------------------
                  // FORM FIELDS
                  // -----------------------
                  _buildField("Full Name", nameController),
                  _buildField("Email", emailController, readOnly: true),
                  _buildField("Role", roleController, readOnly: true),
                  _buildField("Bio", bioController, maxLines: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
