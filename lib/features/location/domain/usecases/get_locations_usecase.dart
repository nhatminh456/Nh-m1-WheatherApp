import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';

class GetLocationsUseCase {
  GetLocationsUseCase(this._repository);

  final LocationRepository _repository;

  Future<List<LocationModel>> call() {
    return _repository.getAll();
  }
}
