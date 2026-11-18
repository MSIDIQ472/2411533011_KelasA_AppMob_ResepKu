import 'dart:convert';

import 'package:appmob_resepku/models/recipes.dart';
import 'package:http/http.dart' as http;

class RecipeService {
  RecipeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://dummyjson.com';
  static const _timeout = Duration(seconds: 10);

  Future<List<Recipe>> fetchRecipes({int limit = 50}) async {
    final uri = Uri.parse('$_baseUrl/recipes')
        .replace(queryParameters: {'limit': '$limit'});
    final response = await _client.get(uri).timeout(_timeout);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final recipes = body['recipes'] as List<dynamic>;
    return recipes
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse('$_baseUrl/recipes/search')
        .replace(queryParameters: {'q': query});
    final response = await _client.get(uri).timeout(_timeout);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final recipes = body['recipes'] as List<dynamic>;
    return recipes
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Recipe> addRecipe({
    required String name,
    required String cuisine,
    required int cookTimeMinutes,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/recipes/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'cuisine': cuisine,
            'cookTimeMinutes': cookTimeMinutes,
          }),
        )
        .timeout(_timeout);
    _checkStatus(response);
    return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Recipe> updateRecipe({required int id, required String name}) async {
    final response = await _client
        .put(
          Uri.parse('$_baseUrl/recipes/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name}),
        )
        .timeout(_timeout);
    _checkStatus(response);
    return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> deleteRecipe(int id) async {
    final response = await _client
        .delete(Uri.parse('$_baseUrl/recipes/$id'))
        .timeout(_timeout);
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RecipeServiceException(
        'Server menjawab dengan status ${response.statusCode}',
      );
    }
  }

  void close() => _client.close();
}

class RecipeServiceException implements Exception {
  const RecipeServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
