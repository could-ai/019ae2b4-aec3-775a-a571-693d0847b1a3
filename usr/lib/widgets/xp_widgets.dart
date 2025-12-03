import 'package:flutter/material.dart';
import '../xp_theme.dart';

class BeveledContainer extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final bool isPressed;
  final Color? color;
  final double? width;
  final double? height;

  const BeveledContainer({
    super.key,
    required this.child,
    this.borderWidth = 3.0,
    this.isPressed = false,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? XPColors.background,
        border: Border(
          top: BorderSide(
            color: isPressed ? XPColors.gray : XPColors.white,
            width: borderWidth,
          ),
          left: BorderSide(
            color: isPressed ? XPColors.gray : XPColors.white,
            width: borderWidth,
          ),
          right: BorderSide(
            color: isPressed ? XPColors.white : XPColors.gray,
            width: borderWidth,
          ),
          bottom: BorderSide(
            color: isPressed ? XPColors.white : XPColors.gray,
            width: borderWidth,
          ),
        ),
      ),
      child: child,
    );
  }
}

class SevenSegmentDisplay extends StatelessWidget {
  final int value;

  const SevenSegmentDisplay({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    // Clamp value between -99 and 999 for display purposes
    int displayValue = value.clamp(-99, 999);
    String text = displayValue.toString().padLeft(3, '0');
    if (displayValue < 0) {
      text = '-${displayValue.abs().toString().padLeft(2, '0')}';
    }

    return BeveledContainer(
      borderWidth: 2,
      isPressed: true, // Inset look
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Courier', // Fallback mono font, ideally use a digital font asset
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class SmileyButton extends StatelessWidget {
  final bool isPressed;
  final bool isWon;
  final bool isLost;
  final VoidCallback onPressed;

  const SmileyButton({
    super.key,
    required this.onPressed,
    this.isPressed = false,
    this.isWon = false,
    this.isLost = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(), // Handle press visual if needed
      onTapUp: (_) => onPressed(),
      onTap: onPressed,
      child: BeveledContainer(
        width: 40,
        height: 40,
        borderWidth: 2,
        isPressed: isPressed,
        child: Center(
          child: Icon(
            isWon
                ? Icons.sentiment_very_satisfied
                : isLost
                    ? Icons.sentiment_very_dissatisfied
                    : Icons.sentiment_satisfied,
            color: Colors.yellow[700],
            size: 28,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 2)
            ],
          ),
        ),
      ),
    );
  }
}
