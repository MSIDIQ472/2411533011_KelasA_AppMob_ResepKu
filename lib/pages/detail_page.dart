import 'package:flutter/material.dart';
import 'package:appmob_resepku/models/recipes.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favorites, _) {
              final isFavorite = favorites.isFavorite(recipe);
              return IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambah ke favorit',
                onPressed: () => favorites.toggle(recipe),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe.image,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: Center(child: Icon(Icons.restaurant, size: 64)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              recipe.cuisine,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${recipe.difficulty} • ${recipe.totalTimeMinutes} menit • '
              '${recipe.caloriesPerServing} kkal/porsi',
            ),
            const SizedBox(height: 16),
            Text(
              'Jumlah porsi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Kurangi porsi',
                  onPressed: _servings > 1
                      ? () => setState(() => _servings--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_servings porsi'),
                IconButton(
                  tooltip: 'Tambah porsi',
                  onPressed: () => setState(() => _servings++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${recipe.caloriesPerServing * _servings} kkal total',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Bahan-bahan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final ingredient in recipe.ingredients)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.circle, size: 8),
                title: Text(ingredient),
              ),
          ],
        ),
      ),
    );
  }
}
