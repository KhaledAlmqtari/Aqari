import 'dart:async';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../pin/domain/usecases/has_pin_usecase.dart';

class SplashController extends GetxController {
  final HasPinUseCase hasPin;

  SplashController(this.hasPin);

  @override
  void onReady() {
    super.onReady();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    // الانتظار لمدة 3 ثوانٍ بالضبط
    Timer(const Duration(seconds: 3), () async {
      bool exists = false;

      try {
        exists = await hasPin().timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => false,
        );
      } catch (_) {
        exists = false;
      }

      // التوجيه الإجباري والمضمون إلى شاشة الـ PIN
      if (exists) {
        Get.offAllNamed(
          AppRoutes.pin,
          arguments: {'mode': 'verify'},
        );
      } else {
        Get.offAllNamed(
          AppRoutes.pin,
          arguments: {'mode': 'create'},
        );
      }
    });
  }
}
