import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../../../shared/widgets/atmosphere_bottom_navigation_bar.dart';
import '../../data/models/weather_alert.dart';
import '../viewmodels/alerts_viewmodel.dart';

const _primary = Color(0xFF00658D);
const _primaryFixed = Color(0xFFC6E7FF);
const _surface = Color(0xFFF5FAFF);
const _onSurface = Color(0xFF171C20);
const _onSurfaceVariant = Color(0xFF3E4850);

class AlertsView extends StatefulWidget {
  const AlertsView({super.key, required this.viewModel});

  final AlertsViewModel viewModel;

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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_primaryFixed, _surface],
          stops: [0, 0.62],
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
              color: _onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          title: const Text(
            'Atmosphere',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: _ReiconIcon(
                icon: Reicon.outline.search,
                color: _onSurfaceVariant,
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
                builder: (context, _) => _buildBody(context),
              ),
            ),
          ),
        ),
        bottomNavigationBar: AtmosphereBottomNavigationBar(
          selectedIndex: 2,
          onDestinationSelected: (index) {
            if (index == 0) {
              context.go('/');
            }
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          onPressed: () => _openEditor(context),
          icon: const Icon(Icons.add),
          label: const Text('Tạo mới'),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (widget.viewModel.status) {
      case AlertsLoadStatus.initial:
      case AlertsLoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: _primary));
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
                color: _onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.viewModel.errorMessage ?? 'Đã có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _primary),
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
                style: FilledButton.styleFrom(backgroundColor: _primary),
                onPressed: () => _openEditor(context),
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
            const Text(
              'Cảnh báo thời tiết',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quản lý các thông báo quan trọng.',
              style: TextStyle(fontSize: 16, color: _onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Tạo mới'),
              ),
            ),
            const SizedBox(height: 20),
            for (final alert in widget.viewModel.alerts) ...[
              _AlertCard(
                alert: alert,
                onToggle: (enabled) => widget.viewModel.setEnabled(alert, enabled),
                onEdit: () => _openEditor(context, alert: alert),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
  }) async {
    final result = await showModalBottomSheet<WeatherAlert>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AlertEditorSheet(alert: alert),
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
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onThresholdChanged,
  });

  final WeatherAlert alert;
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
    _thresholdValue = widget.alert.threshold;
  }

  @override
  void didUpdateWidget(covariant _AlertCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alert.threshold != widget.alert.threshold) {
      _thresholdValue = widget.alert.threshold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metric = widget.alert.metric;
    final accent = _accentFor(metric);
    final bg = accent.withValues(alpha: widget.alert.enabled ? 0.14 : 0.07);
    final enabledColor = widget.alert.enabled ? accent : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.alert.city,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _onSurfaceVariant,
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
                  style: const TextStyle(fontSize: 14, color: _onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      metric.thresholdLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.alert.thresholdText,
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
                    value: _thresholdValue.clamp(
                      metric.minThreshold,
                      metric.maxThreshold,
                    ),
                    min: metric.minThreshold,
                    max: metric.maxThreshold,
                    divisions:
                        ((metric.maxThreshold - metric.minThreshold) / metric.step)
                            .round(),
                    label: widget.alert.thresholdText,
                    onChanged: widget.alert.enabled
                        ? (value) {
                            setState(() => _thresholdValue = value);
                          }
                        : null,
                    onChangeEnd: widget.alert.enabled
                        ? (value) => widget.onThresholdChanged(value)
                        : null,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${metric.minThreshold.toStringAsFixed(metric.step < 1 ? 1 : 0)} ${metric.unit}',
                      style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
                    ),
                    const Spacer(),
                    Text(
                      '${metric.maxThreshold.toStringAsFixed(metric.step < 1 ? 1 : 0)} ${metric.unit}',
                      style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
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
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
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
  const _AlertEditorSheet({this.alert});

  final WeatherAlert? alert;

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
    _threshold = widget.alert?.threshold ?? _metric.maxThreshold / 10;
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Material(
          color: Colors.white,
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
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.alert == null ? 'Tạo cảnh báo' : 'Sửa cảnh báo',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Thiết lập loại cảnh báo, địa điểm và ngưỡng kích hoạt.',
                      style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
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
                            '${_metric.thresholdLabel}: ${_threshold.toStringAsFixed(_metric.step < 1 ? 1 : 0)} ${_metric.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _onSurface,
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
                      value: _threshold.clamp(
                        _metric.minThreshold,
                        _metric.maxThreshold,
                      ),
                      min: _metric.minThreshold,
                      max: _metric.maxThreshold,
                      divisions:
                          ((_metric.maxThreshold - _metric.minThreshold) / _metric.step)
                              .round(),
                      label:
                          '${_threshold.toStringAsFixed(_metric.step < 1 ? 1 : 0)} ${_metric.unit}',
                      onChanged: (value) => setState(() => _threshold = value),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_metric.minThreshold.toStringAsFixed(_metric.step < 1 ? 1 : 0)} ${_metric.unit}',
                          style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
                        ),
                        const Spacer(),
                        Text(
                          '${_metric.maxThreshold.toStringAsFixed(_metric.step < 1 ? 1 : 0)} ${_metric.unit}',
                          style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
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
                            style: FilledButton.styleFrom(backgroundColor: _primary),
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
      threshold: _threshold,
      enabled: _enabled,
    );
    Navigator.of(context).pop(alert);
  }
}

class _EmptyAlertsState extends StatelessWidget {
  const _EmptyAlertsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_none_outlined, size: 56, color: _primary),
          SizedBox(height: 16),
          Text(
            'Chưa có cảnh báo nào',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tạo các quy tắc như mưa lớn, rét đậm hoặc UV cao để nhận cảnh báo kịp thời.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
          ),
        ],
      ),
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
