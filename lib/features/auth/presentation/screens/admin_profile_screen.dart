import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/auth_event.dart';
import '../../../../bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_edit_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  final String uid;
  const AdminProfileScreen({required this.uid, super.key});

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
            middle: Text("Admin Profile"),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
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
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: const AssetImage(
                          "assets/avatars/a1.jpg",
                        ),
                      ),
                      const SizedBox(width: 16),
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
                                fontSize: 15,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Admin",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                CupertinoButton(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(14),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
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

                const SizedBox(height: 12),

                CupertinoButton(
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(14),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
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
