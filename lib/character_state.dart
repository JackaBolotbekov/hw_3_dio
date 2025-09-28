part of 'character_cubit.dart';

@immutable
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


