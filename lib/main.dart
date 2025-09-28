import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// ======================= API =======================

class PotterApi {
  PotterApi()
      : _dio = Dio(BaseOptions(
    baseUrl: 'https://potterapi-fedeperin.vercel.app/en',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  final Dio _dio;

  Future<List<HPCharacter>> getCharacters({
    String? search,
    int? max,
    int? page,
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.get(
      '/characters',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (max != null) 'max': max,
        if (page != null) 'page': page,
      },
      cancelToken: cancelToken,
    );

    final data = res.data;
    if (data is List) {
      return data.map((e) => HPCharacter.fromJson(e as Map<String, dynamic>)).toList();
    }
    return const <HPCharacter>[];
  }
}

/// ======================= MODEL =======================

class HPCharacter {
  final String fullName;
  final String? nickname;
  final String? hogwartsHouse;
  final String? interpretedBy;
  final List<String> children;
  final String? image;
  final String? birthdate;

  const HPCharacter({
    required this.fullName,
    this.nickname,
    this.hogwartsHouse,
    this.interpretedBy,
    this.children = const [],
    this.image,
    this.birthdate,
  });

  factory HPCharacter.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return HPCharacter(
      fullName: (json['fullName'] ?? '').toString(),
      nickname: _opt(json['nickname']),
      hogwartsHouse: _opt(json['hogwartsHouse']),
      interpretedBy: _opt(json['interpretedBy']),
      children: rawChildren is List
          ? rawChildren.map((e) => e.toString()).toList()
          : const <String>[],
      image: _opt(json['image']),
      birthdate: _opt(json['birthdate']),
    );
  }

  static String? _opt(dynamic v) => v == null || (v is String && v.trim().isEmpty) ? null : v.toString();
}

/// ======================= CUBIT =======================

sealed class CharactersState {
  const CharactersState();
}

class CharactersInitial extends CharactersState {
  const CharactersInitial();
}

class CharactersLoading extends CharactersState {
  const CharactersLoading();
}

class CharactersSuccess extends CharactersState {
  final List<HPCharacter> items;
  final String query;
  const CharactersSuccess(this.items, {this.query = ''});
}

class CharactersFailure extends CharactersState {
  final String message;
  const CharactersFailure(this.message);
}

class CharactersCubit extends Cubit<CharactersState> {
  CharactersCubit(this._api) : super(const CharactersInitial());

  final PotterApi _api;
  CancelToken? _lastToken;

  Future<void> fetch({String query = ''}) async {
    _lastToken?.cancel();
    final token = CancelToken();
    _lastToken = token;

    emit(const CharactersLoading());
    try {
      final items = await _api.getCharacters(search: query.trim(), cancelToken: token);
      emit(CharactersSuccess(items, query: query));
    } on DioException catch (e) {
      emit(CharactersFailure(e.message ?? 'Network error'));
    } catch (e) {
      emit(CharactersFailure(e.toString()));
    }
  }
}

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
