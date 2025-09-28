import 'package:flutter/material.dart';

import '../../../data/models/hp_character.dart';
import '../widgets/character_avatar.dart';
import '../widgets/info_row.dart';

class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({required this.character, super.key});

  final HPCharacter character;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if ((character.hogwartsHouse ?? '').isNotEmpty) character.hogwartsHouse!,
      if ((character.nickname ?? '').isNotEmpty) character.nickname!,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(character.fullName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Center(
            child: CharacterAvatar(url: character.image, size: 120),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: chips.map((e) => Chip(label: Text(e))).toList(),
          ),
          const SizedBox(height: 12),
          CharacterInfoRow('Actor', character.interpretedBy ?? '—'),
          CharacterInfoRow('Birthdate', character.birthdate ?? '—'),
          CharacterInfoRow(
            'Children',
            character.children.isEmpty ? '—' : character.children.join(', '),
          ),
        ],
      ),
    );
  }
}
