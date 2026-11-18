import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:appmob_resepku/widgets/recipe_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua favorit?'),
        content: const Text('Semua resep favorit akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus semua'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<FavoriteProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteProvider>().items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        actions: [
          Tooltip(
            message: 'Hapus semua favorit',
            child: TextButton.icon(
              onPressed: favorites.isEmpty
                  ? null
                  : () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Hapus semua'),
            ),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('Belum ada resep favorit'))
          : ListView.separated(
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                return Dismissible(
                  key: ValueKey(recipe.id), // unik dan stabil, bukan index
                  direction: DismissDirection.endToStart, // geser ke kiri
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<FavoriteProvider>().toggle(recipe);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${recipe.name} dihapus dari favorit'),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: RecipeImage(url: recipe.image, cacheWidth: 168),
                      ),
                    ),
                    title: Text(recipe.name),
                    subtitle: Text(
                      '${recipe.cuisine} • ${recipe.totalTimeMinutes} menit • ★ ${recipe.rating}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Hapus dari favorit',
                      onPressed: () =>
                          context.read<FavoriteProvider>().toggle(recipe),
                      icon: const Icon(Icons.favorite, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
