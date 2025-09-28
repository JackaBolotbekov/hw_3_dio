import 'package:flutter/material.dart';

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, this.url, this.size = 56});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: url == null || url!.isEmpty
            ? Icon(Icons.person, size: size * .6, color: Colors.grey.shade500)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_off,
                  size: size * .6,
                  color: Colors.grey.shade500,
                ),
              ),
      ),
    );
  }
}
