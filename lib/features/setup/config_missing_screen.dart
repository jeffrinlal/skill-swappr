import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Shown when Supabase keys haven't been added yet.
class ConfigMissingScreen extends StatelessWidget {
  const ConfigMissingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_suggest_rounded,
                    color: AppColors.warning, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Almost there!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add your Supabase keys to connect the app.'


                  'Open: lib/core/config/supabase_config.dart'


                  'and paste your Project URL and anon key.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
