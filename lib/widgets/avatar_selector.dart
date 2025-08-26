import 'package:flutter/material.dart';

class AvatarSelector extends StatelessWidget {
  final List<String> avatars;
  final String selectedAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    required this.avatars,
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: avatars.map((avatar) {
        final isSelected = avatar == selectedAvatar;
        return GestureDetector(
          onTap: () => onAvatarSelected(avatar),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.greenAccent, width: 3)
                  : null,
            ),
            padding: EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(avatar),
            ),
          ),
        );
      }).toList(),
    );
  }
}
