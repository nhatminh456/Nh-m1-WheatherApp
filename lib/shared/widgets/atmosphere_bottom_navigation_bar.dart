import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

class AtmosphereBottomNavigationBar extends StatelessWidget {
  const AtmosphereBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onDestinationSelected,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: disabledColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: [
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.chartBar, disabledColor),
          activeIcon: _navIcon(Reicon.filled.chartBar, colorScheme.primary),
          label: 'Dự báo',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.location, disabledColor),
          label: 'Vị trí',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.bellAlert, disabledColor),
          activeIcon: _navIcon(Reicon.filled.bellAlert, colorScheme.primary),
          label: 'Cảnh báo',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.history, disabledColor),
          label: 'Lịch sử',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.settings, disabledColor),
          label: 'Cài đặt',
        ),
      ],
    );
  }

  Widget _navIcon(String path, Color color) {
    return _ReiconIcon(icon: path, color: color);
  }
}

class _ReiconIcon extends StatelessWidget {
  const _ReiconIcon({required this.icon, required this.color});

  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      reiconSvg(icon),
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
