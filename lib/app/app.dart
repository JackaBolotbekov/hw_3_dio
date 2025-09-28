import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/potter_api.dart';
import '../features/characters/view/characters_page.dart';

class PotterApp extends StatelessWidget {
  const PotterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Potter Characters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5E76FA),
      ),
      home: RepositoryProvider(
        create: (_) => PotterApi(),
        child: const CharactersPage(),
      ),
    );
  }
}
