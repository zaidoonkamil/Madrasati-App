import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madrasati_app/core/styles/themes.dart';
import 'package:madrasati_app/core/widgets/custom_text_field.dart';
import 'package:madrasati_app/features/auth/view/reset_password.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'widgets/auth_shell_widgets.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          final cubit = LoginCubit.get(context);
          if (state is ForgotPasswordRequestSuccessState) {
            showToastSuccess(
              text: 'تم إرسال رمز إعادة التعيين إلى واتساب',
              context: context,
            );
            navigateTo(
              context,
              ResetPassword(phone: cubit.phonee ?? cubit.pendingPhone ?? ''),
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
                    icon: Icons.lock_reset_rounded,
                    title: 'نسيت كلمة المرور',
                    subtitle:
                        'أدخل رقم هاتفك وسنرسل لك رمز تحقق عبر واتساب لإعادة تعيين كلمة المرور بشكل آمن.',
                  ),
                  const SizedBox(height: 14),
                  const AuthInfoStrip(
                    icon: Icons.verified_user_outlined,
                    text: 'سيصلك الكود على واتساب خلال لحظات',
                  ),
                  const SizedBox(height: 16),
                  AuthPanel(
                    children: [
                      CustomTextField(
                        controller: phoneController,
                        hintText: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_iphone_rounded,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رجاءً أدخل رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      ConditionalBuilder(
                        condition: state is! ForgotPasswordRequestLoadingState,
                        builder: (_) {
                          return AuthPrimaryButton(
                            title: 'إرسال الكود',
                            icon: Icons.send_rounded,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                cubit.forgotPasswordRequest(
                                  phone: phoneController.text.trim(),
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
