import '../repositories/pin_repository.dart';

class VerifyPinUseCase {
  final PinRepository repository;

  VerifyPinUseCase(this.repository);

  Future<bool> call(String pin) => repository.verifyPin(pin);
}
