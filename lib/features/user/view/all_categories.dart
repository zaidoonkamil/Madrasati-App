import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/app_bar.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../model/CatModel.dart';
import 'subcategories.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({
    super.key,
    this.categories = const [],
    this.useHomeAppBar = false,
  });

  final List<CatModel> categories;
  final bool useHomeAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              UserCubit()
                ..getGreeting()
                ..getCat(context: context),
      child: BlocBuilder<UserCubit, UserStates>(
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final viewCategories =
              categories.isNotEmpty ? categories : cubit.getCatModel;
          final localeCode = Localizations.localeOf(context).languageCode;

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appPageColor(context),
              body: Column(
                children: [
                  useHomeAppBar
                      ? const CustomAppBar(
                        title: 'الأقسام',
                        subtitle: 'اختر القسم المناسب لسيارتك',
                      )
                      : CustomAppBarBack(
                        title: 'الأقسام',
                        subtitle: 'اختر القسم المناسب لسيارتك',
                      ),
                  Expanded(
                    child:
                        viewCategories.isEmpty
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                            : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                140,
                              ),
                              itemCount: viewCategories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.8,
                                  ),
                              itemBuilder: (context, index) {
                                final category = viewCategories[index];
                                final rawImageUrl =
                                    category.images.isNotEmpty
                                        ? category.images.first
                                        : '';
                                final cleanImageUrl = rawImageUrl.replaceAll(
                                  RegExp(r'[\[\]]'),
                                  '',
                                );

                                return GestureDetector(
                                  onTap:
                                      () => navigateTo(
                                        context,
                                        SubCategoriesPage(
                                          parentCategory: category,
                                        ),
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: appSurface(context),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: appBorder(context),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            child:
                                                cleanImageUrl.isEmpty
                                                    ? Container(
                                                      color: appMutedSurface(
                                                        context,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons.category_outlined,
                                                        color: appTextMuted(
                                                          context,
                                                        ),
                                                        size: 32,
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
                                          category.localizedName(localeCode),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: secondPrimaryColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
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
