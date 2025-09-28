import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/hp_character.dart';
import '../../../data/potter_api.dart';
import '../bloc/characters_bloc.dart';
import '../widgets/widgets.dart';
import 'character_detail_page.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  late final CharactersBloc _bloc;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final api = context.read<PotterApi>();
    _bloc = CharactersBloc(api)..add(const CharactersRequested());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _bloc.add(CharactersRequested(query: text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(title: const Text('Characters')),
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
                child: BlocBuilder<CharactersBloc, CharactersState>(
                  builder: (context, state) {
                    if (state is CharactersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is CharactersFailure) {
                      return CharactersErrorView(
                        message: state.message,
                        onRetry: () => _bloc.add(
                          CharactersRequested(query: _searchCtrl.text),
                        ),
                      );
                    }
                    if (state is CharactersSuccess) {
                      final items = state.items;
                      if (items.isEmpty) {
                        return const CharactersEmptyView();
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 640;
                          if (isWide) {
                            final crossAxisCount = constraints.maxWidth ~/ 280;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount.clamp(2, 6),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 120,
                              ),
                              itemCount: items.length,
                              itemBuilder: (_, index) => CharacterCard(
                                character: items[index],
                                onTap: () => _openDetails(items[index]),
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (_, index) => CharacterTile(
                              character: items[index],
                              onTap: () => _openDetails(items[index]),
                            ),
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

  void _openDetails(HPCharacter character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterDetailPage(character: character),
      ),
    );
  }
}
