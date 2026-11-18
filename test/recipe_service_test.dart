import 'dart:convert';

import 'package:appmob_resepku/models/recipes.dart';
import 'package:appmob_resepku/services/recipe_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'Recipe.fromJson accepts integer ratings and defaults optional fields',
    () {
      final recipe = Recipe.fromJson({'id': 5, 'name': 'Soup', 'rating': 5});

      expect(recipe.rating, 5.0);
      expect(recipe.cuisine, '-');
      expect(recipe.servings, 1);
      expect(recipe.instructions, isEmpty);
    },
  );

  test('fetchRecipes parses the recipes response from the API', () async {
    late Uri requestedUri;
    final service = RecipeService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          jsonEncode({
            'recipes': [
              {'id': 1, 'name': 'Soup', 'rating': 5},
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(service.close);

    final recipes = await service.fetchRecipes();

    expect(requestedUri.path, '/recipes');
    expect(requestedUri.queryParameters['limit'], '50');
    expect(recipes.single.name, 'Soup');
    expect(recipes.single.rating, 5.0);
  });

  test('fetchRecipes throws a service exception for non-success status', () {
    final service = RecipeService(
      client: MockClient((_) async => http.Response('Not found', 404)),
    );
    addTearDown(service.close);

    expect(service.fetchRecipes(), throwsA(isA<RecipeServiceException>()));
  });

  test('searchRecipes URL-encodes the query', () async {
    late Uri requestedUri;
    final service = RecipeService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(jsonEncode({'recipes': []}), 200);
      }),
    );
    addTearDown(service.close);

    await service.searchRecipes('chicken soup');

    expect(requestedUri.path, '/recipes/search');
    expect(requestedUri.queryParameters['q'], 'chicken soup');
  });

  test('add, update, and delete use their API methods and responses', () async {
    final requests = <http.Request>[];
    final service = RecipeService(
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'DELETE') {
          return http.Response(jsonEncode({'isDeleted': true}), 200);
        }
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 10,
            'name': body['name'],
            'cuisine': body['cuisine'] ?? 'Italian',
            'rating': 0,
          }),
          request.method == 'POST' ? 201 : 200,
        );
      }),
    );
    addTearDown(service.close);

    final added = await service.addRecipe(
      name: 'Rendang',
      cuisine: 'Indonesian',
      cookTimeMinutes: 180,
    );
    final updated = await service.updateRecipe(id: 10, name: 'Nasi Goreng');
    final deleted = await service.deleteRecipe(10);

    expect(added.id, 10);
    expect(updated.name, 'Nasi Goreng');
    expect(deleted['isDeleted'], isTrue);
    expect(requests.map((request) => request.method), [
      'POST',
      'PUT',
      'DELETE',
    ]);
    expect(requests[0].url.path, '/recipes/add');
    expect(requests[1].url.path, '/recipes/10');
    expect(requests[2].url.path, '/recipes/10');
  });
}
