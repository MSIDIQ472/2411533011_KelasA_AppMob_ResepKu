import 'package:flutter/material.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:appmob_resepku/widgets/recipe_tile.dart';
import 'package:provider/provider.dart';

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
    return Consumer<FavoriteProvider>(
      builder: (context, favorites, _) {
        final isEmpty = favorites.items.isEmpty;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorit'),
            actions: [
              TextButton.icon(
                onPressed: favorites.count == 0
                    ? null
                    : () => _confirmClear(context),
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Hapus semua'),
              ),
            ],
          ),
          body: isEmpty
              ? const Center(child: Text('Belum ada resep favorit'))
              : ListView.builder(
                  itemCount: favorites.items.length,
                  itemBuilder: (context, index) =>
                      RecipeTile(recipe: favorites.items[index]),
                ),
        );
      },
    );
  }
}
