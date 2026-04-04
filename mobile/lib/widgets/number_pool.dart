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
            _NumberTile(
              value: availableNumbers[i],
              isSelected: selectedIndex == i,
              onTap: () => onNumberTap(i),
            ),
        ],
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _NumberTile({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
