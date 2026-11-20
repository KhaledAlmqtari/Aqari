import '../../domain/repositories/pin_repository.dart';
import '../datasources/pin_local_datasource.dart';

class PinRepositoryImpl implements PinRepository {
  final PinLocalDataSource dataSource;

  PinRepositoryImpl(this.dataSource);

  @override
  Future<bool> hasPin() => dataSource.hasPin();

  @override
  Future<void> createPin(String pin) => dataSource.createPin(pin);

  @override
  Future<bool> verifyPin(String pin) => dataSource.verifyPin(pin);
}
