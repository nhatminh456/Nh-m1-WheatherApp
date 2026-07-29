import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

const kHomePrimary = Color(0xFF00658D);
const kHomePrimaryFixed = Color(0xFFC6E7FF);
const kHomeSurface = Color(0xFFF5FAFF);
const kHomeOnSurface = Color(0xFF171C20);
const kHomeOnSurfaceVariant = Color(0xFF3E4850);
const kHomeSurfaceVariant = Color(0xFFDEE3E8);

class GlassPanel extends StatelessWidget {
  const GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ReiconIcon extends StatelessWidget {
  const ReiconIcon({required this.icon, this.size = 24, required this.color});

  final String icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      reiconSvg(icon),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
