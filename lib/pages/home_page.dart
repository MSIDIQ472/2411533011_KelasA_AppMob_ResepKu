import 'package:flutter/material.dart';
import 'package:appmob_resepku/data/dummy_recipes.dart';
import 'package:appmob_resepku/pages/settings_page.dart';
import 'package:appmob_resepku/widgets/favorite_badge_button.dart';
import 'package:appmob_resepku/widgets/recipe_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResepKu'),
        actions: [
          const FavoriteBadgeButton(),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyRecipes.length,
        itemBuilder: (context, index) =>
            RecipeTile(recipe: dummyRecipes[index]),
      ),
    );
  }
}
