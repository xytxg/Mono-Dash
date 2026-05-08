import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// 数据库类型图标组件，支持 SVG 图标和集群标识叠加。
class DatabaseTypeIcon extends StatelessWidget {
  const DatabaseTypeIcon({super.key, required this.type, this.size = 24});

  final String type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalizedType = type.toLowerCase();
    final isCluster = normalizedType.contains('cluster');

    // 基础类型判定
    String baseType = normalizedType;
    if (normalizedType.contains('mysql')) {
      baseType = 'mysql';
    } else if (normalizedType.contains('postgresql')) {
      baseType = 'postgresql';
    } else if (normalizedType.contains('mariadb')) {
      baseType = 'mariadb';
    } else if (normalizedType.contains('redis')) {
      baseType = 'redis';
    }

    final (assetPath, color) = _getTypeInfo(baseType);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 主图标
          SvgPicture.asset(
            assetPath,
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),

          // 集群标识
          if (isCluster)
            Positioned(
              right: -size * 0.1,
              bottom: -size * 0.1,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TablerIcons.layers_intersect, // 或者 TablerIcons.nodes_group
                  size: size * 0.5,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  (String, Color) _getTypeInfo(String baseType) {
    return switch (baseType) {
      'mysql' => ('assets/icons/mysql.svg', const Color(0xFF4479A1)),
      'postgresql' => ('assets/icons/postgresql.svg', const Color(0xFF4169E1)),
      'mariadb' => ('assets/icons/mariadb.svg', const Color(0xFF003545)),
      'redis' => ('assets/icons/redis.svg', const Color(0xFFFF4438)),
      _ => ('assets/icons/mysql.svg', CupertinoColors.systemGrey), // 默认
    };
  }
}
