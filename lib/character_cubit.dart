import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:hw_3_dio/potter_api.dart';
import 'package:meta/meta.dart';

import 'hp_character.dart';

part 'character_state.dart';

/// ======================= CUBIT =======================

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
