import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _Placeholder();

    // Do not pass headers. On Chrome, extra headers force a CORS fetch, and
    // Apache does not send Access-Control-Allow-Origin on /uploads images.
    // A plain Image.network load uses <img src>, which can display without CORS.
    return Image.network(
      url,
      fit: fit,
      gaplessPlayback: true,
      // Chrome blocks canvas fetches without CORS. HTML <img> can still display.
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('PRODUCT IMAGE FAIL url=$url error=$error');
        return const _Placeholder();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFFF3F4F6),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFFFE8DE),
      child: Icon(
        Icons.fastfood_rounded,
        color: AppColors.primary,
        size: 42,
      ),
    );
  }
}
