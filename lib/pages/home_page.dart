import 'package:flutter/material.dart';
import 'package:appmob_resepku/models/recipes.dart';
import 'package:appmob_resepku/pages/add_recipe_page.dart';
import 'package:appmob_resepku/pages/search_page.dart';
import 'package:appmob_resepku/pages/settings_page.dart';
import 'package:appmob_resepku/services/recipe_service.dart';
import 'package:appmob_resepku/widgets/error_view.dart';
import 'package:appmob_resepku/widgets/favorite_badge_button.dart';
import 'package:appmob_resepku/widgets/recipe_grid_card.dart';
import 'package:appmob_resepku/widgets/recipe_tile.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false;
  String? _cuisine;
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = context.read<RecipeService>().fetchRecipes();
  }

  void _reload() {
    setState(() {
      _recipesFuture = context.read<RecipeService>().fetchRecipes();
    });
  }

  Future<void> _refresh() async {
    _reload();
    try {
      await _recipesFuture;
    } on Object {
      // FutureBuilder displays the request error.
    }
  }

  Future<void> _openAddPage() async {
    final created = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute<Recipe>(builder: (_) => const AddRecipePage()),
    );
    if (created == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${created.name}" diterima server dengan id ${created.id}. '
          'dummyjson hanya menyimulasikan penyimpanan.',
        ),
      ),
    );
  }

  Future<void> _openSearchPage() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const SearchPage()),
    );
  }

  Widget _buildChips(List<Recipe> recipes) {
    final cuisines = recipes.map((recipe) => recipe.cuisine).toSet().toList();
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Semua'),
              selected: _cuisine == null,
              onSelected: (_) => setState(() => _cuisine = null),
            ),
          ),
          for (final cuisine in cuisines)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cuisine),
                selected: _cuisine == cuisine,
                onSelected: (_) => setState(() => _cuisine = cuisine),
              ),
            ),
        ],
      ),
    );
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) => _cuisine == null
      ? recipes
      : recipes.where((recipe) => recipe.cuisine == _cuisine).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32, width: 32),
            const SizedBox(width: 8),
            const Text('ResepKu'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : 'Tampilan grid',
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          IconButton(
            tooltip: 'Cari resep',
            icon: const Icon(Icons.search),
            onPressed: _openSearchPage,
          ),
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
      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Gagal memuat resep.\n${snapshot.error}',
              onRetry: _reload,
            );
          }

          final recipes = snapshot.data ?? const <Recipe>[];
          if (recipes.isEmpty) {
            return const Center(child: Text('Belum ada resep.'));
          }

          final filteredRecipes = _filterRecipes(recipes);
          return Column(
            children: [
              _buildChips(recipes),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: filteredRecipes.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text('Tidak ada resep untuk cuisine ini.'),
                            ),
                          ],
                        )
                      : _isGrid
                      ? _buildGrid(filteredRecipes)
                      : _buildList(filteredRecipes),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah resep',
        onPressed: _openAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeTile(recipe: recipes[index]),
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeGridCard(recipe: recipes[index]),
    );
  }
}
