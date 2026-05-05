import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madrasati_app/core/styles/themes.dart';
import 'package:madrasati_app/core/widgets/custom_text_field.dart';
import 'package:madrasati_app/core/widgets/show_toast.dart';
import 'package:madrasati_app/features/auth/view/login.dart';

import '../../../core/ navigation/navigation.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'widgets/auth_shell_widgets.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key, required this.phone});

  final String phone;
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final TextEditingController codeController = TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();
  static final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          if (state is ResetPasswordSuccessState) {
            showToastSuccess(
              text: 'تم تغيير كلمة المرور بنجاح',
              context: context,
            );
            navigateAndFinish(context, const Login());
          }
        },
        builder: (context, state) {
          final cubit = LoginCubit.get(context);
          return AuthScaffold(
            showBack: true,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeroCard(
                    icon: Icons.key_rounded,
                    title: 'إعادة تعيين كلمة المرور',
                    subtitle:
                        'أدخل رمز واتساب وكلمة المرور الجديدة لإكمال العملية وحماية حسابك.',
                  ),
                  const SizedBox(height: 14),
                  AuthInfoStrip(
                    icon: Icons.phone_iphone_rounded,
                    text: 'رقم التحقق الحالي: $phone',
                  ),
                  const SizedBox(height: 16),
                  AuthPanel(
                    children: [
                      CustomTextField(
                        controller: codeController,
                        hintText: 'كود OTP',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.pin_rounded,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أدخل كود OTP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'كلمة المرور الجديدة',
                        obscureText: cubit.isPasswordHidden,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: cubit.togglePasswordVisibility,
                          icon: Icon(
                            cubit.isPasswordHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: appTextMutedColor,
                            size: 20,
                          ),
                        ),
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أدخل كلمة المرور الجديدة';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: confirmPasswordController,
                        hintText: 'تأكيد كلمة المرور الجديدة',
                        obscureText: cubit.isPasswordHidden2,
                        prefixIcon: Icons.verified_user_outlined,
                        suffixIcon: IconButton(
                          onPressed: cubit.togglePasswordVisibility2,
                          icon: Icon(
                            cubit.isPasswordHidden2
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: appTextMutedColor,
                            size: 20,
                          ),
                        ),
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أكد كلمة المرور الجديدة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed:
                              state is SendOtpLoadingState
                                  ? null
                                  : () {
                                    cubit.sendOtp(
                                      phone: phone,
                                      purpose: 'password_reset',
                                      context: context,
                                    );
                                  },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: primaryColor,
                            size: 18,
                          ),
                          label: const Text(
                            'إعادة إرسال الكود',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConditionalBuilder(
                        condition: state is! ResetPasswordLoadingState,
                        builder: (_) {
                          return AuthPrimaryButton(
                            title: 'تغيير كلمة المرور',
                            icon: Icons.lock_reset_rounded,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                if (passwordController.text.trim() !=
                                    confirmPasswordController.text.trim()) {
                                  showToastError(
                                    text: 'كلمتا المرور غير متطابقتين',
                                    context: context,
                                  );
                                  return;
                                }

                                cubit.resetPassword(
                                  phone: phone,
                                  code: codeController.text.trim(),
                                  password: passwordController.text.trim(),
                                  context: context,
                                );
                              }
                            },
                          );
                        },
                        fallback:
                            (_) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
