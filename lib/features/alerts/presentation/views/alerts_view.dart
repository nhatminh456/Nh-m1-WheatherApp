import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../../../shared/widgets/atmosphere_bottom_navigation_bar.dart';
import '../../../../shared/models/user_settings.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../data/models/weather_alert.dart';
import '../viewmodels/alerts_viewmodel.dart';

class AlertsView extends StatefulWidget {
  const AlertsView({
    super.key,
    required this.viewModel,
    required this.settingsViewModel,
  });

  final AlertsViewModel viewModel;
  final SettingsViewModel settingsViewModel;

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsViewModel,
      builder: (context, _) {
        final temperatureUnit = widget.settingsViewModel.settings.temperatureUnit;

        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: isDark ? 0.26 : 0.7),
                colorScheme.surface,
              ],
              stops: const [0, 0.62],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: _ReiconIcon(
                  icon: Reicon.outline.menu,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {},
              ),
              title: Text(
                'Atmosphere',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: _ReiconIcon(
                    icon: Reicon.outline.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Chi tiết thời tiết',
                  onPressed: () => context.go('/weather'),
                ),
              ],
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: RefreshIndicator(
                  onRefresh: () => widget.viewModel.load(forceRefresh: true),
                  child: ListenableBuilder(
                    listenable: widget.viewModel,
                    builder: (context, _) => _buildBody(context, temperatureUnit),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: AtmosphereBottomNavigationBar(
              selectedIndex: 2,
              onDestinationSelected: (index) {
                if (index == 0) context.go('/');
                else if (index == 2) context.go('/alerts');
                else if (index == 4) context.go('/settings');
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              onPressed: () => _openEditor(context, temperatureUnit: temperatureUnit),
              icon: const Icon(Icons.add),
              label: const Text('Tạo mới'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TemperatureUnit temperatureUnit) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.viewModel.status) {
      case AlertsLoadStatus.initial:
      case AlertsLoadStatus.loading:
        return Center(child: CircularProgressIndicator(color: colorScheme.primary));
      case AlertsLoadStatus.error:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Center(
              child: _ReiconIcon(
                icon: Reicon.outline.cloudCross,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.viewModel.errorMessage ?? 'Đã có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
                onPressed: () => widget.viewModel.load(forceRefresh: true),
                child: const Text('Thử lại'),
              ),
            ),
          ],
        );
      case AlertsLoadStatus.success:
        if (widget.viewModel.alerts.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            children: [
              const SizedBox(height: 32),
              const _EmptyAlertsState(),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
                onPressed: () => _openEditor(context, temperatureUnit: temperatureUnit),
                icon: const Icon(Icons.add),
                label: const Text('Tạo cảnh báo đầu tiên'),
              ),
            ],
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Text(
              'Cảnh báo thời tiết',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quản lý các thông báo quan trọng.',
              style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                onPressed: () => _openEditor(context, temperatureUnit: temperatureUnit),
                icon: const Icon(Icons.add),
                label: const Text('Tạo mới'),
              ),
            ),
            const SizedBox(height: 20),
            for (final alert in widget.viewModel.alerts) ...[
              _AlertCard(
                alert: alert,
                temperatureUnit: temperatureUnit,
                onToggle: (enabled) => widget.viewModel.setEnabled(alert, enabled),
                onEdit: () => _openEditor(context, alert: alert, temperatureUnit: temperatureUnit),
                onDelete: () => _confirmDelete(context, alert),
                onThresholdChanged: (threshold) => widget.viewModel.saveAlert(
                  alert.copyWith(threshold: threshold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WeatherAlert alert) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá cảnh báo?'),
        content: Text('Xoá ${alert.title} tại ${alert.city}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.viewModel.deleteAlert(alert);
    }
  }

  Future<void> _openEditor(
    BuildContext context, {
    WeatherAlert? alert,
    required TemperatureUnit temperatureUnit,
  }) async {
    final result = await showModalBottomSheet<WeatherAlert>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AlertEditorSheet(
        alert: alert,
        temperatureUnit: temperatureUnit,
      ),
    );

    if (result == null) return;

    if (alert == null) {
      await widget.viewModel.createAlert(result);
    } else {
      await widget.viewModel.saveAlert(result.copyWith(id: alert.id));
    }
  }
}

class _AlertCard extends StatefulWidget {
  const _AlertCard({
    required this.alert,
    required this.temperatureUnit,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onThresholdChanged,
  });

  final WeatherAlert alert;
  final TemperatureUnit temperatureUnit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<double> onThresholdChanged;

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  late double _thresholdValue;

  @override
  void initState() {
    super.initState();
    _thresholdValue = _displayThreshold(
      widget.alert.metric,
      widget.alert.threshold,
      widget.temperatureUnit,
    );
  }

  @override
  void didUpdateWidget(covariant _AlertCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alert.threshold != widget.alert.threshold ||
        oldWidget.temperatureUnit != widget.temperatureUnit) {
      _thresholdValue = _displayThreshold(
        widget.alert.metric,
        widget.alert.threshold,
        widget.temperatureUnit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final metric = widget.alert.metric;
    final accent = _accentFor(metric);
    final bg = accent.withValues(alpha: widget.alert.enabled ? 0.14 : 0.07);
    final enabledColor = widget.alert.enabled ? accent : colorScheme.outline;
    final displayThreshold = _displayThreshold(metric, widget.alert.threshold, widget.temperatureUnit);
    final displayMin = _displayThreshold(metric, metric.minThreshold, widget.temperatureUnit);
    final displayMax = _displayThreshold(metric, metric.maxThreshold, widget.temperatureUnit);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: widget.alert.enabled ? 0.72 : 0.58,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bg,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_iconFor(metric), color: accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.alert.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.alert.city,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: widget.alert.enabled,
                      activeThumbColor: accent,
                      onChanged: widget.onToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  metric.description,
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      metric.thresholdLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _thresholdText(metric, displayThreshold, widget.temperatureUnit),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accent,
                    inactiveTrackColor: accent.withValues(alpha: 0.18),
                    thumbColor: accent,
                    overlayColor: accent.withValues(alpha: 0.12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _thresholdValue.clamp(displayMin, displayMax),
                    min: displayMin,
                    max: displayMax,
                    divisions:
                        ((displayMax - displayMin) / _displayStep(metric, widget.temperatureUnit))
                            .round(),
                    label: _thresholdText(metric, _thresholdValue, widget.temperatureUnit),
                    onChanged: widget.alert.enabled
                        ? (value) {
                            setState(() => _thresholdValue = value);
                          }
                        : null,
                    onChangeEnd: widget.alert.enabled
                        ? (value) => widget.onThresholdChanged(
                              _storedThreshold(metric, value, widget.temperatureUnit),
                            )
                        : null,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _thresholdLabel(metric, displayMin, widget.temperatureUnit),
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Text(
                      _thresholdLabel(metric, displayMax, widget.temperatureUnit),
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Sửa'),
                    ),
                    TextButton.icon(
                      onPressed: widget.onDelete,
                      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Xoá'),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: enabledColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.alert.enabled ? 'Đang bật' : 'Đang tắt',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: enabledColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(WeatherAlertMetric metric) {
    return switch (metric) {
      WeatherAlertMetric.rain => Icons.cloudy_snowing,
      WeatherAlertMetric.lowTemperature => Icons.thermostat,
      WeatherAlertMetric.highUv => Icons.wb_sunny_outlined,
    };
  }

  Color _accentFor(WeatherAlertMetric metric) {
    return switch (metric) {
      WeatherAlertMetric.rain => const Color(0xFF1992C5),
      WeatherAlertMetric.lowTemperature => const Color(0xFFFFA23A),
      WeatherAlertMetric.highUv => const Color(0xFF5E6C84),
    };
  }
}

class _AlertEditorSheet extends StatefulWidget {
  const _AlertEditorSheet({this.alert, required this.temperatureUnit});

  final WeatherAlert? alert;
  final TemperatureUnit temperatureUnit;

  @override
  State<_AlertEditorSheet> createState() => _AlertEditorSheetState();
}

class _AlertEditorSheetState extends State<_AlertEditorSheet> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _titleController;
  late final TextEditingController _cityController;
  late WeatherAlertMetric _metric;
  late double _threshold;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _titleController = TextEditingController(text: widget.alert?.title ?? '');
    _cityController = TextEditingController(text: widget.alert?.city ?? '');
    _metric = widget.alert?.metric ?? WeatherAlertMetric.rain;
    final storedThreshold = widget.alert?.threshold ?? _metric.maxThreshold / 10;
    _threshold = _displayThreshold(_metric, storedThreshold, widget.temperatureUnit);
    _enabled = widget.alert?.enabled ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final metric = _metric;
    final displayThreshold = _displayThreshold(metric, _threshold, widget.temperatureUnit);
    final displayMin = _displayThreshold(metric, metric.minThreshold, widget.temperatureUnit);
    final displayMax = _displayThreshold(metric, metric.maxThreshold, widget.temperatureUnit);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Material(
          color: colorScheme.surface,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.alert == null ? 'Tạo cảnh báo' : 'Sửa cảnh báo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Thiết lập loại cảnh báo, địa điểm và ngưỡng kích hoạt.',
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên cảnh báo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Nhập tên cảnh báo'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'Khu vực',
                        hintText: _metric.cityHint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Nhập khu vực'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<WeatherAlertMetric>(
                      initialValue: _metric,
                      decoration: const InputDecoration(
                        labelText: 'Loại cảnh báo',
                        border: OutlineInputBorder(),
                      ),
                      items: WeatherAlertMetric.values
                          .map(
                            (metric) => DropdownMenuItem(
                              value: metric,
                              child: Text(metric.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _metric = value;
                          _threshold = _threshold.clamp(
                            _metric.minThreshold,
                            _metric.maxThreshold,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${metric.thresholdLabel}: ${_thresholdText(metric, displayThreshold, widget.temperatureUnit)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Switch(
                          value: _enabled,
                          onChanged: (value) => setState(() => _enabled = value),
                        ),
                      ],
                    ),
                    Slider(
                      value: _threshold.clamp(displayMin, displayMax),
                      min: displayMin,
                      max: displayMax,
                      divisions:
                          ((displayMax - displayMin) / _displayStep(metric, widget.temperatureUnit))
                              .round(),
                      label: _thresholdText(metric, _threshold, widget.temperatureUnit),
                      onChanged: (value) => setState(() => _threshold = value),
                    ),
                    Row(
                      children: [
                        Text(
                          _thresholdLabel(metric, displayMin, widget.temperatureUnit),
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Text(
                          _thresholdLabel(metric, displayMax, widget.temperatureUnit),
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Huỷ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
                            onPressed: _submit,
                            child: const Text('Lưu'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final alert = WeatherAlert(
      id: widget.alert?.id,
      title: _titleController.text.trim(),
      city: _cityController.text.trim(),
      metric: _metric,
      threshold: _storedThreshold(_metric, _threshold, widget.temperatureUnit),
      enabled: _enabled,
    );
    Navigator.of(context).pop(alert);
  }
}

class _EmptyAlertsState extends StatelessWidget {
  const _EmptyAlertsState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 56,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có cảnh báo nào',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo các quy tắc như mưa lớn, rét đậm hoặc UV cao để nhận cảnh báo kịp thời.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

double _displayThreshold(
  WeatherAlertMetric metric,
  double threshold,
  TemperatureUnit temperatureUnit,
) {
  if (metric != WeatherAlertMetric.lowTemperature) {
    return threshold;
  }

  return temperatureUnit.fromCelsius(threshold);
}

double _storedThreshold(
  WeatherAlertMetric metric,
  double threshold,
  TemperatureUnit temperatureUnit,
) {
  if (metric != WeatherAlertMetric.lowTemperature) {
    return threshold;
  }

  return temperatureUnit.toCelsius(threshold);
}

double _displayStep(
  WeatherAlertMetric metric,
  TemperatureUnit temperatureUnit,
) {
  if (metric != WeatherAlertMetric.lowTemperature) {
    return metric.step;
  }

  return temperatureUnit == TemperatureUnit.celsius ? metric.step : metric.step * 9 / 5;
}

String _thresholdLabel(
  WeatherAlertMetric metric,
  double value,
  TemperatureUnit temperatureUnit,
) {
  final digits = metric.step < 1 ? 1 : 0;
  final unit = metric == WeatherAlertMetric.lowTemperature
      ? temperatureUnit.symbol
      : metric.unit;
  return '${value.toStringAsFixed(digits)} $unit';
}

String _thresholdText(
  WeatherAlertMetric metric,
  double value,
  TemperatureUnit temperatureUnit,
) {
  final digits = metric.step < 1 ? 1 : 0;
  final unit = metric == WeatherAlertMetric.lowTemperature
      ? temperatureUnit.symbol
      : metric.unit;
  return '${value.toStringAsFixed(digits)} $unit';
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
