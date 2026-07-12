import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.grey600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}