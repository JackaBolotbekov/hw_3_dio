import 'package:flutter/material.dart';

class CharactersEmptyView extends StatelessWidget {
  const CharactersEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nothing found',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
