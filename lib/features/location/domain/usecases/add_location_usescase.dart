import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';

class AddLocationUseCase {
  AddLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<int> call(LocationModel location) {
    return _repository.add(location);
  }
}
