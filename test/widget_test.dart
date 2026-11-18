import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appmob_resepku/main.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:appmob_resepku/providers/theme_provider.dart';
import 'package:appmob_resepku/services/recipe_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

final List<Map<String, Object>> _recipes = [
  {
    'id': 1,
    'name': 'Classic Margherita Pizza',
    'cuisine': 'Italian',
    'difficulty': 'Easy',
    'prepTimeMinutes': 20,
    'cookTimeMinutes': 15,
    'servings': 4,
    'caloriesPerServing': 300,
    'rating': 4.6,
    'image': '',
    'ingredients': ['Pizza dough', 'Tomato sauce'],
    'instructions': ['Prepare dough', 'Bake pizza'],
  },
  {
    'id': 2,
    'name': 'Vegetarian Stir-Fry',
    'cuisine': 'Asian',
    'difficulty': 'Medium',
    'prepTimeMinutes': 15,
    'cookTimeMinutes': 20,
    'servings': 3,
    'caloriesPerServing': 250,
    'rating': 4.7,
    'image': '',
    'ingredients': ['Tofu', 'Broccoli'],
    'instructions': ['Chop vegetables', 'Stir-fry'],
  },
];

Future<http.Response> _mockResponse(http.Request request) async {
  if (request.method == 'GET' && request.url.path.endsWith('/recipes/search')) {
    final query = request.url.queryParameters['q']?.toLowerCase() ?? '';
    final matches = _recipes
        .where(
          (recipe) => (recipe['name']! as String).toLowerCase().contains(query),
        )
        .toList();
    return http.Response(jsonEncode({'recipes': matches}), 200);
  }
  if (request.method == 'GET') {
    return http.Response(jsonEncode({'recipes': _recipes}), 200);
  }
  if (request.method == 'POST') {
    final requestBody = jsonDecode(request.body) as Map<String, dynamic>;
    return http.Response(
      jsonEncode({
        ...requestBody,
        'id': 101,
        'rating': 0,
        'ingredients': <String>[],
        'instructions': <String>[],
      }),
      201,
    );
  }
  if (request.method == 'PUT') {
    final requestBody = jsonDecode(request.body) as Map<String, dynamic>;
    return http.Response(jsonEncode({..._recipes.first, ...requestBody}), 200);
  }
  if (request.method == 'DELETE') {
    return http.Response(jsonEncode({'isDeleted': true, 'id': 1}), 200);
  }
  return http.Response('Not found', 404);
}

Widget _createApp({http.Client? client}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      Provider(
        create: (_) =>
            RecipeService(client: client ?? MockClient(_mockResponse)),
        dispose: (_, service) => service.close(),
      ),
    ],
    child: const ResepKuApp(),
  );
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(_createApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows recipes and updates serving count on the detail page', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    await tester.tap(find.text('Classic Margherita Pizza'));
    await tester.pumpAndSettle();

    expect(find.text('4 porsi'), findsOneWidget);
    expect(find.text('1200 kkal total'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Tambah porsi'));
    await tester.tap(find.byTooltip('Tambah porsi'));
    await tester.pump();
    await tester.ensureVisible(find.byTooltip('Tambah porsi'));
    await tester.tap(find.byTooltip('Tambah porsi'));
    await tester.pump();

    expect(find.text('6 porsi'), findsOneWidget);
    expect(find.text('1800 kkal total'), findsOneWidget);
    await tester.ensureVisible(find.text('Langkah'));
    expect(find.text('Prepare dough'), findsOneWidget);
  });

  testWidgets('favorite state updates list and badge', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Tambah ke favorit').first);
    await tester.pump();
    expect(find.byTooltip('Favorit (1)'), findsOneWidget);

    await tester.tap(find.byTooltip('Favorit (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus dari favorit').first);
    await tester.pump();
    expect(find.text('Belum ada resep favorit'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favorit (0)'), findsOneWidget);
  });

  testWidgets('clears favorites only after confirmation', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Tambah ke favorit').first);
    await tester.pump();
    await tester.tap(find.byTooltip('Favorit (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus semua favorit'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus semua favorit?'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus semua favorit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus semua').last);
    await tester.pumpAndSettle();
    expect(find.text('Belum ada resep favorit'), findsOneWidget);
  });

  testWidgets('clear favorites is disabled when the list is empty', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Favorit (0)'));
    await tester.pumpAndSettle();

    final clearButton = tester.widget<TextButton>(
      find.descendant(
        of: find.byTooltip('Hapus semua favorit'),
        matching: find.byType(TextButton),
      ),
    );
    expect(clearButton.onPressed, isNull);
  });

  testWidgets('settings switch changes the application theme', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Pengaturan'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Tema gelap'))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Tema gelap'))).brightness,
      Brightness.dark,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('ResepKu'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('switches between recipe list and grid', (tester) async {
    await _pumpApp(tester);

    final recipeList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
    );
    expect(recipeList, findsOneWidget);
    await tester.tap(find.byTooltip('Tampilan grid'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byTooltip('Tampilan list'), findsOneWidget);

    await tester.tap(find.byTooltip('Tampilan list'));
    await tester.pumpAndSettle();
    expect(recipeList, findsOneWidget);
  });

  testWidgets('filters recipes by cuisine and shows all again', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Asian'));
    await tester.pumpAndSettle();
    expect(find.text('Vegetarian Stir-Fry'), findsOneWidget);
    expect(find.text('Classic Margherita Pizza'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Semua'));
    await tester.pumpAndSettle();
    expect(find.text('Vegetarian Stir-Fry'), findsOneWidget);
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
  });

  testWidgets('shows an error and retries loading recipes', (tester) async {
    var requestCount = 0;
    final client = MockClient((_) async {
      requestCount++;
      if (requestCount == 1) return http.Response('Server error', 500);
      return http.Response(jsonEncode({'recipes': _recipes}), 200);
    });

    await tester.pumpWidget(_createApp(client: client));
    await tester.pumpAndSettle();
    expect(find.textContaining('Gagal memuat resep.'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    expect(requestCount, 2);
  });

  testWidgets('favorite state persists when switching between grid and list', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Tampilan grid'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tambah ke favorit').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus dari favorit').first, findsOneWidget);

    await tester.tap(find.byTooltip('Tampilan list'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus dari favorit').first, findsOneWidget);
  });

  testWidgets('adds a recipe through the POST form', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Tambah resep'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Wajib diisi'), findsNWidgets(2));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Rendang');
    await tester.enterText(fields.at(1), 'Indonesian');
    await tester.enterText(fields.at(2), '180');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Rendang'), findsOneWidget);
    expect(find.textContaining('id 101'), findsOneWidget);
  });

  testWidgets('searches recipes by query', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Cari resep'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'pizza');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    expect(find.text('Vegetarian Stir-Fry'), findsNothing);
  });

  testWidgets('updates and deletes a recipe from its detail page', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Classic Margherita Pizza'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Aksi resep'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ubah nama'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pizza Baru');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pizza Baru'), findsOneWidget);

    await tester.tap(find.byTooltip('Aksi resep'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus resep'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
  });
}
