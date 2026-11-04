import 'package:flutter/material.dart';
import 'package:appmob_resepku/pages/favorite_page.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:provider/provider.dart';

class FavoriteBadgeButton extends StatelessWidget {
  const FavoriteBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favorites, _) => IconButton(
        tooltip: 'Favorit (${favorites.count})',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const FavoritePage()),
        ),
        icon: Badge(
          isLabelVisible: favorites.count > 0,
          label: Text('${favorites.count}'),
          child: const Icon(Icons.favorite),
        ),
      ),
    );
  }
}
