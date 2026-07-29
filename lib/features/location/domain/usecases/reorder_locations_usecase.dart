import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';

class ReorderLocationsUseCase {
  ReorderLocationsUseCase(this._repository);

  final LocationRepository _repository;

  Future<void> call(List<LocationModel> locations) {
    return _repository.reorder(locations);
  }
}
