import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CaptainAsyncBody<T> extends StatelessWidget {
  const CaptainAsyncBody({
    super.key,
    required this.value,
    required this.builder,
    this.loading,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage = 'Nothing here yet.',
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget? loading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (error, _) => CaptainErrorView(
        message: errorMessage ?? error.toString(),
        onRetry: onRetry,
      ),
      data: (data) {
        if (data is List && (data as List).isEmpty && emptyMessage.isNotEmpty) {
          return CaptainEmptyView(message: emptyMessage);
        }
        return builder(data);
      },
    );
  }
}

class CaptainErrorView extends StatelessWidget {
  const CaptainErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.accentRed, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ],
      ),
    );
  }
}

class CaptainEmptyView extends StatelessWidget {
  const CaptainEmptyView({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
