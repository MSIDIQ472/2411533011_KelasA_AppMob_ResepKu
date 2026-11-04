import 'package:flutter/foundation.dart';
import 'package:appmob_resepku/models/recipes.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Recipe> _items = [];

  List<Recipe> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool isFavorite(Recipe recipe) => _items.any((item) => item.id == recipe.id);

  void toggle(Recipe recipe) {
    if (isFavorite(recipe)) {
      _items.removeWhere((item) => item.id == recipe.id);
    } else {
      _items.add(recipe);
    }
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
