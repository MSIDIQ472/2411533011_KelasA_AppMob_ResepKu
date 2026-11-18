import 'package:flutter/material.dart';
import 'package:appmob_resepku/models/recipes.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:appmob_resepku/services/recipe_service.dart';
import 'package:appmob_resepku/widgets/recipe_image.dart';
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

  Future<void> _renameRecipe() async {
    var updatedName = widget.recipe.name;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah nama resep'),
        content: TextFormField(
          initialValue: updatedName,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama resep'),
          onChanged: (value) => updatedName = value,
          onFieldSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = updatedName.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (name == null || !mounted) return;

    final service = context.read<RecipeService>();
    try {
      final updated = await service.updateRecipe(
        id: widget.recipe.id,
        name: name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama resep diperbarui menjadi "${updated.name}"'),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengubah resep: $error')));
    }
  }

  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus resep?'),
        content: Text('Resep "${widget.recipe.name}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final service = context.read<RecipeService>();
    try {
      final result = await service.deleteRecipe(widget.recipe.id);
      if (!mounted) return;
      if (result['isDeleted'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${widget.recipe.name}" berhasil dihapus.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server tidak menghapus resep.')),
        );
      }
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus resep: $error')));
    }
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
          PopupMenuButton<String>(
            tooltip: 'Aksi resep',
            onSelected: (action) {
              if (action == 'rename') {
                _renameRecipe();
              } else {
                _deleteRecipe();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Ubah nama')),
              PopupMenuItem(value: 'delete', child: Text('Hapus resep')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: RecipeImage(url: recipe.image),
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
            if (recipe.instructions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Langkah', style: Theme.of(context).textTheme.titleLarge),
              for (final (index, step) in recipe.instructions.indexed)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(step),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
