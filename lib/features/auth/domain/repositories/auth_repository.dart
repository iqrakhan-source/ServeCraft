import '../../data/models/register_customer_request.dart';
import '../../data/models/register_customer_response.dart';
import '../../data/models/send_otp_response.dart';
import '../../data/models/user_model.dart';
import '../../data/models/verify_otp_response.dart';

abstract class AuthRepository {
  Future<RegisterCustomerResponse> registerCustomer(
      RegisterCustomerRequest request,
      );
  Future<SendOtpResponse> sendOtp(String phone);
  Future<SendOtpResponse> sendSignupOtp(String email);
  Future<VerifyOtpResponse> verifyOtp(String phone, String otp);
  Future<UserModel> completeProfile({
    required String name,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? profileImage,
  });
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<UserModel> updateClinicalPreferences(Map<String, dynamic> preferences);
  Future<UserModel?> checkAuthSession();
  Future<UserModel?> getCachedUser();
  Future<void> logout();
}
