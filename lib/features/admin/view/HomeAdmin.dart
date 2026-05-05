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
                                                  color: containerColor,
                                                  border: Border.all(
                                                    color: borderColor,
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
                                            childAspectRatio: 0.6,
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
                                                  color: borderColor,
                                                  width: 1.0,
                                                ),
                                                color: containerColor,
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
                                                      SizedBox(width: 6),
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

                                                  const Spacer(),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : Container(),
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
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          backgroundColor: appSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'تعديل المنتج',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: appTextPrimaryColor,
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
                    controller: descriptionController,
                    hint: 'الوصف',
                    maxLines: 4,
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
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

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
        fillColor: appMutedSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }
}
