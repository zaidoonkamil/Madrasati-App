import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:like_button/like_button.dart';
import 'package:madrasati_app/core/network/remote/dio_helper.dart';
import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:madrasati_app/core/widgets/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/styles/themes.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

// ═══════════════════════════════════════════════════════
//  PALETTE (matches full app)
// ═══════════════════════════════════════════════════════
const _cream = appBackgroundColor;
const _inkDeep = appTextPrimaryColor;
const _accentAmber = appAccentColor;

class Details extends StatelessWidget {
  const Details({
    super.key,
    required this.id,
    required this.sellerId,
    required this.tittle,
    required this.description,
    required this.price,
    required this.stock,
    required this.images,
    required this.imageSeller,
    required this.locationSeller,
    required this.nameSeller,
    required this.isFavorite,
  });

  static int currentIndex = 0;

  final String sellerId;
  final String id;
  final String tittle;
  final String description;
  final String price;
  final int stock;
  final String imageSeller;
  final String nameSeller;
  final String locationSeller;
  final bool isFavorite;
  final List<String>? images;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit()..isLiked = isFavorite,
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {
          if (state is AddToBasketSuccessState) {
            _showSuccessSnackBar(context, 'تمت إضافة المنتج إلى السلة بنجاح');
          }
        },
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final int number = int.tryParse(price) ?? 0;
          final bool canOrder =
              (adminOrUser == 'user' || token != '') && stock > 0;
          final List<String> safeImages =
              (images ?? []).where((e) => e.isNotEmpty).toList();

          return Scaffold(
            backgroundColor: _cream,
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  CustomAppBarBack(
                    title: 'تفاصيل المنتج',
                    subtitle: 'مواصفات القطعة وخيارات الطلب',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildGallery(cubit, safeImages),
                          const SizedBox(height: 12),
                          _buildHeadline(context, number, stock),
                          if (token != '') ...[
                            const SizedBox(height: 8),
                            _buildActionsCard(context, cubit, canOrder, stock),
                          ],
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── ✦ REDESIGNED ADD-TO-CART BUTTON ──
            bottomNavigationBar:
                canOrder
                    ? SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _AddToCartBar(
                          cubit: cubit,
                          id: id,
                          stock: stock,
                        ),
                      ),
                    )
                    : null,
          );
        },
      ),
    );
  }

  // ─── gallery, headline, actions — unchanged logic, kept as-is ───────────

  Widget _buildGallery(UserCubit cubit, List<String> safeImages) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardSurfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'product-image-$id',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child:
                  safeImages.isEmpty
                      ? Container(
                        height: 300,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 44,
                          color: secondTextColor,
                        ),
                      )
                      : CarouselSlider(
                        items:
                            safeImages.map((entry) {
                              return Image.network(
                                '$url/uploads/$entry',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 1,
                          enlargeCenterPage: false,
                          autoPlay: safeImages.length > 1,
                          autoPlayInterval: const Duration(seconds: 5),
                          onPageChanged: (index, reason) {
                            currentIndex = index;
                            cubit.slid();
                          },
                        ),
                      ),
            ),
          ),
          if (safeImages.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  safeImages.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentIndex == entry.key ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            currentIndex == entry.key
                                ? primaryColor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeadline(BuildContext context, int number, int stock) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: secondPrimaryColor.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            tittle,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 18,
              color: secondPrimaryColor,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: secondTextColor,
              height: 1.8,
            ),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: mutedSurfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 17,
                      color: successColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stock > 0 ? 'متوفر: $stock قطعة' : 'غير متوفر حالياً',
                      style: TextStyle(
                        color: stock > 0 ? secondPrimaryColor : dangerColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat('#,###').format(number),
                    style: const TextStyle(
                      fontSize: 24,
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'دينار عراقي',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    UserCubit cubit,
    bool canOrder,
    int stock,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LikeButton(
                size: 34,
                isLiked: cubit.isLiked,
                likeBuilder: (bool isLiked) {
                  return Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey[700],
                    size: 28,
                  );
                },
                onTap: (isLiked) async {
                  cubit.updateFavoritesDetails(idItem: id, context: context);
                  return !isLiked;
                },
              ),
            ],
          ),
          const Spacer(),
          if (canOrder)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: mutedSurfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (cubit.quantity < stock) {
                        cubit.add();
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      cubit.quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: secondPrimaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cubit.minus(context: context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: secondPrimaryColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'تمت العملية',
            message: message,
            contentType: ContentType.success,
          ),
        ),
      );
  }
}

// ═══════════════════════════════════════════════════════
//  ✦ ADD TO CART BOTTOM BAR
// ═══════════════════════════════════════════════════════
class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.cubit,
    required this.id,
    required this.stock,
  });
  final UserCubit cubit;
  final String id;
  final int stock;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (cubit.quantity > stock) {
          return;
        }
        cubit.addToBasket(
          productId: id,
          quantity: cubit.quantity.toString(),
          context: context,
        );
      },
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: _accentAmber,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _accentAmber.withValues(alpha: 0.38),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Cart icon box
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _inkDeep.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Iconsax.shopping_bag,
                color: _inkDeep,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // Label
            const Expanded(
              child: Text(
                'أضف إلى السلة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _inkDeep,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                ),
              ),
            ),

            // Quantity chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: _inkDeep.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${cubit.quantity} قطعة',
                style: const TextStyle(
                  color: _inkDeep,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
