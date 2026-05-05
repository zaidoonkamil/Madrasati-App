import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:madrasati_app/features/user/view/complete_shopping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/circular_progress.dart';
import '../../../core/widgets/constant.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

// ═══════════════════════════════════════════════════════
//  PALETTE  (matches Home & Profile)
// ═══════════════════════════════════════════════════════
const _cream = appBackgroundColor;
const _inkDeep = appTextPrimaryColor;
const _accentAmber = appAccentColor;
const _accentRose = appDangerColor;
const _cardBg = appSurfaceColor;
const _softGray = appMutedSurfaceColor;
const _textMuted = appTextMutedColor;

class Basket extends StatelessWidget {
  const Basket({super.key});

  @override
  Widget build(BuildContext context) {
    if (token.isEmpty || id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToastInfo(text: 'سجل الدخول أولاً', context: context);
        if (Navigator.canPop(context)) {
          navigateBack(context);
        }
      });

      return const Scaffold(backgroundColor: _cream);
    }

    return BlocProvider(
      create: (context) => UserCubit()..getBasket(context: context),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final hasItems = cubit.basketModel.isNotEmpty;

          return Scaffold(
            backgroundColor: _cream,
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  CustomAppBarBack(
                    title: 'سلة التسوق',
                    subtitle: 'راجع المنتجات قبل إكمال الطلب',
                  ),
                  Expanded(
                    child: ConditionalBuilder(
                      condition: state is! GetBasketLoadingState,
                      builder: (context) {
                        if (!hasItems) return const _EmptyBasket();

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                          child: Column(
                            children: [
                              // ── Summary card ──
                              _SummaryCard(cubit: cubit)
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideY(
                                    begin: 0.12,
                                    end: 0,
                                    duration: 380.ms,
                                    curve: Curves.easeOutCubic,
                                  ),

                              SizedBox(height: 14),
                              ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cubit.basketModel.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = cubit.basketModel[index];
                                  final image =
                                      item.product.images.isNotEmpty
                                          ? item.product.images.first
                                              .replaceAll(RegExp(r'[\[\]]'), '')
                                          : '';
                                  return _BasketItem(
                                        item: item,
                                        image: image,
                                        index: index,
                                        cubit: cubit,
                                        context: context,
                                      )
                                      .animate(
                                        delay: Duration(
                                          milliseconds: 60 * index,
                                        ),
                                      )
                                      .fadeIn(duration: 280.ms)
                                      .slideX(
                                        begin: 0.06,
                                        end: 0,
                                        duration: 340.ms,
                                        curve: Curves.easeOutCubic,
                                      );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      fallback:
                          (context) => const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: CircularProgressBasket(),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar:
                hasItems
                    ? SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _CheckoutBar(cubit: cubit),
                      ),
                    )
                    : null,
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SUMMARY CARD
// ═══════════════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cubit});
  final UserCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _inkDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Total amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المجموع الكلي',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat('#,###').format(cubit.getTotalPrice()),
                    style: const TextStyle(
                      color: _accentAmber,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'د.ع',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Items count badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'عدد المنتجات',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accentAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accentAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${cubit.basketModel.length} منتج',
                  style: const TextStyle(
                    color: _accentAmber,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  BASKET ITEM CARD
// ═══════════════════════════════════════════════════════
class _BasketItem extends StatelessWidget {
  const _BasketItem({
    required this.item,
    required this.image,
    required this.index,
    required this.cubit,
    required this.context,
  });

  final dynamic item;
  final String image;
  final int index;
  final UserCubit cubit;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softGray),
        boxShadow: [
          BoxShadow(
            color: _inkDeep.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Right: details ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Title row + delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delete button
                    GestureDetector(
                      onTap:
                          () => cubit.deleteBasket(
                            idItem: item.id.toString(),
                            context: context,
                          ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _accentRose.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: _accentRose.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Iconsax.trash,
                          color: _accentRose,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: _inkDeep,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Price row
                Row(
                  children: [
                    Text(
                      NumberFormat(
                        '#,###',
                      ).format(item.product.price * item.quantity),
                      style: const TextStyle(
                        color: _accentAmber,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      'د.ع',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    // Unit price chip
                    const Spacer(),
                    // Total price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _softGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'القطعة ${NumberFormat('#,###').format(item.product.price)} د.ع',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 10,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Qty row
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _softGray,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _QtyBtn(
                            icon: Icons.remove,
                            onTap:
                                () => cubit.minusBasket(
                                  index: index,
                                  context: context,
                                ),
                            filled: false,
                          ),
                          Container(
                            width: 36,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: _inkDeep,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          _QtyBtn(
                            icon: Icons.add,
                            onTap: () => cubit.addBasket(index: index),
                            filled: true,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    Text(
                      'المتوفر ${item.product.stock}',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Left: product image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 96,
              height: 118,
              color: _softGray,
              child:
                  image.isEmpty
                      ? const Icon(
                        Icons.image_not_supported_outlined,
                        color: _textMuted,
                      )
                      : Image.network('$url/uploads/$image', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  QTY BUTTON
// ═══════════════════════════════════════════════════════
class _QtyBtn extends StatelessWidget {
  const _QtyBtn({
    required this.icon,
    required this.onTap,
    required this.filled,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled ? _accentAmber : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: filled ? _inkDeep : _textMuted, size: 17),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CHECKOUT BAR
// ═══════════════════════════════════════════════════════
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cubit});
  final UserCubit cubit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final items =
            cubit.basketModel
                .map(
                  (item) => {
                    'productId': item.productId,
                    'quantity': item.quantity,
                  },
                )
                .toList();
        navigateTo(context, CompleteShopping(items: items));
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: _accentAmber,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _accentAmber.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            // Arrow circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _inkDeep.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Iconsax.arrow_left_2,
                color: _inkDeep,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'إكمال الشراء',
                    style: TextStyle(
                      color: _inkDeep,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'إجمالي الطلب ${NumberFormat('#,###').format(cubit.getTotalPrice())} د.ع',
                    style: TextStyle(
                      color: _inkDeep.withValues(alpha: 0.60),
                      fontSize: 11,
                      fontFamily: 'Cairo',
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

// ═══════════════════════════════════════════════════════
//  EMPTY BASKET
// ═══════════════════════════════════════════════════════
class _EmptyBasket extends StatelessWidget {
  const _EmptyBasket();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _inkDeep,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Iconsax.shopping_bag,
                    size: 40,
                    color: _accentAmber,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            const Text(
              'السلة فارغة حالياً',
              style: TextStyle(
                color: _inkDeep,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 280.ms),
            const SizedBox(height: 8),
            const Text(
              'أضف بعض المنتجات ثم ارجع هنا لإكمال الطلب',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textMuted,
                fontSize: 13,
                height: 1.7,
                fontFamily: 'Cairo',
              ),
            ).animate().fadeIn(delay: 220.ms, duration: 280.ms),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _accentAmber,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'تسوّق الآن',
                  style: TextStyle(
                    color: _inkDeep,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}
