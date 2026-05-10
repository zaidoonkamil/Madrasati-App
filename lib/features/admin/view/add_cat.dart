import 'dart:io';

import 'package:madrasati_app/core/navigation_bar/navigation_bar_Admin.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/show_toast.dart';
import '../../user/model/CatModel.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

class AddCat extends StatefulWidget {
  const AddCat({super.key});

  @override
  State<AddCat> createState() => _AddCatState();
}

class _AddCatState extends State<AddCat> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController parentIdController = TextEditingController();

  bool isSubcategory = false;

  @override
  void dispose() {
    titleController.dispose();
    parentNameController.dispose();
    parentIdController.dispose();
    super.dispose();
  }

  void _resetParentSelection() {
    parentNameController.clear();
    parentIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AdminCubit()..getCat(context: context),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is AddCategoriesSuccessState) {
            final cubit = AdminCubit.get(context);
            cubit.selectedImagesCat = [];
            titleController.clear();
            _resetParentSelection();
            setState(() {
              isSubcategory = false;
            });
            showToastSuccess(text: "تمت العملية بنجاح", context: context);
            navigateAndFinish(context, BottomNavBarAdmin());
          }
        },
        builder: (context, state) {
          final cubit = AdminCubit.get(context);
          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appPageColor(context),
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const CustomAppBarBack(
                      title: 'إضافة قسم',
                      subtitle: 'أنشئ قسماً رئيسياً أو قسماً فرعياً تابعاً له',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildTypeSelector(),
                            const SizedBox(height: 18),
                            _buildImagePicker(cubit),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: titleController,
                                    hintText:
                                        isSubcategory
                                            ? 'اسم القسم الفرعي'
                                            : 'اسم القسم الرئيسي',
                                    validate: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'رجاءً أدخل اسم القسم';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (isSubcategory) ...[
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: parentNameController,
                                      hintText: 'اختر القسم الرئيسي',
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
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ConditionalBuilder(
                              condition: state is! AddCategoriesLoadingState,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    if (formKey.currentState!.validate()) {
                                      cubit.addCat(
                                        tittle: titleController.text.trim(),
                                        parentId:
                                            isSubcategory
                                                ? parentIdController.text.trim()
                                                : null,
                                        context: context,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          appDarkGradientStartColor,
                                          appDarkGradientEndColor,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(
                                            alpha: 0.22,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        isSubcategory
                                            ? 'إضافة قسم فرعي'
                                            : 'إضافة قسم رئيسي',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              fallback:
                                  (c) => const CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isSubcategory
                                  ? 'القسم الفرعي سيظهر داخل القسم الرئيسي الذي تختاره.'
                                  : 'الأقسام الرئيسية هي المستوى الأول الذي يراه المستخدم.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: secondTextColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _typeTile(
              title: 'قسم رئيسي',
              subtitle: 'يظهر أولاً',
              selected: !isSubcategory,
              onTap: () {
                setState(() {
                  isSubcategory = false;
                  _resetParentSelection();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _typeTile(
              title: 'قسم فرعي',
              subtitle: 'داخل قسم رئيسي',
              selected: isSubcategory,
              onTap: () {
                setState(() {
                  isSubcategory = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? secondPrimaryColor : appMutedSurface(context),
        ),
        child: Column(
          children: [
            Icon(
              selected ? Iconsax.category_2 : Iconsax.category,
              color: selected ? Colors.white : secondPrimaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : secondPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white70 : appTextMuted(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(AdminCubit cubit) {
    return GestureDetector(
      onTap: cubit.pickImagesCat,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: appSurface(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isSubcategory ? 'صورة القسم الفرعي' : 'صورة القسم الرئيسي',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اختر صورة واضحة تمثل هذا القسم داخل التطبيق.',
                    style: TextStyle(color: secondTextColor, height: 1.5),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            cubit.selectedImagesCat.isEmpty
                ? Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: secondPrimaryColor,
                  ),
                  child: const Icon(
                    Iconsax.gallery_add,
                    color: Colors.white,
                    size: 34,
                  ),
                )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.file(
                    File(cubit.selectedImagesCat.first.path),
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _showMainCategoriesBottomSheet(BuildContext context, AdminCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: appSurface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List<CatModel> mainCategories = cubit.mainCategories;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'اختر القسم الرئيسي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'سيتم ربط القسم الفرعي داخل هذا القسم.',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: secondTextColor, height: 1.5),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    itemCount: mainCategories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final category = mainCategories[index];
                      return ListTile(
                        title: Text(category.name, textAlign: TextAlign.right),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                        ),
                        onTap: () {
                          parentNameController.text = category.name;
                          parentIdController.text = category.id.toString();
                          navigateBack(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
