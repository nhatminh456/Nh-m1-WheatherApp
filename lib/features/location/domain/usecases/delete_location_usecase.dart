import '../../data/repositories/location_repository.dart';

class DeleteLocationUseCase {
  DeleteLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<int> call(int id) {
    return _repository.delete(id);
  }
}
