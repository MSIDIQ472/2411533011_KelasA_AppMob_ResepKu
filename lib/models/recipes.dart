class Recipe {
  final int id;
  final String name;
  final String cuisine;
  final String difficulty;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final int caloriesPerServing;
  final double rating;
  final String image;
  final List<String> ingredients;
  final List<String> instructions;

  const Recipe({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.caloriesPerServing,
    required this.rating,
    required this.image,
    required this.ingredients,
    this.instructions = const [],
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'] as List? ?? const [];
    final rawInstructions = json['instructions'] as List? ?? const [];

    return Recipe(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'Tanpa nama',
      cuisine: json['cuisine'] as String? ?? '-',
      difficulty: json['difficulty'] as String? ?? '-',
      prepTimeMinutes: (json['prepTimeMinutes'] as num? ?? 0).toInt(),
      cookTimeMinutes: (json['cookTimeMinutes'] as num? ?? 0).toInt(),
      servings: (json['servings'] as num? ?? 1).toInt(),
      caloriesPerServing: (json['caloriesPerServing'] as num? ?? 0).toInt(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      image: json['image'] as String? ?? '',
      ingredients: List<String>.from(rawIngredients),
      instructions: List<String>.from(rawInstructions),
    );
  }
}
