import 'package:flutter/material.dart';

class TurnstileWidget extends StatelessWidget {
  final String siteKey;
  final ValueChanged<String> onToken;
  final ValueChanged<String>? onError;

  const TurnstileWidget({
    super.key,
    required this.siteKey,
    required this.onToken,
    this.onError,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
