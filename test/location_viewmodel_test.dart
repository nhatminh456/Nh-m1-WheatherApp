import 'package:flutter_test/flutter_test.dart';
import 'package:weatherapp/features/location/data/models/location_model.dart';
import 'package:weatherapp/features/location/data/repositories/location_repository.dart';
import 'package:weatherapp/features/location/presentation/viewmodels/location_viewmodel.dart';

class FakeLocationRepository extends LocationRepository {
  final List<LocationModel> _items = [];

  @override
  Future<List<LocationModel>> getAll() async => List.unmodifiable(_items);

  @override
  Future<int> add(LocationModel location) async {
    _items.add(location);
    return _items.length;
  }

  @override
  Future<int> update(LocationModel location) async {
    final index = _items.indexWhere((item) => item.id == location.id);
    if (index >= 0) {
      _items[index] = location;
    }
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    _items.removeWhere((item) => item.id == id);
    return 1;
  }

  @override
  Future<void> reorder(List<LocationModel> locations) async {
    _items
      ..clear()
      ..addAll(locations);
  }
}

void main() {
  group('LocationViewModel', () {
    test('addLocation loads the new location into the list', () async {
      final repository = FakeLocationRepository();
      final viewModel = LocationViewModel(repository);

      await viewModel.addLocation(
        const LocationModel(name: 'Home', latitude: 1.2, longitude: 2.3),
      );

      expect(viewModel.locations, hasLength(1));
      expect(viewModel.locations.first.name, 'Home');
      expect(viewModel.status, LocationStatus.success);
    });
  });
}
