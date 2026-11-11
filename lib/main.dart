import 'package:flutter/material.dart';
import 'package:appmob_resepku/pages/home_page.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:appmob_resepku/providers/theme_provider.dart';
import 'package:appmob_resepku/widgets/identity_footer.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ResepKuApp(),
    ),
  );
}

class ResepKuApp extends StatelessWidget {
  const ResepKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    return MaterialApp(
      title: 'ResepKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      themeMode: themeMode,
      builder: (context, child) =>
          IdentityFooter(child: child ?? const SizedBox.shrink()),
      home: const HomePage(),
    );
  }
}
