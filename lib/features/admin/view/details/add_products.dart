import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:iconsax/iconsax.dart';
import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/show_toast.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class AddProducts extends StatelessWidget {
  const AddProducts({super.key});

  static GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static TextEditingController tittleController = TextEditingController();
  static TextEditingController descController = TextEditingController();
  static TextEditingController priceController = TextEditingController();
  static TextEditingController stockController = TextEditingController();
  static TextEditingController colorsController = TextEditingController();
  static TextEditingController sizesController = TextEditingController();
  static TextEditingController categoryIdController = TextEditingController();
  static TextEditingController subcategoryNameController =
      TextEditingController();
  static TextEditingController mainCategoryIdController =
      TextEditingController();
  static TextEditingController mainCategoryNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AdminCubit()..getCat(context: context),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is AddProductsSuccessState) {
            AdminCubit.get(context).selectedImages = [];
            tittleController.clear();
            descController.clear();
            priceController.clear();
            stockController.clear();
            colorsController.clear();
            sizesController.clear();
            categoryIdController.clear();
            subcategoryNameController.clear();
            mainCategoryIdController.clear();
            mainCategoryNameController.clear();
            showToastSuccess(text: "تمت العملية بنجاح", context: context);
          }
        },
        builder: (context, state) {
          final cubit = AdminCubit.get(context);
          return SafeArea(
            top: false,
            child: Scaffold(
              body: Column(
                children: [
                  const CustomAppBarBack(
                    title: 'إضافة منتج',
                    subtitle: 'اختر القسم الرئيسي ثم الفرعي قبل إضافة المنتج',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: cubit.pickImages,
                                child:
                                    cubit.selectedImages.isEmpty
                                        ? Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: secondPrimaryColor,
                                            border: Border.all(
                                              color: primaryColor,
                                              width: 2,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: primaryColor,
                                                blurRadius: 12,
                                                offset: Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Iconsax.picture_frame,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  "اختيار صورة",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: ClipOval(
                                            child: Image.file(
                                              File(
                                                cubit.selectedImages[0].path,
                                              ),
                                              height: 120,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: tittleController,
                                hintText: 'العنوان',
                                prefixIcon: Icons.title,
                                validate: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'رجاءً أدخل العنوان';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: priceController,
                                hintText: 'السعر',
                                keyboardType: TextInputType.number,
                                validate: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'رجاءً أدخل السعر';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: stockController,
                                hintText: 'الكمية المتوفرة',
                                keyboardType: TextInputType.number,
                                validate: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'رجاءً أدخل الكمية المتوفرة';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: mainCategoryNameController,
                                hintText: 'القسم الرئيسي',
                                keyboardType: TextInputType.none,
                                onTap:
                                    () => _showMainCategoriesBottomSheet(
                                      context,
                                      cubit,
                                    ),
                                validate: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'رجاءً اختر القسم الرئيسي';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: subcategoryNameController,
                                hintText: 'القسم الفرعي',
                                keyboardType: TextInputType.none,
                                onTap:
                                    () => _showSubcategoriesBottomSheet(
                                      context,
                                      cubit,
                                    ),
                                validate: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'رجاءً اختر القسم الفرعي';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: descController,
                                hintText: 'الوصف',
                                prefixIcon: Icons.description_outlined,
                                keyboardType: TextInputType.text,
                                maxLines: 5,
                                validate: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'رجاءً أدخل الوصف';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: colorsController,
                                hintText: 'الألوان اختيارية مثل: أحمر, أزرق',
                                prefixIcon: Icons.palette_outlined,
                                keyboardType: TextInputType.text,
                                validate: (_) => null,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: sizesController,
                                hintText: 'القياسات اختيارية مثل: S, M, L',
                                prefixIcon: Icons.straighten_outlined,
                                keyboardType: TextInputType.text,
                                validate: (_) => null,
                              ),
                              const SizedBox(height: 30),
                              ConditionalBuilder(
                                condition: state is! AddProductsLoadingState,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        cubit.addProducts(
                                          tittle: tittleController.text.trim(),
                                          desc: descController.text.trim(),
                                          price: priceController.text.trim(),
                                          stock: stockController.text.trim(),
                                          categoryId:
                                              categoryIdController.text.trim(),
                                          colors: colorsController.text.trim(),
                                          sizes: sizesController.text.trim(),
                                          context: context,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withValues(
                                              alpha: 0.2,
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
                                          const SizedBox(width: 50),
                                          const Text(
                                            'إضافة المنتج',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(6),
                                            height: double.maxFinite,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white,
                                            ),
                                            child: const Icon(
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
                                    (c) => const CircularProgressIndicator(
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

  void _showMainCategoriesBottomSheet(BuildContext context, AdminCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: appSurface(context),
      builder: (context) {
        return ListView.builder(
          itemCount: cubit.mainCategories.length,
          itemBuilder: (context, i) {
            final category = cubit.mainCategories[i];
            return ListTile(
              title: Text(category.name),
              onTap: () {
                mainCategoryNameController.text = category.name;
                mainCategoryIdController.text = category.id.toString();
                subcategoryNameController.clear();
                categoryIdController.clear();
                navigateBack(context);
              },
            );
          },
        );
      },
    );
  }

  void _showSubcategoriesBottomSheet(BuildContext context, AdminCubit cubit) {
    if (mainCategoryIdController.text.isEmpty) {
      showToastInfo(text: 'اختر القسم الرئيسي أولاً', context: context);
      return;
    }

    final subcategories = cubit.subcategoriesForMain(
      int.parse(mainCategoryIdController.text),
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: appSurface(context),
      builder: (context) {
        return ListView.builder(
          itemCount: subcategories.length,
          itemBuilder: (context, i) {
            final category = subcategories[i];
            return ListTile(
              title: Text(category.name),
              onTap: () {
                subcategoryNameController.text = category.name;
                categoryIdController.text = category.id.toString();
                navigateBack(context);
              },
            );
          },
        );
      },
    );
  }
}
