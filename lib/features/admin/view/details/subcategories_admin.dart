import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/remote/dio_helper.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/show_toast.dart';
import '../../../../core/ navigation/navigation.dart';
import '../../../user/model/CatModel.dart';
import '../../../user/view/Section.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class AdminSubcategoriesPage extends StatelessWidget {
  const AdminSubcategoriesPage({super.key, required this.parentCategory});

  final CatModel parentCategory;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit()..getCat(context: context),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is DeleteCategoriesSuccessState) {
            showToastSuccess(
              text: 'تم حذف القسم الفرعي بنجاح',
              context: context,
            );
          }
        },
        builder: (context, state) {
          final cubit = AdminCubit.get(context);
          final currentParent = cubit.getCatModel.cast<CatModel?>().firstWhere(
            (item) => item?.id == parentCategory.id,
            orElse: () => parentCategory,
          );
          final subcategories = currentParent?.subcategories ?? [];

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appBackgroundColor,
              body: Column(
                children: [
                  CustomAppBarBack(
                    title: 'الأقسام الفرعية',
                    subtitle: 'إدارة الأقسام التابعة لـ ${parentCategory.name}',
                  ),
                  Expanded(
                    child:
                        subcategories.isEmpty
                            ? const Center(
                              child: Text(
                                'لا توجد أقسام فرعية لهذا القسم حالياً',
                                style: TextStyle(
                                  color: secondTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                            : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: subcategories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.84,
                                  ),
                              itemBuilder: (context, index) {
                                final subcategory = subcategories[index];
                                final imageUrl =
                                    subcategory.images.isNotEmpty
                                        ? subcategory.images.first
                                        : '';
                                final cleanImageUrl = imageUrl.replaceAll(
                                  RegExp(r'[\[\]]'),
                                  '',
                                );

                                return GestureDetector(
                                  onTap: () {
                                    navigateTo(
                                      context,
                                      Section(
                                        categoriesId: subcategory.id.toString(),
                                        categoryTitle: subcategory.name,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
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
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child:
                                                cleanImageUrl.isEmpty
                                                    ? Container(
                                                      color: mutedSurfaceColor,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons.widgets_outlined,
                                                        color: secondTextColor,
                                                        size: 30,
                                                      ),
                                                    )
                                                    : Image.network(
                                                      '$url/uploads/$cleanImageUrl',
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          subcategory.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: secondPrimaryColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'اضغط لعرض المنتجات',
                                          style: TextStyle(
                                            color: secondTextColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              cubit.deleteCategories(
                                                id: subcategory.id.toString(),
                                                context: context,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: accentColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'حذف',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
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
