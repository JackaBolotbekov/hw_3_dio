
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hw_3_dio/potter_api.dart';

import 'character_cubit.dart';
import 'character_detail.dart';
import 'hp_character.dart';

/// ======================= UI =======================

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  late final CharactersCubit _cubit;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final api = context.read<PotterApi>();
    _cubit = CharactersCubit(api);
    _cubit.fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _cubit.fetch(query: text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text('Characters'),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by name…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<CharactersCubit, CharactersState>(
                  builder: (context, state) {
                    if (state is CharactersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is CharactersFailure) {
                      return _ErrorView(
                        message: state.message,
                        onRetry: () => _cubit.fetch(query: _searchCtrl.text),
                      );
                    }
                    if (state is CharactersSuccess) {
                      final items = state.items;
                      if (items.isEmpty) {
                        return const _EmptyView();
                      }
                      return LayoutBuilder(
                        builder: (context, cons) {
                          final isWide = cons.maxWidth >= 640;
                          if (isWide) {
                            final cross = cons.maxWidth ~/ 280;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross.clamp(2, 6),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 120,
                              ),
                              itemCount: items.length,
                              itemBuilder: (_, i) => _CharacterCard(items[i]),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (_, i) => _CharacterTile(items[i]),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// ======================= widgets =======================

class _CharacterTile extends StatelessWidget {
  const _CharacterTile(this.c);
  final HPCharacter c;

  @override
  Widget build(BuildContext context) {
    final house = c.hogwartsHouse?.isNotEmpty == true ? c.hogwartsHouse : '—';
    final actor = c.interpretedBy?.isNotEmpty == true ? c.interpretedBy : '—';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: _Avatar(url: c.image),
        title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('House: $house\nActor: $actor'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CharacterDetailPage(c)),
          );
        },
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard(this.c);
  final HPCharacter c;

  @override
  Widget build(BuildContext context) {
    final house = c.hogwartsHouse?.isNotEmpty == true ? c.hogwartsHouse : '—';
    final actor = c.interpretedBy?.isNotEmpty == true ? c.interpretedBy : '—';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CharacterDetailPage(c)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(url: c.image, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c.fullName, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('House: $house', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Actor: $actor', maxLines: 1, overflow: TextOverflow.ellipsis),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Nothing found', style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}