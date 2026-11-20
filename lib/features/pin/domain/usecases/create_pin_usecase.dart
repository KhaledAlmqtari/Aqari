import '../repositories/pin_repository.dart';

class CreatePinUseCase {
  final PinRepository repository;

  CreatePinUseCase(this.repository);

  Future<void> call(String pin) => repository.createPin(pin);
}
