import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:like_button/like_button.dart';
import 'package:madrasati_app/core/network/remote/dio_helper.dart';
import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:madrasati_app/core/widgets/constant.dart';
import 'package:madrasati_app/core/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/styles/themes.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../model/ProductsModel.dart';

// ═══════════════════════════════════════════════════════
//  PALETTE (matches full app)
// ═══════════════════════════════════════════════════════
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
    required this.colors,
    required this.sizes,
    required this.images,
    required this.imageSeller,
    required this.locationSeller,
    required this.nameSeller,
    required this.isFavorite,
  });

  static int currentIndex = 0;
  static final String _appShareLink = appShareLink;

  final String sellerId;
  final String id;
  final String tittle;
  final String description;
  final String price;
  final int stock;
  final List<String> colors;
  final List<String> sizes;
  final String imageSeller;
  final String nameSeller;
  final String locationSeller;
  final bool isFavorite;
  final List<String>? images;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              UserCubit()
                ..isLiked = isFavorite
                ..getMarketingProducts(context: context, productId: id),
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
            backgroundColor: appPageColor(context),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  CustomAppBarBackPr(
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
                          _buildGallery(context, cubit, safeImages),
                          const SizedBox(height: 12),
                          _buildHeadline(context, number, stock),
                          if (colors.isNotEmpty || sizes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildOptionsCard(context, cubit),
                          ],
                          if (token != '') ...[
                            const SizedBox(height: 8),
                            _buildActionsCard(context, cubit, canOrder, stock),
                          ],
                          if (cubit.marketingProducts.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildMarketingProducts(context, cubit),
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
                          colors: colors,
                          sizes: sizes,
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

  Widget _buildGallery(
    BuildContext context,
    UserCubit cubit,
    List<String> safeImages,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: appBorder(context)),
      ),
      child: Column(
        children: [
          Stack(
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
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 44,
                              color: appTextMuted(context),
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
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () => _shareProduct(context),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: homeAccentColor.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share_rounded,
                          color: homeTextColor,
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'مشاركة',
                          style: TextStyle(
                            color: homeTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                                : appSurface(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: appBorder(context)),
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
        color: appSurface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appBorder(context)),
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
            style: TextStyle(
              fontSize: 18,
              color: secondPrimaryColor,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: appTextMuted(context),
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
                  color: appMutedSurface(context),
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
                      stock > 0 ? 'متوفر ' : 'غير متوفر حالياً',
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
                  Text(
                    'دينار عراقي',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      color: appTextMuted(context),
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
        color: appSurface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appBorder(context)),
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
                color: appMutedSurface(context),
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
                      child: Icon(
                        Icons.add,
                        color: appSurface(context),
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
                        color: appSurface(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: appBorder(context)),
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

  Widget _buildOptionsCard(BuildContext context, UserCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (colors.isNotEmpty) ...[
            const Text(
              'اختر اللون',
              style: TextStyle(
                color: secondPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _OptionWrap(
              values: colors,
              selectedValue: cubit.selectedProductColor,
              onSelected: cubit.selectProductColor,
            ),
          ],
          if (colors.isNotEmpty && sizes.isNotEmpty) const SizedBox(height: 16),
          if (sizes.isNotEmpty) ...[
            const Text(
              'اختر القياس',
              style: TextStyle(
                color: secondPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _OptionWrap(
              values: sizes,
              selectedValue: cubit.selectedProductSize,
              onSelected: cubit.selectProductSize,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarketingProducts(BuildContext context, UserCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'منتجات قد تعجبك',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: appTextPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              reverse: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: cubit.marketingProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _MarketingProductCard(
                  product: cubit.marketingProducts[index],
                );
              },
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

  Future<void> _shareProduct(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final number = int.tryParse(price) ?? 0;
    final shareText = '''
$tittle
السعر: ${NumberFormat('#,###').format(number)} دينار عراقي
$_appShareLink
''';

    await SharePlus.instance.share(
      ShareParams(
        text: shareText.trim(),
        subject: tittle,
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ✦ ADD TO CART BOTTOM BAR
// ═══════════════════════════════════════════════════════
class _MarketingProductCard extends StatelessWidget {
  const _MarketingProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final image = product.images.isNotEmpty ? product.images.first : '';
    final cleanImage = image.replaceAll(RegExp(r'[\[\]]'), '');

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => Details(
                  sellerId: product.userId.toString(),
                  id: product.id.toString(),
                  tittle: product.localizedTitle('ar'),
                  description: product.localizedDescription('ar'),
                  price: product.price.toString(),
                  stock: product.stock,
                  colors: product.colors,
                  sizes: product.sizes,
                  images: product.images,
                  imageSeller: product.seller.image,
                  locationSeller: product.seller.location,
                  nameSeller: product.seller.name,
                  isFavorite: product.isFavorite,
                ),
          ),
        );
      },
      child: Container(
        width: 142,
        decoration: BoxDecoration(
          color: appMutedSurface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: appBorder(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child:
                  cleanImage.isEmpty
                      ? Container(
                        height: 110,
                        color: appBorder(context),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: appTextMuted(context),
                        ),
                      )
                      : Image.network(
                        '$url/uploads/$cleanImage',
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.localizedTitle('ar'),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: appTextPrimary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${NumberFormat('#,###').format(product.price)} د.ع',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionWrap extends StatelessWidget {
  const _OptionWrap({
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<String> values;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children:
          values.map((value) {
            final selected = selectedValue == value;
            return GestureDetector(
              onTap: () => onSelected(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color:
                      selected
                          ? appAccentColor.withValues(alpha: 0.18)
                          : appMutedSurface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? appAccentColor : appBorder(context),
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color:
                        selected
                            ? appTextPrimary(context)
                            : appTextMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.cubit,
    required this.id,
    required this.stock,
    required this.colors,
    required this.sizes,
  });
  final UserCubit cubit;
  final String id;
  final int stock;
  final List<String> colors;
  final List<String> sizes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (cubit.quantity > stock) {
          return;
        }
        if (colors.isNotEmpty && cubit.selectedProductColor == null) {
          showToastInfo(text: 'اختار اللون أولاً', context: context);
          return;
        }
        if (sizes.isNotEmpty && cubit.selectedProductSize == null) {
          showToastInfo(text: 'اختار القياس أولاً', context: context);
          return;
        }
        cubit.addToBasket(
          productId: id,
          quantity: cubit.quantity.toString(),
          selectedColor: cubit.selectedProductColor,
          selectedSize: cubit.selectedProductSize,
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
                Iconsax.shopping_cart,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
