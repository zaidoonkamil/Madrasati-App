import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/show_toast.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class AddAdmin extends StatelessWidget {
  const AddAdmin({super.key});

  static GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static TextEditingController userNameController = TextEditingController();
  static TextEditingController phoneController = TextEditingController();
  static TextEditingController locationController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController rePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AdminCubit(),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is SignUpSuccessState) {
            userNameController.text = '';
            phoneController.text = '';
            locationController.text = '';
            passwordController.text = '';
            rePasswordController.text = '';
            showToastSuccess(text: "تم انشاء الحساب بنجاح", context: context);
          }
        },
        builder: (context, state) {
          var cubit = AdminCubit.get(context);
          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appPageColor(context),
              body: Column(
                children: [
                  const CustomAppBarBack(
                    title: 'إضافة أدمن',
                    subtitle: 'إنشاء حساب إداري جديد',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              CustomTextField(
                                hintText: 'الاسم الثلاثي',
                                prefixIcon: Icons.person_outline,
                                controller: userNameController,
                                validate: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'رجائا اخل الاسم الثلاثي';
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  CustomTextField(
                                    controller: phoneController,
                                    hintText: 'رقم الهاتف',
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'رجائا اخل رقم الهاتف';
                                      }
                                    },
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    height: 48,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: secondPrimaryColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '+964',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: locationController,
                                hintText: 'الموقع',
                                prefixIcon: Icons.location_on_outlined,
                                validate: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'رجائا اخل الرمز السري';
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: passwordController,
                                hintText: 'كلمة السر',
                                prefixIcon: Icons.lock,
                                obscureText: cubit.isPasswordHidden,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    cubit.togglePasswordVisibility();
                                  },
                                  child: Icon(
                                    cubit.isPasswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                ),
                                validate: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'رجائا اخل الرمز السري';
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: rePasswordController,
                                hintText: 'اعد كتابة كلمة السر',
                                prefixIcon: Icons.lock,
                                obscureText: cubit.isPasswordHidden2,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    cubit.togglePasswordVisibility2();
                                  },
                                  child: Icon(
                                    cubit.isPasswordHidden2
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                ),
                                validate: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'رجائا اعد ادخال الرمز السري';
                                  }
                                },
                              ),
                              const SizedBox(height: 60),
                              ConditionalBuilder(
                                condition: state is! SignUpLoadingState,
                                builder: (c) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        if (passwordController.text ==
                                            rePasswordController.text) {
                                          cubit.signUp(
                                            name:
                                                userNameController.text.trim(),
                                            phone: phoneController.text.trim(),
                                            location:
                                                locationController.text.trim(),
                                            password:
                                                passwordController.text.trim(),
                                            role: 'admin',
                                            context: context,
                                          );
                                        } else {
                                          showToastError(
                                            text: "كلمة السر غير متطابقة",
                                            context: context,
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                            offset: const Offset(5, 5),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(12),
                                        color: secondPrimaryColor,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(width: 50),
                                          Text(
                                            'اضافة ادمن',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(6),
                                            height: double.maxFinite,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 22,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                fallback:
                                    (c) => CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
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
