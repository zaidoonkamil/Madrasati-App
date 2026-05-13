import 'package:carousel_slider/carousel_slider.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:madrasati_app/features/admin/cubit/cubit.dart';
import 'package:madrasati_app/features/admin/cubit/states.dart';
import 'package:madrasati_app/features/admin/view/add_ads.dart';
import 'package:madrasati_app/features/admin/view/add_cat.dart';
import 'package:madrasati_app/features/user/model/GetAdsModel.dart';
import 'package:madrasati_app/features/user/view/ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/circular_progress.dart';
import 'details/subcategories_admin.dart';
import '../../user/view/details.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  static ScrollController? scrollController;
  static CarouselController carouselController = CarouselController();
  static int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) =>
              AdminCubit()
                ..getGreeting()
                ..getAds(context: context)
                ..getProfile(context: context)
                ..getSocialSettings(context: context)
                ..getCoupons(context: context)
                ..getFaqs(context: context)
                ..getCustomRequests(context: context)
                ..getCat(context: context)
                ..getProducts(context: context, page: '1'),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AdminCubit.get(context);
          return SafeArea(
            top: false,
            child: Scaffold(
              body: Column(
                children: [
                  CustomAppBarAdmin(),
                  cubit.getCatModel.isNotEmpty
                      ? Expanded(
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                _AdminToolsCard(cubit: cubit),
                                const SizedBox(height: 12),
                                ConditionalBuilder(
                                  condition: cubit.getAdsModel.isNotEmpty,
                                  builder: (c) {
                                    return Stack(
                                      children: [
                                        CarouselSlider(
                                          items:
                                              cubit.getAdsModel.isNotEmpty
                                                  ? cubit.getAdsModel
                                                      .expand<Widget>(
                                                        (
                                                          GetAds ad,
                                                        ) => ad.images.map<
                                                          Widget
                                                        >(
                                                          (
                                                            String imageUrl,
                                                          ) => Builder(
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              String
                                                              formattedDate =
                                                                  DateFormat(
                                                                    'yyyy/M/d',
                                                                  ).format(
                                                                    ad.createdAt,
                                                                  );
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  navigateTo(
                                                                    context,
                                                                    AdsUser(
                                                                      tittle:
                                                                          ad.title,
                                                                      desc:
                                                                          ad.description,
                                                                      image:
                                                                          imageUrl,
                                                                      time:
                                                                          formattedDate,
                                                                    ),
                                                                  );
                                                                },
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8.0,
                                                                      ),
                                                                  child: Image.network(
                                                                    "$url/uploads/$imageUrl",
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                      .toList()
                                                  : <Widget>[],
                                          options: CarouselOptions(
                                            height: 156,
                                            viewportFraction: 0.94,
                                            enlargeCenterPage: true,
                                            initialPage: 0,
                                            enableInfiniteScroll: true,
                                            reverse: true,
                                            autoPlay: true,
                                            autoPlayInterval: const Duration(
                                              seconds: 6,
                                            ),
                                            autoPlayAnimationDuration:
                                                const Duration(seconds: 1),
                                            autoPlayCurve: Curves.fastOutSlowIn,
                                            scrollDirection: Axis.horizontal,
                                            onPageChanged: (index, reason) {
                                              currentIndex = index;
                                              cubit.slid();
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 0,
                                          right: 0,
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  cubit.deleteAds(
                                                    id:
                                                        cubit
                                                            .getAdsModel[currentIndex]
                                                            .id
                                                            .toString(),
                                                    context: context,
                                                  );
                                                },
                                                child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children:
                                                    cubit.getAdsModel.asMap().entries.map((
                                                      entry,
                                                    ) {
                                                      return Container(
                                                        width: 8,
                                                        height: 7.0,
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 3.0,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          color:
                                                              currentIndex ==
                                                                      entry.key
                                                                  ? primaryColor
                                                                      .withValues(
                                                                        alpha:
                                                                            0.8,
                                                                      )
                                                                  : Colors
                                                                      .white,
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  fallback:
                                      (c) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 60.0,
                                        ),
                                        child: Container(),
                                      ),
                                ),
                                SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    navigateTo(context, AddAds());
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: primaryColor,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'اضافة اعلان',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'اقسامنا',
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: cubit.mainCategories.length,
                                    reverse: true,
                                    itemBuilder: (context, i) {
                                      String rawImageUrl =
                                          cubit.mainCategories[i].images[0];
                                      String cleanImageUrl = rawImageUrl
                                          .replaceAll(RegExp(r'[\[\]]'), '');
                                      return GestureDetector(
                                        onTap: () {
                                          navigateTo(
                                            context,
                                            AdminSubcategoriesPage(
                                              parentCategory:
                                                  cubit.mainCategories[i],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appMutedSurface(
                                                    context,
                                                  ),
                                                  border: Border.all(
                                                    color: appBorder(context),
                                                    width: 1.0,
                                                  ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      "$url/uploads/$cleanImageUrl",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                cubit.mainCategories[i].name,
                                                style: TextStyle(fontSize: 13),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  cubit.deleteCategories(
                                                    id:
                                                        cubit
                                                            .mainCategories[i]
                                                            .id
                                                            .toString(),
                                                    context: context,
                                                  );
                                                },
                                                child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
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
                                SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    navigateTo(context, AddCat());
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: primaryColor,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'اضافة قسم',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'الأكثر مبيعًا',
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                cubit.productsModel != null
                                    ? GridView.custom(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      controller: scrollController,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 4,
                                            mainAxisSpacing: 1,
                                            childAspectRatio: 0.48,
                                          ),
                                      childrenDelegate: SliverChildBuilderDelegate(
                                        childCount:
                                            cubit
                                                .productsModel!
                                                .products
                                                .length,
                                        (context, index) {
                                          if (index ==
                                                  cubit
                                                          .productsModel!
                                                          .products
                                                          .length -
                                                      1 &&
                                              !cubit.isLastPageProducts) {
                                            cubit.getProducts(
                                              page:
                                                  (cubit.currentPageProducts +
                                                          1)
                                                      .toString(),
                                              context: context,
                                            );
                                          }
                                          String rawImageUrl =
                                              cubit
                                                  .productsModel!
                                                  .products[index]
                                                  .images[0];
                                          String cleanImageUrl = rawImageUrl
                                              .replaceAll(
                                                RegExp(r'[\[\]]'),
                                                '',
                                              );
                                          return GestureDetector(
                                            onTap: () {
                                              navigateTo(
                                                context,
                                                Details(
                                                  sellerId:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .seller
                                                          .id
                                                          .toString(),
                                                  id:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .id
                                                          .toString(),
                                                  tittle:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .title
                                                          .toString(),
                                                  description:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .description
                                                          .toString(),
                                                  price:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .price
                                                          .toString(),
                                                  stock:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .stock,
                                                  colors:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .colors,
                                                  sizes:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .sizes,
                                                  images:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .images,
                                                  isFavorite:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .isFavorite,
                                                  imageSeller:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .seller
                                                          .image,
                                                  locationSeller:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .seller
                                                          .location,
                                                  nameSeller:
                                                      cubit
                                                          .productsModel!
                                                          .products[index]
                                                          .seller
                                                          .name,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: 4,
                                                  ),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: appBorder(context),
                                                  width: 1.0,
                                                ),
                                                color: appSurface(context),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    child: Image.network(
                                                      '$url/uploads/$cleanImageUrl',
                                                      width: double.maxFinite,
                                                      height: 143,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          cubit.deleteProducts(
                                                            idProducts:
                                                                cubit
                                                                    .productsModel!
                                                                    .products[index]
                                                                    .id
                                                                    .toString(),
                                                            context: context,
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 35,
                                                          height: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: const Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              cubit
                                                                  .productsModel!
                                                                  .products[index]
                                                                  .title,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                              textAlign:
                                                                  TextAlign.end,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              'ID: ${cubit.productsModel!.products[index].id}',
                                                              style: const TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                    appTextMutedColor,
                                                              ),
                                                              textAlign:
                                                                  TextAlign.end,
                                                            ),
                                                            SizedBox(height: 6),
                                                            Text(
                                                              cubit
                                                                          .productsModel!
                                                                          .products[index]
                                                                          .stock >
                                                                      0
                                                                  ? 'المخزون: ${cubit.productsModel!.products[index].stock}'
                                                                  : 'غير متوفر',
                                                              style: TextStyle(
                                                                color:
                                                                    cubit.productsModel!.products[index].stock >
                                                                            0
                                                                        ? successColor
                                                                        : dangerColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                              textAlign:
                                                                  TextAlign.end,
                                                            ),
                                                            SizedBox(height: 6),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  'د.ع',
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                    color:
                                                                        secondPrimaryColor,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                ),
                                                                Text(
                                                                  NumberFormat(
                                                                        '#,###',
                                                                      )
                                                                      .format(
                                                                        cubit
                                                                            .productsModel!
                                                                            .products[index]
                                                                            .price,
                                                                      )
                                                                      .toString(),
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                    color:
                                                                        secondPrimaryColor,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      GestureDetector(
                                                        onTap:
                                                            () => _showEditProductDialog(
                                                              context,
                                                              cubit,
                                                              cubit
                                                                  .productsModel!
                                                                  .products[index],
                                                            ),
                                                        child: Container(
                                                          width: 35,
                                                          height: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    appAccentColor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: const Icon(
                                                            Icons.edit,
                                                            color:
                                                                appTextPrimaryColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),

                                                      GestureDetector(
                                                        onTap:
                                                            () => _showMarketingProductsDialog(
                                                              context,
                                                              cubit,
                                                              cubit
                                                                  .productsModel!
                                                                  .products[index],
                                                            ),
                                                        child: Container(
                                                          width: 35,
                                                          height: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    primaryColor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: const Icon(
                                                            Icons
                                                                .view_carousel_outlined,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const Spacer(),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : Container(),

                                SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      )
                      : Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: [CircularProgressHome()]),
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

class _AdminToolsCard extends StatelessWidget {
  const _AdminToolsCard({required this.cubit});

  final AdminCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorder(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'الأسئلة الشائعة',
                style: IconButton.styleFrom(backgroundColor: appAccentColor),
                onPressed: () => _showFaqAdminDialog(context, cubit),
                icon: const Icon(Icons.question_answer_outlined),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appAccentColor,
                  foregroundColor: appTextPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _showCouponDialog(context, cubit),
                icon: const Icon(Icons.local_offer_outlined, size: 18),
                label: const Text('كوبونات'),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'الطلبات المخصصة',
                style: IconButton.styleFrom(backgroundColor: appAccentColor),
                onPressed: () => _showCustomRequestsDialog(context, cubit),
                icon: const Icon(Icons.assignment_outlined),
              ),
            ],
          ),
          Row(
            children: [
              Switch(
                value: cubit.showSocialLinks,
                activeColor: appAccentColor,
                onChanged:
                    (value) => cubit.updateSocialSettings(
                      context: context,
                      show: value,
                    ),
              ),
              const SizedBox(width: 8),
              const Text(
                'إظهار التواصل',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showFaqAdminDialog(BuildContext context, AdminCubit cubit) {
  final q = TextEditingController();
  final a = TextEditingController();
  showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          backgroundColor: appSurface(context),
          title: const Text('الأسئلة الشائعة', textAlign: TextAlign.end),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EditProductField(controller: q, hint: 'السؤال'),
                const SizedBox(height: 10),
                _EditProductField(controller: a, hint: 'الجواب', maxLines: 3),
                const SizedBox(height: 12),
                ...cubit.faqs.map(
                  (faq) => ListTile(
                    title: Text(
                      faq['question']?.toString() ?? '',
                      textAlign: TextAlign.end,
                    ),
                    subtitle: Text(
                      faq['answer']?.toString() ?? '',
                      textAlign: TextAlign.end,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: primaryColor,
                          ),
                          onPressed:
                              () => _showEditFaqDialog(context, cubit, faq),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: appDangerColor,
                          ),
                          onPressed:
                              () => cubit.deleteFaq(
                                context: context,
                                faqId: faq['id'] as int,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
            ElevatedButton(
              onPressed: () {
                cubit.addFaq(
                  context: context,
                  question: q.text,
                  answer: a.text,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
  );
}

void _showEditFaqDialog(
  BuildContext pageContext,
  AdminCubit cubit,
  Map<String, dynamic> faq,
) {
  final q = TextEditingController(text: faq['question']?.toString() ?? '');
  final a = TextEditingController(text: faq['answer']?.toString() ?? '');
  bool isActive = faq['isActive'] != false;

  showDialog(
    context: pageContext,
    builder:
        (dialogContext) => StatefulBuilder(
          builder:
              (builderContext, setState) => AlertDialog(
                backgroundColor: appSurface(builderContext),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: const Text(
                  'تعديل السؤال',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _EditProductField(controller: q, hint: 'السؤال'),
                      const SizedBox(height: 10),
                      _EditProductField(
                        controller: a,
                        hint: 'الجواب',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        value: isActive,
                        activeColor: appAccentColor,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'إظهار السؤال للمستخدم',
                          textAlign: TextAlign.end,
                        ),
                        onChanged: (value) => setState(() => isActive = value),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appAccentColor,
                      foregroundColor: appTextPrimaryColor,
                    ),
                    onPressed: () {
                      cubit.updateFaq(
                        context: pageContext,
                        faqId: faq['id'] as int,
                        question: q.text,
                        answer: a.text,
                        isActive: isActive,
                      );
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              ),
        ),
  );
}

void _showCustomRequestsDialog(BuildContext context, AdminCubit cubit) {
  showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          backgroundColor: appSurface(context),
          title: const Text('الطلبات المخصصة', textAlign: TextAlign.end),
          content: SizedBox(
            width: double.maxFinite,
            child:
                cubit.customRequests.isEmpty
                    ? const Text(
                      'لا توجد طلبات مخصصة حالياً',
                      textAlign: TextAlign.center,
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      itemCount: cubit.customRequests.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final request = cubit.customRequests[index];
                        final user = request['user'] as Map?;
                        return ListTile(
                          title: Text(
                            request['description']?.toString() ?? '',
                            textAlign: TextAlign.end,
                          ),
                          subtitle: Text(
                            '${user?['name'] ?? ''}\n${user?['phone'] ?? ''}',
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        ),
  );
}

void _showCouponDialog(BuildContext pageContext, AdminCubit cubit) {
  final codeController = TextEditingController();
  final valueController = TextEditingController();
  String type = 'percentage';

  showDialog(
    context: pageContext,
    builder:
        (dialogContext) => StatefulBuilder(
          builder:
              (sheetContext, setState) => AlertDialog(
                backgroundColor: appSurface(pageContext),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: const Text(
                  'كوبونات الخصم',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _EditProductField(
                        controller: codeController,
                        hint: 'رمز الكوبون',
                      ),
                      const SizedBox(height: 10),
                      _EditProductField(
                        controller: valueController,
                        hint: type == 'percentage' ? 'النسبة %' : 'المبلغ',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('مبلغ'),
                            selected: type == 'fixed',
                            onSelected: (_) => setState(() => type = 'fixed'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('نسبة'),
                            selected: type == 'percentage',
                            onSelected:
                                (_) => setState(() => type = 'percentage'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...cubit.coupons.map((coupon) {
                        final active = coupon['isActive'] == true;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            coupon['code']?.toString() ?? '',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${coupon['value']} ${coupon['type'] == 'fixed' ? 'د.ع' : '%'}',
                            textAlign: TextAlign.end,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: appDangerColor,
                            ),
                            onPressed:
                                () => _confirmDeleteCoupon(
                                  pageContext,
                                  cubit,
                                  coupon['id'] as int,
                                  coupon['code']?.toString() ?? '',
                                ),
                          ),
                          leading: Switch(
                            value: active,
                            activeColor: appAccentColor,
                            onChanged:
                                (_) => cubit.toggleCoupon(
                                  context: pageContext,
                                  couponId: coupon['id'] as int,
                                  isActive: active,
                                ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('إغلاق'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appAccentColor,
                      foregroundColor: appTextPrimaryColor,
                    ),
                    onPressed: () {
                      cubit.addCoupon(
                        context: pageContext,
                        code: codeController.text.trim(),
                        type: type,
                        value: valueController.text.trim(),
                      );
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('إضافة'),
                  ),
                ],
              ),
        ),
  );
}

void _confirmDeleteCoupon(
  BuildContext context,
  AdminCubit cubit,
  int couponId,
  String couponCode,
) {
  showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          backgroundColor: appSurface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'حذف الكوبون',
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'هل تريد حذف كوبون $couponCode؟',
            textAlign: TextAlign.end,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appDangerColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.deleteCoupon(context: context, couponId: couponId);
              },
              child: const Text('حذف'),
            ),
          ],
        ),
  );
}

void _showMarketingProductsDialog(
  BuildContext pageContext,
  AdminCubit cubit,
  dynamic product,
) {
  final searchController = TextEditingController();
  final selected = <int>{};
  var initialized = false;
  var isSearching = false;
  var searchResults = <dynamic>[];

  showDialog(
    context: pageContext,
    builder:
        (dialogContext) => FutureBuilder<List<int>>(
          future: cubit.getMarketingProductIds(
            context: pageContext,
            productId: product.id as int,
          ),
          builder: (builderContext, snapshot) {
            if (!initialized && snapshot.hasData) {
              selected.addAll(snapshot.data!);
              initialized = true;
            }

            return StatefulBuilder(
              builder:
                  (innerContext, setState) => AlertDialog(
                    backgroundColor: appSurface(innerContext),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(
                      'منتجات تظهر تحت هذا المنتج',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: appTextPrimary(innerContext),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    content: SizedBox(
                      width: double.maxFinite,
                      child:
                          snapshot.connectionState == ConnectionState.waiting
                              ? const SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : searchResults.isEmpty
                              ? const Text(
                                'لا توجد منتجات للاختيار',
                                textAlign: TextAlign.center,
                              )
                              : ListView.separated(
                                shrinkWrap: true,
                                itemCount: searchResults.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (_, index) {
                                  final item = searchResults[index];
                                  final isSelected = selected.contains(item.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    activeColor: appAccentColor,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    onChanged: (_) {
                                      setState(() {
                                        if (isSelected) {
                                          selected.remove(item.id);
                                        } else {
                                          selected.add(item.id);
                                        }
                                      });
                                    },
                                    title: Text(
                                      item.title,
                                      textAlign: TextAlign.end,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      'ID: ${item.id}',
                                      textAlign: TextAlign.end,
                                    ),
                                  );
                                },
                              ),
                    ),
                    actions: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appAccentColor,
                                foregroundColor: appTextPrimaryColor,
                              ),
                              onPressed:
                                  isSearching
                                      ? null
                                      : () async {
                                        setState(() => isSearching = true);
                                        final results = await cubit
                                            .searchMarketingProducts(
                                              context: pageContext,
                                              query: searchController.text,
                                              currentProductId:
                                                  product.id as int,
                                            );
                                        setState(() {
                                          searchResults = results;
                                          isSearching = false;
                                        });
                                      },
                              child:
                                  isSearching
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text('بحث'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _EditProductField(
                                controller: searchController,
                                hint: 'ابحث بالـ ID أو اسم المنتج',
                                requiredField: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        child: Text(
                          'المختارة: ${selected.length}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: appTextMuted(innerContext),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appAccentColor,
                          foregroundColor: appTextPrimaryColor,
                        ),
                        onPressed: () {
                          cubit.marketingProductIds = selected.toList();
                          cubit.updateMarketingProducts(
                            context: pageContext,
                            productId: product.id as int,
                          );
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('حفظ'),
                      ),
                    ],
                  ),
            );
          },
        ),
  );
}

void _showEditProductDialog(
  BuildContext context,
  AdminCubit cubit,
  dynamic product,
) {
  final titleController = TextEditingController(text: product.title.toString());
  final descriptionController = TextEditingController(
    text: product.description.toString(),
  );
  final priceController = TextEditingController(text: product.price.toString());
  final stockController = TextEditingController(text: product.stock.toString());
  final lowStockAlertController = TextEditingController(
    text: product.lowStockAlert.toString(),
  );
  final colorsController = TextEditingController(
    text: (product.colors as List).join(', '),
  );
  final sizesController = TextEditingController(
    text: (product.sizes as List).join(', '),
  );
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          backgroundColor: appSurface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'تعديل المنتج',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: appTextPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EditProductField(
                    controller: titleController,
                    hint: 'العنوان',
                  ),
                  const SizedBox(height: 10),
                  _EditProductField(
                    controller: priceController,
                    hint: 'السعر',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _EditProductField(
                    controller: stockController,
                    hint: 'المخزون',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _EditProductField(
                    controller: lowStockAlertController,
                    hint: 'حد تنبيه المخزون',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _EditProductField(
                    controller: descriptionController,
                    hint: 'الوصف',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 10),
                  _EditProductField(
                    controller: colorsController,
                    requiredField: false,
                    hint: 'الألوان اختيارية: أحمر, أزرق',
                  ),
                  const SizedBox(height: 10),
                  _EditProductField(
                    controller: sizesController,
                    requiredField: false,
                    hint: 'القياسات اختيارية: S, M, L',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentColor,
                foregroundColor: appTextPrimaryColor,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                cubit.updateProduct(
                  productId: product.id.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  price: priceController.text.trim(),
                  stock: stockController.text.trim(),
                  lowStockAlert: lowStockAlertController.text.trim(),
                  colors: colorsController.text.trim(),
                  sizes: sizesController.text.trim(),
                  context: context,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
  );
}

class _EditProductField extends StatelessWidget {
  const _EditProductField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.requiredField = true,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: appMutedSurface(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (!requiredField) return null;
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }
}
