import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/constant.dart';
import '../../auth/view/login.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'details.dart';
import 'widgets/product_grid_card.dart';

class Section extends StatelessWidget {
  const Section({super.key, required this.categoriesId, this.categoryTitle});

  final String categoriesId;
  final String? categoryTitle;
  static ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) =>
              UserCubit()
                ..getGreeting()
                ..getCatCatProducts(
                  context: context,
                  page: '1',
                  id: categoriesId,
                )
                ..initScrollControllerCat(context, categoriesId),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final localeCode = Localizations.localeOf(context).languageCode;
          final bool isAdminView = adminOrUser == 'admin';

          return SafeArea(
            top: false,
            child: Scaffold(
              body: Column(
                children: [
                  CustomAppBarBack(
                    title: categoryTitle ?? 'الأقسام',
                    subtitle: 'تشكيلة متجددة من قطع الغيار تتغير في كل مرة',
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        MediaQuery.of(context).size.shortestSide > 600
                            ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cubit.productCat.length,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                itemBuilder: (context, index) {
                                  final product = cubit.productCat[index];
                                  final List<String> images =
                                      product.images
                                          .where(
                                            (image) => image.trim().isNotEmpty,
                                          )
                                          .toList();
                                  final String cleanImageUrl =
                                      images.isNotEmpty
                                          ? images.first.replaceAll(
                                            RegExp(r'[\[\]]'),
                                            '',
                                          )
                                          : '';

                                  return GestureDetector(
                                    onTap: () {
                                      navigateToPremium(
                                        context,
                                        Details(
                                          sellerId:
                                              product.seller.id.toString(),
                                          id: product.id.toString(),
                                          tittle: product.localizedTitle(
                                            localeCode,
                                          ),
                                          description: product
                                              .localizedDescription(localeCode),
                                          price: product.price.toString(),
                                          stock: product.stock,
                                          colors: product.colors,
                                          sizes: product.sizes,
                                          images: product.images,
                                          isFavorite: product.isFavorite,
                                          imageSeller: product.seller.image,
                                          locationSeller:
                                              product.seller.location,
                                          nameSeller: product.seller.name,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: appSurface(context),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: appBorder(context),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (isAdminView) {
                                                cubit.deleteProductFromSection(
                                                  productId:
                                                      product.id.toString(),
                                                  context: context,
                                                );
                                                return;
                                              }

                                              if (token != '') {
                                                if (product.colors.isNotEmpty ||
                                                    product.sizes.isNotEmpty) {
                                                  navigateToPremium(
                                                    context,
                                                    Details(
                                                      sellerId:
                                                          product.seller.id
                                                              .toString(),
                                                      id: product.id.toString(),
                                                      tittle: product
                                                          .localizedTitle(
                                                            localeCode,
                                                          ),
                                                      description: product
                                                          .localizedDescription(
                                                            localeCode,
                                                          ),
                                                      price:
                                                          product.price
                                                              .toString(),
                                                      stock: product.stock,
                                                      colors: product.colors,
                                                      sizes: product.sizes,
                                                      images: product.images,
                                                      isFavorite:
                                                          product.isFavorite,
                                                      imageSeller:
                                                          product.seller.image,
                                                      locationSeller:
                                                          product
                                                              .seller
                                                              .location,
                                                      nameSeller:
                                                          product.seller.name,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                cubit.addToBasket(
                                                  productId:
                                                      product.id.toString(),
                                                  quantity: '1',
                                                  context: context,
                                                );
                                              } else {
                                                navigateTo(
                                                  context,
                                                  const Login(),
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color:
                                                    isAdminView
                                                        ? accentColor
                                                        : secondPrimaryColor,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.yellowAccent
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: FaIcon(
                                                  isAdminView
                                                      ? FontAwesomeIcons
                                                          .trashCan
                                                      : FontAwesomeIcons
                                                          .basketShopping,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  product.localizedTitle(
                                                    localeCode,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'د.ع',
                                                      style: const TextStyle(
                                                        color:
                                                            secondPrimaryColor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      NumberFormat(
                                                        '#,###',
                                                      ).format(product.price),
                                                      style: const TextStyle(
                                                        color:
                                                            secondPrimaryColor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child:
                                                cleanImageUrl.isEmpty
                                                    ? Container(
                                                      width: 95,
                                                      height: 95,
                                                      color: appMutedSurface(
                                                        context,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported_outlined,
                                                        color: appTextMuted(
                                                          context,
                                                        ),
                                                      ),
                                                    )
                                                    : Image.network(
                                                      '$url/uploads/$cleanImageUrl',
                                                      width: 95,
                                                      height: 95,
                                                      fit: BoxFit.cover,
                                                    ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: UserCubit.scrollControllerCat,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.61,
                                  ),
                              itemCount: cubit.productCat.length,
                              itemBuilder: (context, index) {
                                final product = cubit.productCat[index];
                                return UserProductGridCard(
                                  cubit: cubit,
                                  productId: product.id.toString(),
                                  sellerId: product.seller.id.toString(),
                                  title: product.localizedTitle(localeCode),
                                  description: product.localizedDescription(
                                    localeCode,
                                  ),
                                  price: product.price,
                                  stock: product.stock,
                                  colors: product.colors,
                                  sizes: product.sizes,
                                  images: product.images,
                                  isFavorite: product.isFavorite,
                                  imageSeller: product.seller.image,
                                  locationSeller: product.seller.location,
                                  nameSeller: product.seller.name,
                                  showDelete: isAdminView,
                                  onDelete: () {
                                    cubit.deleteProductFromSection(
                                      productId: product.id.toString(),
                                      context: context,
                                    );
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
      ),
    );
  }
}
