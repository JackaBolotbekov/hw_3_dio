import 'package:flutter/material.dart';

import '../../../data/models/hp_character.dart';
import 'character_avatar.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key, required this.character, this.onTap});

  final HPCharacter character;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final house = character.hogwartsHouse?.isNotEmpty == true
        ? character.hogwartsHouse
        : '—';
    final actor = character.interpretedBy?.isNotEmpty == true
        ? character.interpretedBy
        : '—';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CharacterAvatar(url: character.image),
        title: Text(
          character.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('House: $house\nActor: $actor'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
