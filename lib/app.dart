import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/posts/presentation/cubit/post_detail_cubit.dart';
import 'features/posts/presentation/pages/posts_page.dart';

final class ReaderApp extends StatelessWidget {
  const ReaderApp({
    required this.createDetailCubit,
    this.useFixture = false,
    super.key,
  });

  final PostDetailCubit Function() createDetailCubit;
  final bool useFixture;

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(seedColor: const Color(0xFF136F63));
    return MaterialApp(
      title: 'Góc đọc',
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        scaffoldBackgroundColor: const Color(0xFFF6F7F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7F3),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDFE5DC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDFE5DC)),
          ),
        ),
      ),
      home: PostsPage(
        createDetailCubit: createDetailCubit,
        useFixture: useFixture,
      ),
    );
  }
}
