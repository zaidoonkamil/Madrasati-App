import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madrasati_app/core/styles/themes.dart';
import 'package:madrasati_app/core/widgets/custom_text_field.dart';
import 'package:madrasati_app/core/widgets/show_toast.dart';
import 'package:madrasati_app/features/auth/view/login.dart';
import 'package:madrasati_app/features/auth/view/loginCode.dart';

import '../../../core/ navigation/navigation.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'widgets/auth_shell_widgets.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final TextEditingController userNameController =
      TextEditingController();
  static final TextEditingController phoneController = TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();
  static final TextEditingController rePasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          final cubit = LoginCubit.get(context);
          if (state is SignUpSuccessState) {
            userNameController.clear();
            phoneController.clear();
            passwordController.clear();
            rePasswordController.clear();
            showToastSuccess(
              text: 'تم إنشاء الحساب، أدخل رمز التفعيل المرسل عبر واتساب',
              context: context,
            );
            navigateAndFinish(
              context,
              LoginCode(phone: cubit.phonee ?? cubit.pendingPhone ?? ''),
            );
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
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'حساب جديد',
                    subtitle:
                        'سجل بياناتك حتى تقدر تطلب وتتابع مشترياتك من داخل التطبيق.',
                  ),
                  const SizedBox(height: 16),
                  AuthPanel(
                    children: [
                      CustomTextField(
                        hintText: 'الاسم الثلاثي',
                        controller: userNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validate: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أدخل الاسم الثلاثي';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Stack(
                        children: [
                          CustomTextField(
                            controller: phoneController,
                            hintText: 'رقم الهاتف',
                            keyboardType: TextInputType.phone,
                            validate: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'رجاءً أدخل رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          PositionedDirectional(
                            start: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 76,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: appAccentColor,
                                borderRadius: BorderRadiusDirectional.only(
                                  topStart: Radius.circular(16),
                                  bottomStart: Radius.circular(16),
                                ),
                              ),
                              child: const Text(
                                '+964',
                                style: TextStyle(
                                  color: appTextPrimaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'كلمة المرور',
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
                        validate: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أدخل كلمة المرور';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: rePasswordController,
                        hintText: 'أعد كتابة كلمة المرور',
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
                        validate: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أعد إدخال كلمة المرور';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      ConditionalBuilder(
                        condition: state is! SignUpLoadingState,
                        builder: (c) {
                          return AuthPrimaryButton(
                            title: 'إنشاء الحساب',
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                if (passwordController.text ==
                                    rePasswordController.text) {
                                  cubit.signUp(
                                    name: userNameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    location: 'البصرة',
                                    password: passwordController.text.trim(),
                                    role: 'user',
                                    context: context,
                                  );
                                } else {
                                  showToastError(
                                    text: 'كلمة المرور غير متطابقة',
                                    context: context,
                                  );
                                }
                              }
                            },
                          );
                        },
                        fallback:
                            (c) => const Padding(
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
                  const SizedBox(height: 18),
                  AuthSecondaryAction(
                    label: 'أمتلك حساب؟ ',
                    actionText: 'تسجيل الدخول',
                    onTap: () {
                      navigateAndFinish(context, const Login());
                    },
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
