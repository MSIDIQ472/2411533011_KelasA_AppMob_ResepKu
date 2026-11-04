import 'package:flutter/material.dart';
import 'package:appmob_resepku/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SwitchListTile(
        title: const Text('Tema gelap'),
        subtitle: const Text('Aktifkan tampilan gelap aplikasi'),
        secondary: Icon(theme.isDarkMode ? Icons.dark_mode : Icons.light_mode),
        value: theme.isDarkMode,
        onChanged: theme.toggleTheme,
      ),
    );
  }
}
