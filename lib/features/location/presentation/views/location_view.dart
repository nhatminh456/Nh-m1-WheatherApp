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
  // initState là constructor, chỉ chạy 1 lần
  void initState() {
    super.initState();
    widget.viewModel.loadLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        // canh giữa tiêu đề
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      // quy định vị trí nằm bên phải
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'location_add_fab',
            onPressed: _showAddDialog,
            tooltip: 'Thêm thành phố',
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListenableBuilder(
        // khi viewmodel gọi notify tự rebuild lại UI
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
          // check xem có lỗi không nếu có hiển thị ra chính giữa *
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
          // nếu không có thêm gì hết thì hiển thị
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
            // cho phép mình kéo thả để sắp xếp lại danh sách các City
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false, // muốn kéo thả thì để là false
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: items.length, // đếm coi có bao nhiêu city
              onReorderItem: (oldIndex, newIndex) async {
                await _onReorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = items[index];
                final location = item.location;
                final weather = item.weather;

                return Card(
                  // đại diện cho 1 city
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
                        switch (value) {
                          case 'default':
                            if (location.id != null) {
                              await widget.viewModel.setDefault(location.id!);
                            }
                            break;

                          case 'edit':
                            await _showEditDialog(location);
                            break;

                          case 'delete':
                            if (location.id != null) {
                              await _deleteLocation(location.id!);
                            }
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        return <PopupMenuEntry<String>>[
                          if (!location.isDefault)
                            const PopupMenuItem<String>(
                              value: 'default',
                              child: Text('Đặt làm mặc định'),
                            ),
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Sửa tên hiển thị'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Xóa'),
                          ),
                        ];
                      },
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
    // -1 là vì khi kéo vào index mới thì nó sẽ đẩy cái cũ xuống 1 bậc nên phải
    //trừ đi 1
    if (oldIndex < newIndex) newIndex -= 1;
    final moved = locations.removeAt(oldIndex);
    locations.insert(newIndex, moved);
    final reordered = [
      for (var i = 0; i < locations.length; i++)
        locations[i].copyWith(sortOrder: i),
    ];
    await widget.viewModel.reorderLocations(reordered);
  }

  //
  Future<void> _showAddDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // nâng cao UX
      builder: (dialogContext) {
        return _LocationEditorDialog(
          viewModel: widget.viewModel, // truyền viewmodel lấy data
          onSave: (location) => widget.viewModel.addLocation(location),
        );
      },
    );
  }

  //
  Future<void> _showEditDialog(LocationModel location) async {
    var newName = location.displayName;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Sửa ${location.name}'),
          content: TextFormField(
            initialValue: location.displayName,
            decoration: const InputDecoration(
              labelText: 'Tên hiển thị',
              hintText: 'VD: Nhà',
            ),
            onChanged: (v) => newName = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final trimmed = newName.trim();

                // Close dialog first to avoid lifecycle races
                if (!navigator.mounted) return;
                navigator.pop();

                await widget.viewModel.updateLocation(
                  location.copyWith(displayName: trimmed),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
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
          mainAxisSize: MainAxisSize.min, // tránh bị tràn màn hình
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
                  signed: true, // cho nhap so am
                  decimal: true, // cho nhap so thap phan
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
                      // bắt lỗi GPS nếu ko mở
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
            final navigator = Navigator.of(
              context,
            ); // tránh xung đột khi rebuild UI
            final saveFn = widget.onSave;
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

              // Close dialog first to avoid rebuild/dispose race, then perform save.
              if (!navigator.mounted) return;
              navigator.pop();

              await saveFn(
                LocationModel(
                  name: resolvedName,
                  displayName: alias,
                  latitude: latitude,
                  longitude: longitude,
                ),
              );
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
