import 'package:flutter/material.dart';

import '../../../data/models/hp_character.dart';
import 'character_avatar.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.character, this.onTap});

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CharacterAvatar(url: character.image, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      character.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'House: $house',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Actor: $actor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
