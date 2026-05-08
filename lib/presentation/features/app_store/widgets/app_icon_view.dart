import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../providers/app_store_provider.dart';

class AppIconView extends ConsumerWidget {
  const AppIconView({
    super.key,
    required this.iconName,
    this.inlineIcon,
    this.size = 48,
    this.borderRadius = 13,
    this.fallbackSize,
    this.backgroundAlpha = 0.12,
    this.fit = BoxFit.cover,
  });

  final String iconName;
  final String? inlineIcon;
  final double size;
  final double borderRadius;
  final double? fallbackSize;
  final double backgroundAlpha;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = CupertinoColors.activeBlue.resolveFrom(context);
    final inlineBytes = _decodeInlineIcon(inlineIcon);
    if (inlineBytes != null) {
      return _IconFrame(
        size: size,
        borderRadius: borderRadius,
        backgroundAlpha: backgroundAlpha,
        color: color,
        child: _IconImage(
          bytes: inlineBytes,
          color: color,
          size: fallbackSize ?? size * 0.52,
          fit: fit,
        ),
      );
    }

    final iconAsync = ref.watch(appIconProvider(iconName));
    return _IconFrame(
      size: size,
      borderRadius: borderRadius,
      backgroundAlpha: backgroundAlpha,
      color: color,
      child: iconAsync.maybeWhen(
        data: (bytes) => _IconImage(
          bytes: bytes,
          color: color,
          size: fallbackSize ?? size * 0.52,
          fit: fit,
        ),
        orElse: () => Icon(
          TablerIcons.package,
          size: fallbackSize ?? size * 0.52,
          color: color,
        ),
      ),
    );
  }
}

class AppIconBackground extends ConsumerWidget {
  const AppIconBackground({
    super.key,
    required this.iconName,
    this.inlineIcon,
    this.opacity = 0.08,
    this.fit = BoxFit.cover,
  });

  final String iconName;
  final String? inlineIcon;
  final double opacity;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inlineBytes = _decodeInlineIcon(inlineIcon);
    if (inlineBytes != null) {
      return Opacity(
        opacity: opacity,
        child: Image.memory(
          inlineBytes,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      );
    }

    final iconAsync = ref.watch(appIconProvider(iconName));
    return iconAsync.maybeWhen(
      data: (bytes) => bytes.isEmpty
          ? const SizedBox.shrink()
          : Opacity(
              opacity: opacity,
              child: Image.memory(
                bytes,
                fit: fit,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _IconFrame extends StatelessWidget {
  const _IconFrame({
    required this.size,
    required this.borderRadius,
    required this.backgroundAlpha,
    required this.color,
    required this.child,
  });

  final double size;
  final double borderRadius;
  final double backgroundAlpha;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _IconImage extends StatelessWidget {
  const _IconImage({
    required this.bytes,
    required this.color,
    required this.size,
    required this.fit,
  });

  final Uint8List bytes;
  final Color color;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (bytes.isEmpty) {
      return Icon(TablerIcons.package, size: size, color: color);
    }
    return Image.memory(
      bytes,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) =>
          Icon(TablerIcons.package, size: size, color: color),
    );
  }
}

final Map<String, Uint8List> _inlineIconCache = {};

Uint8List? _decodeInlineIcon(String? icon) {
  final raw = icon?.trim();
  if (raw == null || raw.isEmpty) return null;
  final cached = _inlineIconCache[raw];
  if (cached != null) return cached;

  // Compatibility: 1Panel v2.0.0 can return app icons as base64 directly from
  // /api/v2/apps/installed/search. Prefer that to avoid an extra icon request.
  final payload = raw.startsWith('data:')
      ? raw.substring(raw.indexOf(',') + 1)
      : raw;
  try {
    final bytes = base64Decode(payload);
    if (bytes.isEmpty) return null;
    _inlineIconCache[raw] = bytes;
    return bytes;
  } catch (_) {
    return null;
  }
}
