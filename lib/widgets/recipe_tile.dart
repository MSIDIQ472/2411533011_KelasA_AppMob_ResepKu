import 'package:flutter/material.dart';
import 'package:appmob_resepku/models/recipes.dart';
import 'package:appmob_resepku/pages/detail_page.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:appmob_resepku/widgets/recipe_image.dart';
import 'package:provider/provider.dart';

class RecipeTile extends StatelessWidget {
  const RecipeTile({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favorites, _) => ListTile(
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
          '${recipe.cuisine} • ${recipe.totalTimeMinutes} menit • '
          '★ ${recipe.rating}',
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => DetailPage(recipe: recipe)),
        ),
        trailing: IconButton(
          tooltip: favorites.isFavorite(recipe)
              ? 'Hapus dari favorit'
              : 'Tambah ke favorit',
          icon: Icon(
            favorites.isFavorite(recipe)
                ? Icons.favorite
                : Icons.favorite_border,
            color: favorites.isFavorite(recipe) ? Colors.red : null,
          ),
          onPressed: () => favorites.toggle(recipe),
        ),
      ),
    );
  }
}
