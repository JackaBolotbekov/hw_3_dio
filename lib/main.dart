import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hw_3_dio/potter_api.dart';

import 'character_page.dart';

void main() => runApp(const PotterApp());

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







