// lib/features/auth/presentation/screens/settings_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillcast/bloc/auth_event.dart';
import '../../../../bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  final String privacyPolicyUrl;
  final String privacyChoicesUrl;

  const SettingsScreen({
    required this.privacyPolicyUrl,
    required this.privacyChoicesUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(CupertinoIcons.chevron_forward),
              onTap: () => _openUrl(context, privacyPolicyUrl),
            ),
            const SizedBox(height: 8),
            CupertinoListTile(
              title: const Text('Manage Privacy / Data'),
              trailing: const Icon(CupertinoIcons.chevron_forward),
              onTap: () => _openUrl(context, privacyChoicesUrl),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              child: const Text('Sign out'),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openUrl(BuildContext context, String url) {
    // Use url_launcher in UI (add dependency if not present)
    // For now show a dialog with the URL so you can copy it
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Open URL'),
        content: Text(url),
        actions: [
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
