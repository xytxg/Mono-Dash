import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_icon_path_cache.dart';
import '../../../../data/dto/file/file_item_dto.dart';

class FileIconUtils {
  FileIconUtils._();

  /// 获取文件夹对应的 PNG 资源路径
  static String getFolderAssetPath(String name, String path) {
    // 仅针对根目录下的系统文件夹显示特殊图标（不区分大小写）
    final lowerPath = path.toLowerCase();

    return switch (lowerPath) {
      '/' || '/root' => 'assets/icons/folder-icon-root.png',
      '/boot' => 'assets/icons/folder-icon-boot.png',
      '/bin' || '/sbin' => 'assets/icons/folder-icon-bin.png',
      '/dev' => 'assets/icons/folder-icon-dev.png',
      '/etc' => 'assets/icons/folder-icon-etc.png',
      '/home' => 'assets/icons/folder-icon-home.png',
      '/lib' || '/lib64' => 'assets/icons/folder-icon-lib.png',
      '/mnt' => 'assets/icons/folder-icon-mnt.png',
      '/opt' => 'assets/icons/folder-icon-opt.png',
      '/opt/1panel' => 'assets/icons/folder-icon-1panel.png',
      '/opt/1panel/www' => 'assets/icons/folder-icon-opensety.png',
      '/tmp' => 'assets/icons/folder-icon-tmp.png',
      '/var' => 'assets/icons/folder-icon-var.png',
      _ => _checkDynamicPaths(lowerPath),
    };
  }

  static String _checkDynamicPaths(String lowerPath) {
    final websitePath = FileIconPathCache.websitePath;
    final onePanelPath = FileIconPathCache.onePanelPath;
    if (websitePath != null && lowerPath == websitePath.toLowerCase()) {
      return 'assets/icons/folder-icon-opensety.png';
    }
    if (onePanelPath != null && lowerPath == onePanelPath.toLowerCase()) {
      return 'assets/icons/folder-icon-1panel.png';
    }
    if (lowerPath == '/var/run/docker') {
      return 'assets/icons/folder-icon-docker.png';
    }
    return 'assets/icons/folder-icon-default.png';
  }

  /// 无扩展名的特殊文件名 → (图标, 颜色)
  static const _specialFiles = <String, (IconData, CupertinoDynamicColor)>{
    'dockerfile': (TablerIcons.brand_docker, CupertinoColors.systemBlue),
    'makefile': (TablerIcons.hammer, CupertinoColors.systemOrange),
    'authorized_keys': (TablerIcons.key, CupertinoColors.systemGreen),
  };

  /// 获取文件对应的图标和颜色
  static (IconData, Color) getFileIconInfo(
    BuildContext context,
    String ext,
    String name,
  ) {
    final special = _specialFiles[name.toLowerCase()];
    if (special != null) {
      return (special.$1, special.$2.resolveFrom(context));
    }

    return switch (ext.toLowerCase()) {
      '.zip' ||
      '.gz' ||
      '.tar' ||
      '.rar' ||
      '.7z' ||
      '.bz2' ||
      '.tgz' ||
      '.xz' ||
      '.tar.bz2' ||
      '.tar.gz' ||
      '.tar.xz' => (
        TablerIcons.file_zip,
        CupertinoColors.systemOrange.resolveFrom(context),
      ),
      '.sh' ||
      '.py' ||
      '.js' ||
      '.html' ||
      '.css' ||
      '.php' ||
      '.go' ||
      '.yaml' ||
      '.yml' ||
      '.json' => (
        TablerIcons.file_code,
        CupertinoColors.systemTeal.resolveFrom(context),
      ),
      '.txt' || '.md' || '.log' || '.conf' || '.ini' => (
        TablerIcons.file_text,
        CupertinoColors.systemGrey.resolveFrom(context),
      ),
      '.jpg' || '.jpeg' || '.png' || '.gif' || '.svg' || '.webp' => (
        TablerIcons.photo,
        CupertinoColors.systemPurple.resolveFrom(context),
      ),
      '.pdf' => (
        TablerIcons.file_type_pdf,
        CupertinoColors.systemRed.resolveFrom(context),
      ),
      '.mp4' || '.mov' || '.avi' || '.mkv' => (
        TablerIcons.video,
        CupertinoColors.systemPink.resolveFrom(context),
      ),
      '.mp3' || '.wav' || '.flac' || '.aac' => (
        TablerIcons.music,
        CupertinoColors.systemIndigo.resolveFrom(context),
      ),
      _ =>
        name.startsWith('.')
            ? (
                TablerIcons.file_settings,
                CupertinoColors.systemGrey.resolveFrom(context),
              )
            : (
                TablerIcons.file,
                CupertinoColors.systemGrey.resolveFrom(context),
              ),
    };
  }

  /// 构建统一的文件/文件夹图标组件
  static Widget buildIcon(
    BuildContext context,
    FileItemDto item, {
    double size = 32,
    Color? tintColor,
  }) {
    final opacity = item.isHidden ? 0.45 : 1.0;
    final isFavorite = item.favoriteID != 0;

    Widget iconWidget;
    if (item.isDir) {
      // 文件夹图标
      final assetPath = isFavorite
          ? 'assets/icons/folder-icon-favorite.png'
          : getFolderAssetPath(item.name, item.path);

      iconWidget = Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );

      // 叠加小标逻辑
      if (!isFavorite) {
        if (item.shareCode.isNotEmpty) {
          iconWidget = _buildBadgeOverlay(
            context,
            iconWidget,
            size,
            TablerIcons.share,
            CupertinoColors.systemGreen,
          );
        } else if (item.isSymlink) {
          iconWidget = _buildBadgeOverlay(
            context,
            iconWidget,
            size,
            CupertinoIcons.link,
            CupertinoColors.activeBlue,
          );
        }
      }
    } else {
      // 文件图标
      final ext = item.extension.toLowerCase();
      final (icon, color) = getFileIconInfo(context, ext, item.name);

      iconWidget = Icon(icon, size: size, color: tintColor ?? color);

      if (isFavorite) {
        // 收藏优先：显示星标
        iconWidget = _buildBadgeOverlay(
          context,
          iconWidget,
          size,
          TablerIcons.star_filled,
          const Color(0xFFF8D748),
        );
      } else if (item.shareCode.isNotEmpty) {
        // 其次是分享：显示分享小标
        iconWidget = _buildBadgeOverlay(
          context,
          iconWidget,
          size,
          TablerIcons.share,
          CupertinoColors.systemGreen,
        );
      } else if (item.isSymlink) {
        // 最后是符号链接：显示链接小标
        iconWidget = _buildBadgeOverlay(
          context,
          iconWidget,
          size,
          CupertinoIcons.link,
          CupertinoColors.activeBlue,
        );
      }
    }

    final fixedIcon = Align(
      alignment: Alignment.center,
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox(width: size, height: size, child: iconWidget),
    );

    if (opacity < 1.0) {
      return Opacity(opacity: opacity, child: fixedIcon);
    }
    return fixedIcon;
  }

  /// 内部方法：构建叠加徽标
  static Widget _buildBadgeOverlay(
    BuildContext context,
    Widget base,
    double size,
    IconData badgeIcon,
    Color badgeColor,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: base),
        Positioned(
          right: -size * 0.05,
          bottom: -size * 0.05,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              shape: BoxShape.circle,
            ),
            child: Icon(badgeIcon, size: size * 0.38, color: badgeColor),
          ),
        ),
      ],
    );
  }
}
