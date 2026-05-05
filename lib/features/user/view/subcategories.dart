import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:flutter/material.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/app_bar.dart';
import '../model/CatModel.dart';
import 'Section.dart';

class SubCategoriesPage extends StatelessWidget {
  const SubCategoriesPage({super.key, required this.parentCategory});

  final CatModel parentCategory;

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final subcategories = parentCategory.subcategories;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: pageBackgroundColor,
        body: Column(
          children: [
            CustomAppBarBack(
              title: parentCategory.localizedName(localeCode),
              subtitle: 'اختر القسم المناسب لسيارتك',
            ),
            Expanded(
              child:
                  subcategories.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'لا توجد نتائج مطابقة',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: secondTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: subcategories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.88,
                            ),
                        itemBuilder: (context, index) {
                          final subcategory = subcategories[index];
                          final rawImageUrl =
                              subcategory.images.isNotEmpty
                                  ? subcategory.images.first
                                  : '';
                          final cleanImageUrl = rawImageUrl.replaceAll(
                            RegExp(r'[\[\]]'),
                            '',
                          );

                          return GestureDetector(
                            onTap:
                                () => navigateTo(
                                  context,
                                  Section(
                                    categoriesId: subcategory.id.toString(),
                                    categoryTitle: subcategory.localizedName(
                                      localeCode,
                                    ),
                                  ),
                                ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardSurfaceColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child:
                                          cleanImageUrl.isEmpty
                                              ? Container(
                                                color: mutedSurfaceColor,
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.widgets_outlined,
                                                  color: secondTextColor,
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
                                    subcategory.localizedName(localeCode),
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
  }
}
