import 'package:get/get.dart';
import '../../data/datasources/pin_local_datasource.dart';
import '../../data/repositories/pin_repository_impl.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/usecases/create_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import '../../presentation/controllers/pin_controller.dart';

class PinBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PinLocalDataSource>()) {
      Get.lazyPut<PinLocalDataSource>(
        () => PinLocalDataSource(Get.find()),
      );
    }

    if (!Get.isRegistered<PinRepository>()) {
      Get.lazyPut<PinRepository>(
        () => PinRepositoryImpl(Get.find()),
      );
    }

    Get.lazyPut(() => CreatePinUseCase(Get.find()));
    Get.lazyPut(() => VerifyPinUseCase(Get.find()));
    Get.lazyPut(() => PinController(
          Get.find(),
          Get.find(),
        ));
  }
}
