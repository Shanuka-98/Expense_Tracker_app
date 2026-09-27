import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/viewmodels/settings_view_model.dart';
import '../../../../core/viewmodels/user_settings_view_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final userSettings = context.watch<UserSettingsViewModel>();
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isGuest = user?.isAnonymous ?? true;

        return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Account Section
          _buildSectionHeader(context, 'Account'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: !isGuest && user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: isGuest || user?.photoURL == null
                        ? Icon(Icons.person_outline_rounded, color: theme.colorScheme.onPrimaryContainer)
                        : null,
                  ),
                  title: Text(isGuest ? 'Guest User' : (user?.displayName ?? 'User')),
                  subtitle: Text(isGuest ? 'Not backed up' : (user?.email ?? '')),
                ),
                if (isGuest) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    title: const Text('Backup with Google'),
                    subtitle: const Text('Save your data securely'),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.cloud_upload_rounded, color: theme.colorScheme.onTertiaryContainer),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _linkGoogleAccount(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionHeader(context, 'Preferences'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle app appearance'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      settings.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    userSettings.setDarkMode(isDark);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  title: const Text('Currency'),
                  subtitle: Text(userSettings.currencySymbol),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.payments_rounded, color: theme.colorScheme.onTertiaryContainer),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showCurrencyDialog(context, userSettings),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  title: const Text('Monthly Budget Limit'),
                  subtitle: Text('${userSettings.currencySymbol} ${(userSettings.budgetLimitCents / 100).toStringAsFixed(0)}'),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.track_changes_rounded, color: theme.colorScheme.onSecondaryContainer),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showBudgetDialog(context, userSettings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Actions
          ElevatedButton.icon(
            onPressed: () => _confirmSignOut(context, isGuest),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              backgroundColor: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Future<void> _showCurrencyDialog(BuildContext context, UserSettingsViewModel settings) async {
    final currencies = ['LKR', 'USD', 'EUR', 'GBP', 'INR', 'AUD', 'CAD'];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text(currency),
                trailing: settings.currencySymbol == currency
                    ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  settings.setCurrencySymbol(currency);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context, UserSettingsViewModel settings) async {
    final controller = TextEditingController(text: (settings.budgetLimitCents ~/ 100).toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Budget Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Budget Limit',
            prefixText: '${settings.currencySymbol} ',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                settings.setBudgetLimit(val * 100);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, bool isGuest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGuest ? 'Delete Guest Account?' : 'Log Out?'),
        content: Text(
          isGuest
              ? 'WARNING: You are using a temporary Guest account. If you log out without backing up to a Google account, ALL your expenses and data will be permanently lost.'
              : 'Are you sure you want to log out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(isGuest ? 'Log Out & Delete Data' : 'Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await GoogleSignIn().signOut();
        
        final user = FirebaseAuth.instance.currentUser;
        if (isGuest && user != null) {
          // Delete the anonymous user completely so it doesn't linger in Firebase Auth
          await user.delete();
        } else {
          await FirebaseAuth.instance.signOut();
        }
      } finally {
        if (context.mounted) {
          // Pop all dialogs and SettingsView to return to the root route
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  Future<void> _linkGoogleAccount(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '83543355758-nukgb8dnd4kc7i9n9ftvu91k4l287gtg.apps.googleusercontent.com',
      );
      
      // Force the Google Account picker to show by signing out of any cached session first
      await googleSignIn.signOut();
      
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.linkWithCredential(credential);
            // Manually update the Firebase user profile with Google info
            if (googleUser.displayName != null) {
              await user.updateDisplayName(googleUser.displayName);
            }
            if (googleUser.photoUrl != null) {
              await user.updatePhotoURL(googleUser.photoUrl);
            }
            // Reload user to propagate changes to streams
            await user.reload();
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully linked Google account! Data is backed up.')),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' && context.mounted) {
            final switchAccount = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Account Already Exists'),
                content: const Text(
                  'This Google account is already registered to another user.\n\n'
                  'Would you like to log in to it instead? Any unbacked-up guest data will be lost.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            );

            if (switchAccount == true) {
              await FirebaseAuth.instance.signInWithCredential(credential);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged into existing account')),
                );
                // AuthGate handles UI state change automatically
              }
            }
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to link account: ${e.message}')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to link account: $e')),
        );
      }
    }
  }
}
