import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../../data/models/hp_character.dart';
import '../../../data/potter_api.dart';

sealed class CharactersEvent {
  const CharactersEvent();
}

class CharactersRequested extends CharactersEvent {
  const CharactersRequested({this.query = ''});

  final String query;
}

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
  const CharactersSuccess(this.items, {this.query = ''});

  final List<HPCharacter> items;
  final String query;
}

class CharactersFailure extends CharactersState {
  const CharactersFailure(this.message);

  final String message;
}

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc(this._api) : super(const CharactersInitial()) {
    on<CharactersRequested>(_onRequested, transformer: _restartable());
  }

  final PotterApi _api;
  CancelToken? _token;

  Future<void> _onRequested(
    CharactersRequested event,
    Emitter<CharactersState> emit,
  ) async {
    _token?.cancel();
    _token = CancelToken();

    emit(const CharactersLoading());
    try {
      final items = await _api.getCharacters(
        search: event.query.trim(),
        cancelToken: _token,
      );
      emit(CharactersSuccess(items, query: event.query));
    } on DioException catch (error) {
      emit(CharactersFailure(error.message ?? 'Network error'));
    } catch (error) {
      emit(CharactersFailure(error.toString()));
    }
  }

  EventTransformer<T> _restartable<T>() {
    return (events, mapper) => events.asyncExpand(mapper);
  }

  @override
  Future<void> close() {
    _token?.cancel();
    return super.close();
  }
}
