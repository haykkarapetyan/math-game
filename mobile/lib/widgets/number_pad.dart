import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final ValueChanged<int> onNumberTap;
  final VoidCallback? onHint;
  final int hintsRemaining;

  const NumberPad({
    super.key,
    required this.onNumberTap,
    this.onHint,
    this.hintsRemaining = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Numbers 1-5
          Row(
            children: List.generate(
              5,
              (i) => Expanded(
                child: _NumButton(
                  value: i + 1,
                  onTap: () => onNumberTap(i + 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Numbers 6-0 + hint
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Expanded(
                  child: _NumButton(
                    value: (i + 6) % 10,
                    label: i == 4 ? '0' : null,
                    onTap: () => onNumberTap((i + 6) % 10),
                  ),
                ),
              ),
            ],
          ),
          if (onHint != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: hintsRemaining > 0 ? onHint : null,
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: Text('Hint ($hintsRemaining)'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber,
                  disabledForegroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumButton extends StatelessWidget {
  final int value;
  final String? label;
  final VoidCallback onTap;

  const _NumButton({
    required this.value,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label ?? '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
