import 'package:madrasati_app/features/auth/cubit/states.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/show_toast.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  void validation() {
    emit(ValidationState());
  }

  bool isPasswordHidden = true;
  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    emit(PasswordVisibilityChanged());
  }

  bool isPasswordHidden2 = true;
  void togglePasswordVisibility2() {
    isPasswordHidden2 = !isPasswordHidden2;
    emit(PasswordVisibilityChanged());
  }

  Future<void> registerDevice(String userId) async {
    final playerId = OneSignal.User.pushSubscription.id;

    if (playerId != null) {
      try {
        final response = await DioHelper.postData(
          url: "/register-device",
          data: {"user_id": userId, "player_id": playerId},
        );

        if (response.statusCode == 200) {
          print("Device registered successfully");
        } else {
          print("Device registration failed: ${response.statusMessage}");
        }
      } catch (error) {
        print("Device registration error: $error");
      }
    } else {
      print("OneSignal player_id is not available");
    }
  }

  String normalizePhone(String phone) {
    phone = phone.trim();

    if (phone.startsWith('964') && phone.length == 13) {
      return phone;
    } else if (phone.startsWith('0') && phone.length == 11) {
      return '964${phone.substring(1)}';
    } else if (phone.length == 10) {
      return '964$phone';
    } else {
      return phone;
    }
  }

  String? token;
  String? role;
  String? id;
  String? phonee;
  String? pendingPhone;
  bool? isVerified;

  void signUp({
    required String name,
    required String phone,
    required String password,
    required String location,
    required String role,
    required BuildContext context,
  }) {
    phone = normalizePhone(phone);
    pendingPhone = phone;
    emit(SignUpLoadingState());
    DioHelper.postData(
          url: '/users',
          data: {
            'name': name,
            'phone': phone,
            'role': role,
            'location': location,
            'password': password,
          },
        )
        .then((value) {
          phonee = value.data['phone']?.toString() ?? phone;
          isVerified = value.data['isVerified'] == true;
          emit(SignUpSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text:
                  error.response?.data["error"] ?? "حدث خطأ أثناء إنشاء الحساب",
              context: context,
            );
            emit(SignUpErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void signIn({
    required String phone,
    required String password,
    required BuildContext context,
  }) {
    phone = normalizePhone(phone);
    phonee = phone;
    emit(LoginLoadingState());
    DioHelper.postData(
          url: '/login',
          data: {'phone': phone, 'password': password},
        )
        .then((value) {
          token = value.data['token'];
          role = value.data['user']['role'];
          id = value.data['user']['id'].toString();
          phonee = value.data['user']['phone'].toString();
          isVerified = value.data['user']['isVerified'];
          emit(LoginSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            if (error.response?.statusCode == 403 &&
                error.response?.data?['code'] == 'ACCOUNT_NOT_VERIFIED') {
              phonee = error.response?.data?['phone']?.toString() ?? phone;
              isVerified = false;
              emit(AccountNotVerifiedState());
              return;
            }

            showToastError(
              text:
                  error.response?.data["error"] ?? "حدث خطأ أثناء تسجيل الدخول",
              context: context,
            );
            emit(LoginErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void sendOtp({
    required String phone,
    required BuildContext context,
    String purpose = 'activation',
  }) {
    phone = normalizePhone(phone);
    emit(SendOtpLoadingState());
    DioHelper.postData(
          url: '/send-otp',
          data: {'phone': phone, 'purpose': purpose},
        )
        .then((value) {
          emit(SendOtpSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: error.response?.data["error"] ?? "حدث خطأ غير معروف",
              context: context,
            );
            emit(SendOtpErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void verifyOtp({
    required String phone,
    required String code,
    required BuildContext context,
    String purpose = 'activation',
  }) {
    phone = normalizePhone(phone);
    emit(VerifyOtpLoadingState());
    DioHelper.postData(
          url: '/verify-otp',
          data: {'phone': phone, 'code': code, 'purpose': purpose},
        )
        .then((value) {
          emit(VerifyOtpSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: error.response?.data["error"] ?? "حدث خطأ غير معروف",
              context: context,
            );
            emit(VerifyOtpErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void forgotPasswordRequest({
    required String phone,
    required BuildContext context,
  }) {
    phone = normalizePhone(phone);
    pendingPhone = phone;
    emit(ForgotPasswordRequestLoadingState());
    DioHelper.postData(url: '/forgot-password/request', data: {'phone': phone})
        .then((value) {
          phonee = value.data['phone']?.toString() ?? phone;
          emit(ForgotPasswordRequestSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text:
                  error.response?.data["error"] ?? "حدث خطأ أثناء إرسال الكود",
              context: context,
            );
            print(error.response?.data["error"]);
            emit(ForgotPasswordRequestErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void resetPassword({
    required String phone,
    required String code,
    required String password,
    required BuildContext context,
  }) {
    phone = normalizePhone(phone);
    emit(ResetPasswordLoadingState());
    DioHelper.postData(
          url: '/forgot-password/reset',
          data: {'phone': phone, 'code': code, 'password': password},
        )
        .then((value) {
          emit(ResetPasswordSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text:
                  error.response?.data["error"] ??
                  "حدث خطأ أثناء إعادة التعيين",
              context: context,
            );
            emit(ResetPasswordErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }
}
