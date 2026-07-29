import '../../data/repositories/location_repository.dart';

class SetDefaultLocationUseCase {
  SetDefaultLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<void> call(int id) {
    return _repository.setDefault(id);
  }
}
