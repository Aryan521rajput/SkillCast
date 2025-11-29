// lib/features/auth/presentation/screens/profile_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/auth_event.dart';
import '../../../../bloc/auth_state.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String uid;
  const ProfileScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;

        if (user == null) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text(
              "My Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage:
                            user.photoUrl != null && user.photoUrl!.isNotEmpty
                                ? AssetImage(user.photoUrl!) as ImageProvider
                                : const AssetImage("assets/avatars/a1.jpg"),
                      ),
                      const SizedBox(width: 16),

                      // TEXT AREA
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              user.role,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF5B7FFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            // BIO
                            if (user.bio != null && user.bio!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  user.bio!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // EDIT PROFILE BUTTON
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: const Color(0xFF5B7FFF),
                  borderRadius: BorderRadius.circular(14),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ProfileEditScreen(user: user),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // LOGOUT
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(14),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    // dispatch logout — AuthBloc will clear auth state
                    context.read<AuthBloc>().add(const AuthLogoutRequested());

                    // ensure immediate navigation away from tab UI
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
