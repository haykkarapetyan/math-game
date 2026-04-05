import 'package:flutter/material.dart';

class NumberPool extends StatelessWidget {
  final List<int> availableNumbers;
  final int? selectedIndex;
  final ValueChanged<int> onNumberTap;

  const NumberPool({
    super.key,
    required this.availableNumbers,
    this.selectedIndex,
    required this.onNumberTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < availableNumbers.length; i++)
            _DraggableNumberTile(
              index: i,
              value: availableNumbers[i],
              isSelected: selectedIndex == i,
              onTap: () => onNumberTap(i),
            ),
        ],
      ),
    );
  }
}

class _DraggableNumberTile extends StatelessWidget {
  final int index;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _DraggableNumberTile({
    required this.index,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF66BB6A) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF81C784),
          width: isSelected ? 2.5 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF2E7D32),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      delay: const Duration(milliseconds: 150),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
