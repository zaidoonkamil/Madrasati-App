import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:madrasati_app/core/widgets/app_bar.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/circular_progress.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../model/FavoritesModel.dart';
import 'details.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) => UserCubit()..getFavorites(context: context),
      child: BlocBuilder<UserCubit, UserStates>(
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final favorites =
              cubit.favoritesModel?.productsFavorites ??
              const <ProductFavorites>[];
          final localeCode = Localizations.localeOf(context).languageCode;

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: pageBackgroundColor,
              body: Column(
                children: [
                  CustomAppBarBack(
                    title: 'المفضلة',
                    subtitle: 'المنتجات التي حفظتها للرجوع إليها',
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        state is GetFavoritesLoadingState
                            ? const CustomCircularProgress()
                            : favorites.isEmpty
                            ? const _EmptyFavorites()
                            : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              physics: const BouncingScrollPhysics(),
                              itemCount: favorites.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final product = favorites[index];
                                return _FavoriteCard(
                                  product: product,
                                  localeCode: localeCode,
                                  onRemove: () {
                                    cubit.updateFavorites(
                                      idItem: product.id.toString(),
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

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.product,
    required this.localeCode,
    required this.onRemove,
  });

  final ProductFavorites product;
  final String localeCode;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final List<String> safeImages =
        product.images.where((image) => image.trim().isNotEmpty).toList();
    final String imageName =
        safeImages.isNotEmpty
            ? safeImages.first.replaceAll(RegExp(r'[\[\]]'), '')
            : '';
    final String title = product.localizedTitle(localeCode);
    final String description = product.localizedDescription(localeCode);

    return GestureDetector(
      onTap: () {
        navigateToPremium(
          context,
          Details(
            sellerId: product.seller.id.toString(),
            id: product.id.toString(),
            tittle: title,
            description: description,
            price: product.price.toString(),
            stock: product.stock,
            images: product.images,
            isFavorite: true,
            imageSeller: product.seller.image,
            locationSeller: product.seller.location,
            nameSeller: product.seller.name,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardSurfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: secondPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: secondTextColor,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: appWarmSurfaceColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: appRustColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat('#,###').format(product.price),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: secondPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'دينار عراقي',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: secondTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  imageName.isEmpty
                      ? Container(
                        width: 88,
                        height: 98,
                        color: mutedSurfaceColor,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: secondTextColor,
                        ),
                      )
                      : Hero(
                        tag: 'product-image-${product.id}',
                        child: Image.network(
                          '$url/uploads/$imageName',
                          width: 88,
                          height: 98,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: mutedSurfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: secondPrimaryColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات محفوظة حالياً',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'عند إضافة أي منتج إلى المفضلة سيظهر هنا بشكل منظم',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondTextColor,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
