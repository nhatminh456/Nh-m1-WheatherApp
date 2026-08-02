import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reicon_flutter/reicon_flutter.dart';
import 'package:weatherapp/l10n/generated/app_localizations.dart';

import '../../../../../shared/utilities/forecast_util.dart';
import '../../viewmodels/search_viewmodel.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({
    super.key,
    required this.viewModel,
    required this.onTapItem,
  });

  final SearchViewModel viewModel;
  final void Function(String name, double lat, double lon) onTapItem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final l10n = AppLocalizations.of(context)!;

    final favorites = viewModel.favoriteCities;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ReiconIcon(
                icon: Reicon.outline.star,
                size: 48,
                color: onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noFavorites,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.favoritesInstructions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            l10n.saved,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: favorites.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final city = favorites[index];
            final weather = viewModel.favoriteWeatherMap['${city.latitude}_${city.longitude}'];

            return _GlassPanel(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTapItem(city.name, city.latitude, city.longitude),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather != null
                                  ? (weather.description.isNotEmpty
                                      ? '${weather.description[0].toUpperCase()}${weather.description.substring(1)}'
                                      : weather.condition)
                                  : l10n.loadingWeather,
                              style: TextStyle(
                                fontSize: 14,
                                color: onSurfaceVariant,
                              ),
                            ),
                            if (weather != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _ReiconIcon(
                                    icon: Reicon.outline.drop,
                                    size: 14,
                                    color: onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${weather.humidityPercent}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _ReiconIcon(
                                    icon: Reicon.outline.wind,
                                    size: 14,
                                    color: onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(weather.windSpeedMeterPerSecond * 3.6).round()} km/h',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              if (weather != null)
                                Image.asset(
                                  Util.findIcon(weather.condition, false),
                                  width: 32,
                                  height: 32,
                                ),
                              IconButton(
                                icon: _ReiconIcon(
                                  icon: Reicon.filled.star,
                                  size: 24,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  viewModel.toggleFavorite(city.name, city.latitude, city.longitude);
                                },
                              ),
                            ],
                          ),
                          if (weather != null)
                            Text(
                              '${weather.temperatureCelsius.round()}°',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.15)),
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

class _ReiconIcon extends StatelessWidget {
  const _ReiconIcon({required this.icon, this.size = 24, required this.color});

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
