import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:madrasati_app/core/widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/styles/themes.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'widgets/product_grid_card.dart';

class AllProductsPage extends StatelessWidget {
  const AllProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              UserCubit()
                ..getFeaturedProducts(context: context, page: '1', limit: 12)
                ..initFeaturedScrollController(context, limit: 12),
      child: const _AllProductsView(),
    );
  }
}

class _AllProductsView extends StatelessWidget {
  const _AllProductsView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<UserCubit, UserStates>(
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final localeCode = Localizations.localeOf(context).languageCode;

          return Scaffold(
            backgroundColor: appPageColor(context),
            body: Column(
              children: [
                _Header(
                  title: 'أبرز المنتجات',
                  subtitle: 'تشكيلة متجددة من قطع الغيار تتغير في كل مرة',
                ),
                Expanded(
                  child:
                      cubit.products.isEmpty && state is GetProductsLoadingState
                          ? const CircularProgressHome()
                          : GridView.builder(
                            controller: cubit.scrollControllerFeatured,
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                cubit.products.length +
                                (cubit.isLastPageFeaturedProducts ? 0 : 1),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.61,
                                ),
                            itemBuilder: (context, index) {
                              if (index >= cubit.products.length) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: appSurface(context),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: appBorder(context),
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              }

                              final product = cubit.products[index];

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
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [appDarkGradientStartColor, appDarkGradientEndColor],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => navigateBack(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
