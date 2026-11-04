import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appmob_resepku/main.dart';
import 'package:appmob_resepku/providers/favorite_provider.dart';
import 'package:appmob_resepku/providers/theme_provider.dart';
import 'package:provider/provider.dart';

Widget _createApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const ResepKuApp(),
  );
}

void main() {
  testWidgets('shows recipes and updates serving count on the detail page', (
    tester,
  ) async {
    await tester.pumpWidget(_createApp());

    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    await tester.tap(find.text('Classic Margherita Pizza'));
    await tester.pumpAndSettle();

    expect(find.text('4 porsi'), findsOneWidget);
    expect(find.text('1200 kkal total'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah porsi'));
    await tester.pump();
    await tester.tap(find.byTooltip('Tambah porsi'));
    await tester.pump();

    expect(find.text('6 porsi'), findsOneWidget);
    expect(find.text('1800 kkal total'), findsOneWidget);
  });

  testWidgets('favorite state updates list and badge', (tester) async {
    await tester.pumpWidget(_createApp());

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
    await tester.pumpWidget(_createApp());

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
    await tester.tap(find.text('Hapus semua'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada resep favorit'), findsOneWidget);
  });

  testWidgets('clear favorites is disabled when the list is empty', (
    tester,
  ) async {
    await tester.pumpWidget(_createApp());

    await tester.tap(find.byTooltip('Favorit (0)'));
    await tester.pumpAndSettle();

    final clearButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.tooltip == 'Hapus semua favorit',
      ),
    );
    expect(clearButton.onPressed, isNull);
  });

  testWidgets('settings switch changes the application theme', (tester) async {
    await tester.pumpWidget(_createApp());

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
}
