import 'package:flutter/material.dart';

// Full screen loading widget
class LoadingWidget extends StatelessWidget {
  final String message;
  final double size;

  const LoadingWidget({
    Key? key,
    this.message = 'Đang tải...',
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF1976D2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String loadingMessage;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingMessage = 'Đang xử lý...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: LoadingWidget(message: loadingMessage),
          ),
      ],
    );
  }
}

// Small loading spinner
class SmallLoadingSpinner extends StatelessWidget {
  final Color color;
  final double size;

  const SmallLoadingSpinner({
    Key? key,
    this.color = const Color(0xFF1976D2),
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}