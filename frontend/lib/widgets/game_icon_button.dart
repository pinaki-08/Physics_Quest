import 'package:flutter/material.dart';

class GameIconButton extends StatelessWidget {
  const GameIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tonal = true,
    this.selected,
    this.color = const Color(0xFF426D73),
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool tonal;
  final bool? selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final button = tonal
        ? IconButton.filledTonal(
            onPressed: onPressed,
            isSelected: selected,
            style: IconButton.styleFrom(
              backgroundColor: selected == true
                  ? const Color(0xFFD9E6E0)
                  : null,
            ),
            icon: Icon(icon),
          )
        : IconButton(onPressed: onPressed, icon: Icon(icon, color: color));
    return MergeSemantics(
      child: Semantics(
        label: label,
        selected: selected,
        child: Tooltip(
          message: label,
          excludeFromSemantics: true,
          child: button,
        ),
      ),
    );
  }
}
