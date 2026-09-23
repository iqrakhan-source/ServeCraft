import '../../data/models/send_otp_response.dart';
import '../../data/models/user_model.dart';
import '../../data/models/verify_otp_response.dart';

abstract class AuthRepository {
  Future<SendOtpResponse> sendOtp(String phone);
  Future<VerifyOtpResponse> verifyOtp(String phone, String otp);
  Future<UserModel> completeProfile({
    required String name,
    String? email,
    String? profileImage,
  });
  Future<UserModel?> checkAuthSession();
  Future<UserModel?> getCachedUser();
  Future<void> logout();
}
