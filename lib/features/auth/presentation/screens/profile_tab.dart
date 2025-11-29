import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/auth_event.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Profile")),
      child: Center(
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          onPressed: () {
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
