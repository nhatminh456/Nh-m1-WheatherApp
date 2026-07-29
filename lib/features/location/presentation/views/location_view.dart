import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/location_model.dart';
import '../../data/services/location_service.dart';
import '../viewmodels/location_viewmodel.dart';

class LocationView extends StatefulWidget {
  const LocationView({super.key, required this.viewModel});

  final LocationViewModel viewModel;

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'location_home_fab',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('Home'),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'location_add_fab',
            onPressed: _showAddDialog,
            tooltip: 'Thêm thành phố',
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final status = widget.viewModel.status;
          final items = widget.viewModel.items;
          final isLoading =
              status == LocationStatus.initial ||
              status == LocationStatus.loading;

          if (isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (status == LocationStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.viewModel.errorMessage ?? 'Có lỗi xảy ra',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (status == LocationStatus.success && items.isEmpty) {
            return RefreshIndicator(
              onRefresh: widget.viewModel.loadLocations,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  const Icon(Icons.location_city, size: 72),
                  const SizedBox(height: 16),
                  const Center(child: Text('Chưa có thành phố nào')),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm thành phố'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: widget.viewModel.loadLocations,
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: items.length,
              onReorderItem: (oldIndex, newIndex) async {
                await _onReorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = items[index];
                final location = item.location;
                final weather = item.weather;

                return Card(
                  key: ValueKey(location.id ?? index),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    onTap: () async {
                      await context.push('/weather', extra: location);
                      await widget.viewModel.loadLocations();
                    },
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: CircleAvatar(
                        child: Icon(
                          location.isDefault ? Icons.star : Icons.place,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(location.title)),
                        if (location.isDefault)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Chip(label: Text('Mặc định')),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      weather == null
                          ? '${location.name} • đang cập nhật nhiệt độ'
                          : '${location.name} • ${weather.temperatureCelsius.toStringAsFixed(1)}°C • ${weather.description}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _showEditDialog(location);
                        } else if (value == 'delete' && location.id != null) {
                          await _deleteLocation(location.id!);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Sửa tên hiển thị'),
                        ),
                        PopupMenuItem(value: 'delete', child: Text('Xóa')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final locations = [...widget.viewModel.items.map((e) => e.location)];
    if (oldIndex < newIndex) newIndex -= 1;
    final moved = locations.removeAt(oldIndex);
    locations.insert(newIndex, moved);
    final reordered = [
      for (var i = 0; i < locations.length; i++)
        locations[i].copyWith(sortOrder: i),
    ];
    await widget.viewModel.reorderLocations(reordered);
  }

  Future<void> _showAddDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _LocationEditorDialog(
          viewModel: widget.viewModel,
          onSave: (location) => widget.viewModel.addLocation(location),
        );
      },
    );
  }

  Future<void> _showEditDialog(LocationModel location) async {
    final aliasController = TextEditingController(text: location.displayName);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Sửa ${location.name}'),
          content: TextField(
            controller: aliasController,
            decoration: const InputDecoration(
              labelText: 'Tên hiển thị',
              hintText: 'VD: Nhà',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                await widget.viewModel.updateLocation(
                  location.copyWith(displayName: aliasController.text.trim()),
                );
                if (!mounted) return;
                navigator.pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    aliasController.dispose();
  }

  Future<void> _deleteLocation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa thành phố'),
        content: const Text('Bạn có chắc muốn xóa thành phố này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.viewModel.deleteLocation(id);
    }
  }
}

class _LocationEditorDialog extends StatefulWidget {
  const _LocationEditorDialog({required this.viewModel, required this.onSave});

  final LocationViewModel viewModel;
  final Future<void> Function(LocationModel location) onSave;

  @override
  State<_LocationEditorDialog> createState() => _LocationEditorDialogState();
}

class _LocationEditorDialogState extends State<_LocationEditorDialog> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool _useManualCoordinates = false;

  @override
  void dispose() {
    _cityController.dispose();
    _aliasController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm thành phố'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _cityController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                labelText: 'Tên thành phố',
                hintText: 'VD: Đà Nẵng',
              ),
            ),
            TextField(
              controller: _aliasController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị (tuỳ chọn)',
                hintText: 'VD: Nhà',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _useManualCoordinates,
              title: const Text('Nhập kinh độ / vĩ độ thủ công'),
              onChanged: (value) {
                setState(() => _useManualCoordinates = value);
              },
            ),
            if (_useManualCoordinates) ...[
              TextField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Vĩ độ',
                  hintText: 'VD: 16.0544',
                ),
              ),
              TextField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Kinh độ',
                  hintText: 'VD: 108.2022',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final position = await widget.viewModel
                          .getCurrentPosition();
                      _latitudeController.text = position.latitude.toString();
                      _longitudeController.text = position.longitude.toString();
                    } on LocationServiceException catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Lấy vị trí hiện tại'),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);
            final cityName = _cityController.text.trim();
            final alias = _aliasController.text.trim();
            if (cityName.isEmpty) return;

            try {
              double latitude;
              double longitude;
              String resolvedName = cityName;

              if (_useManualCoordinates) {
                latitude =
                    double.tryParse(_latitudeController.text.trim()) ?? 0;
                longitude =
                    double.tryParse(_longitudeController.text.trim()) ?? 0;
              } else {
                final resolved = await widget.viewModel.searchCity(cityName);
                resolvedName = resolved.cityName;
                latitude = resolved.latitude;
                longitude = resolved.longitude;
              }

              if (latitude == 0 && longitude == 0) {
                throw const LocationServiceException(
                  'Vui lòng nhập đúng vĩ độ và kinh độ.',
                );
              }

              await widget.onSave(
                LocationModel(
                  name: resolvedName,
                  displayName: alias,
                  latitude: latitude,
                  longitude: longitude,
                ),
              );

              if (!mounted) return;
              navigator.pop();
            } on LocationServiceException catch (e) {
              if (!mounted) return;
              messenger.showSnackBar(SnackBar(content: Text(e.message)));
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
