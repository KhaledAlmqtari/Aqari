import '../repositories/pin_repository.dart';

class HasPinUseCase {
  final PinRepository repository;

  HasPinUseCase(this.repository);

  Future<bool> call() => repository.hasPin();
}
