import 'package:dio/dio.dart';

import 'hp_character.dart';

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