import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../../../../shared/utilities/forecast_util.dart';
import '../../viewmodels/search_viewmodel.dart';

const _primary = Color(0xFF00658D);
const _onSurface = Color(0xFF171C20);
const _onSurfaceVariant = Color(0xFF3E4850);

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
                color: _onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có địa điểm yêu thích',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đánh dấu sao các thành phố để theo dõi nhanh thời tiết tại đây.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _onSurfaceVariant,
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Đã lưu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _onSurface,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather != null
                                  ? (weather.description.isNotEmpty
                                      ? '${weather.description[0].toUpperCase()}${weather.description.substring(1)}'
                                      : weather.condition)
                                  : 'Đang tải thời tiết...',
                              style: const TextStyle(
                                fontSize: 14,
                                color: _onSurfaceVariant,
                              ),
                            ),
                            if (weather != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _ReiconIcon(
                                    icon: Reicon.outline.drop,
                                    size: 14,
                                    color: _onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${weather.humidityPercent}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _ReiconIcon(
                                    icon: Reicon.outline.wind,
                                    size: 14,
                                    color: _onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(weather.windSpeedMeterPerSecond * 3.6).round()} km/h',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _onSurfaceVariant,
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
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: _primary,
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
    return Container(
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
