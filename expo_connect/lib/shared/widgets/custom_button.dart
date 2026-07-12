import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? AppColors.primary,
              side: BorderSide(
                color: backgroundColor ?? AppColors.primary,
              ),
              minimumSize: isFullWidth
                  ? const Size(double.infinity, 48)
                  : null,
            ),
            child: _buildChild(),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primary,
              foregroundColor: textColor ?? Colors.white,
              minimumSize: isFullWidth
                  ? const Size(double.infinity, 48)
                  : null,
            ),
            child: _buildChild(),
          );

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}