import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madrasati_app/core/navigation_bar/navigation_bar.dart';
import 'package:madrasati_app/core/navigation_bar/navigation_bar_Admin.dart';
import 'package:madrasati_app/core/network/local/cache_helper.dart';
import 'package:madrasati_app/core/styles/themes.dart';
import 'package:madrasati_app/core/widgets/constant.dart';
import 'package:madrasati_app/core/widgets/custom_text_field.dart';
import 'package:madrasati_app/core/widgets/show_toast.dart';
import 'package:madrasati_app/features/auth/view/forgot_password.dart';
import 'package:madrasati_app/features/auth/view/loginCode.dart';
import 'package:madrasati_app/features/auth/view/register.dart';

import '../../../core/ navigation/navigation.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'widgets/auth_shell_widgets.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final TextEditingController userNameController =
      TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          final cubit = LoginCubit.get(context);

          if (state is LoginSuccessState) {
            CacheHelper.saveData(key: 'token', value: cubit.token).then((
              value,
            ) {
              CacheHelper.saveData(key: 'id', value: cubit.id).then((value) {
                CacheHelper.saveData(key: 'role', value: cubit.role).then((
                  value,
                ) {
                  token = cubit.token.toString();
                  id = cubit.id.toString();
                  adminOrUser = cubit.role.toString();

                  cubit.registerDevice(cubit.id.toString());

                  if (adminOrUser == 'admin') {
                    navigateAndFinish(context, BottomNavBarAdmin());
                  } else {
                    navigateAndFinish(context, BottomNavBar());
                  }
                });
              });
            });
          }

          if (state is AccountNotVerifiedState) {
            showToastError(
              text: 'الحساب غير مفعل بعد، تم تحويلك إلى صفحة التفعيل',
              context: context,
            );
            navigateTo(
              context,
              LoginCode(phone: cubit.phonee ?? userNameController.text.trim()),
            );
          }
        },
        builder: (context, state) {
          final cubit = LoginCubit.get(context);
          return AuthScaffold(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  AuthLogoMark(assetName: logo),
                  const SizedBox(height: 18),
                  const AuthHeroCard(
                    icon: Icons.login_rounded,
                    title: 'تسجيل الدخول',
                    subtitle:
                        'أدخل رقم الهاتف وكلمة المرور حتى ترجع لحسابك وتكمل طلباتك بسهولة.',
                  ),
                  const SizedBox(height: 16),
                  AuthPanel(
                    children: [
                      CustomTextField(
                        hintText: 'رقم الهاتف',
                        controller: userNameController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_iphone_rounded,
                        validate: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أدخل رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: 'كلمة المرور',
                        controller: passwordController,
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
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            navigateTo(context, const ForgotPassword());
                          },
                          child: const Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConditionalBuilder(
                        condition: state is! LoginLoadingState,
                        builder: (c) {
                          return AuthPrimaryButton(
                            title: 'تسجيل الدخول',
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                cubit.signIn(
                                  phone: userNameController.text.trim(),
                                  password: passwordController.text.trim(),
                                  context: context,
                                );
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
                    label: 'لا تمتلك حساب؟ ',
                    actionText: 'إنشاء حساب',
                    onTap: () {
                      navigateTo(context, const Register());
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
