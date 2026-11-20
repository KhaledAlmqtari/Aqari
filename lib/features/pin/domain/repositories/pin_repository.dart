abstract class PinRepository {
  Future<bool> hasPin();
  Future<void> createPin(String pin);
  Future<bool> verifyPin(String pin);
}
