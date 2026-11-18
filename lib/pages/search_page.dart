import 'package:appmob_resepku/models/recipes.dart';
import 'package:appmob_resepku/services/recipe_service.dart';
import 'package:appmob_resepku/widgets/error_view.dart';
import 'package:appmob_resepku/widgets/recipe_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<List<Recipe>>? _searchFuture;
  String _lastQuery = '';

  void _search(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;
    _lastQuery = normalizedQuery;
    setState(() {
      _searchFuture = context.read<RecipeService>().searchRecipes(
        normalizedQuery,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari resep',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
      ),
      body: _searchFuture == null
          ? const Center(
              child: Text('Masukkan kata kunci untuk mencari resep.'),
            )
          : FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal mencari resep.\n${snapshot.error}',
                    onRetry: () => _search(_lastQuery),
                  );
                }

                final recipes = snapshot.data ?? const <Recipe>[];
                if (recipes.isEmpty) {
                  return const Center(
                    child: Text('Resep tidak ditemukan. Coba kata kunci lain.'),
                  );
                }
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) =>
                      RecipeTile(recipe: recipes[index]),
                );
              },
            ),
    );
  }
}
