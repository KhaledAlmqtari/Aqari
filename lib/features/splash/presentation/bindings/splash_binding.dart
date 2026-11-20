import 'package:get/get.dart';
import '../../../pin/data/datasources/pin_local_datasource.dart';
import '../../../pin/data/repositories/pin_repository_impl.dart';
import '../../../pin/domain/repositories/pin_repository.dart';
import '../../../pin/domain/usecases/has_pin_usecase.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // التأكد من تسجيل الـ LocalDataSource إذا لم تكن مسجلة مسبقاً
    if (!Get.isRegistered<PinLocalDataSource>()) {
      Get.lazyPut(() => PinLocalDataSource(Get.find()), fenix: true);
    }

    // التأكد من تسجيل الـ Repository إذا لم تكن مسجلة مسبقاً
    if (!Get.isRegistered<PinRepository>()) {
      Get.lazyPut<PinRepository>(
        () => PinRepositoryImpl(Get.find()),
        fenix: true,
      );
    }

    // تسجيل الـ UseCase بشكل فوري وثابت لتجنب أي تأخير
    if (!Get.isRegistered<HasPinUseCase>()) {
      Get.put<HasPinUseCase>(
        HasPinUseCase(Get.find<PinRepository>()),
        permanent: true,
      );
    }

    // تسجيل الـ SplashController بشكل فوري لضمان عمل المؤقت والـ onReady بدون أي تأخير
    if (!Get.isRegistered<SplashController>()) {
      Get.put<SplashController>(
        SplashController(Get.find<HasPinUseCase>()),
        permanent: true,
      );
    }
  }
}
