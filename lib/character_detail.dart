

import 'package:flutter/material.dart';

import 'hp_character.dart';

/// ======================= detail =======================

class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage(this.c, {super.key});
  final HPCharacter c;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if ((c.hogwartsHouse ?? '').isNotEmpty) c.hogwartsHouse!,
      if ((c.nickname ?? '').isNotEmpty) c.nickname!,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(c.fullName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Center(child: _Avatar(url: c.image, size: 120)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: chips.map((e) => Chip(label: Text(e))).toList(),
          ),
          const SizedBox(height: 12),
          _InfoRow('Actor', c.interpretedBy ?? '—'),
          _InfoRow('Birthdate', c.birthdate ?? '—'),
          _InfoRow('Children', c.children.isEmpty ? '—' : c.children.join(', ')),
        ],
      ),
    );
  }
}



class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.size = 56});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size, height: size, color: Colors.grey.shade200,
        child: url == null || url!.isEmpty
            ? Icon(Icons.person, size: size * .6, color: Colors.grey.shade500)
            : Image.network(url!, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.person_off, size: size * .6, color: Colors.grey.shade500)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.title, this.value);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(title, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
