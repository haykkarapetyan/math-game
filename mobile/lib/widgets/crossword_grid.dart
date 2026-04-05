import 'package:flutter/material.dart';
import '../models/puzzle.dart';

class CrosswordGrid extends StatelessWidget {
  final Puzzle puzzle;
  final Map<String, int> playerAnswers;
  final String? selectedCell;
  final Set<String> wrongCells;
  final ValueChanged<String> onCellTap;
  final void Function(String cellKey, int poolIndex)? onDrop;

  const CrosswordGrid({
    super.key,
    required this.puzzle,
    required this.playerAnswers,
    this.selectedCell,
    this.wrongCells = const {},
    required this.onCellTap,
    this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final cellSize =
            (maxWidth / puzzle.gridCols).floorToDouble().clamp(0.0, 56.0);
        final gridWidth = cellSize * puzzle.gridCols;
        final gridHeight = cellSize * puzzle.gridRows;

        return SizedBox(
          width: gridWidth,
          height: gridHeight,
          child: Stack(
            children: [
              for (final cell in puzzle.cells) _buildCell(cell, cellSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCell(Cell cell, double cellSize) {
    final key = '${cell.row},${cell.col}';
    final isBlank = cell.isBlank;
    final isSelected = selectedCell == key;
    final hasAnswer = playerAnswers.containsKey(key);
    final isWrong = wrongCells.contains(key);

    // Display value
    String displayText;
    Color textColor;
    double fontSize = cellSize * 0.45;

    if (cell.type == CellType.op) {
      final opDisplay = cell.value == '*'
          ? '\u00D7'
          : cell.value == '/'
              ? '\u00F7'
              : '${cell.value}';
      displayText = opDisplay;
      textColor = isWrong ? const Color(0xFFD32F2F) : const Color(0xFF5D7B9A);
      fontSize = cellSize * 0.38;
    } else if (cell.type == CellType.equals) {
      displayText = '=';
      textColor = isWrong ? const Color(0xFFD32F2F) : const Color(0xFF5D7B9A);
      fontSize = cellSize * 0.38;
    } else if (hasAnswer) {
      displayText = '${playerAnswers[key]}';
      textColor = isWrong ? Colors.white : const Color(0xFF2E7D32);
    } else if (isBlank) {
      displayText = '';
      textColor = const Color(0xFF888888);
    } else {
      displayText = '${cell.value}';
      textColor = isWrong ? const Color(0xFFD32F2F) : const Color(0xFF2C3E50);
    }

    // Cell decoration
    BoxDecoration decoration;
    if (cell.type == CellType.op || cell.type == CellType.equals) {
      decoration = const BoxDecoration();
    } else if (isWrong) {
      decoration = BoxDecoration(
        color: const Color(0xFFFFCDD2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
      );
    } else if (isSelected) {
      decoration = BoxDecoration(
        color: const Color(0xFFD5E8D4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF66BB6A), width: 2.5),
      );
    } else if (hasAnswer) {
      decoration = BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF81C784), width: 1.5),
      );
    } else if (isBlank) {
      decoration = BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D0C8), width: 1),
      );
    } else {
      decoration = BoxDecoration(
        color: const Color(0xFFF5E6C8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D0C8), width: 1),
      );
    }

    final cellWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(1.5),
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final canDrop = isBlank && !hasAnswer && onDrop != null;

    return Positioned(
      left: cell.col * cellSize,
      top: cell.row * cellSize,
      width: cellSize,
      height: cellSize,
      child: canDrop
          ? DragTarget<int>(
              onAcceptWithDetails: (details) {
                onDrop!(key, details.data);
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onCellTap(key),
                  child: isHovering
                      ? Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBBDEFB),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF3D5AFE), width: 2.5),
                          ),
                        )
                      : cellWidget,
                );
              },
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isBlank && !hasAnswer ? () => onCellTap(key) : null,
              child: cellWidget,
            ),
    );
  }
}
