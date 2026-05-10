import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/circular_progress.dart';
import '../../../core/widgets/constant.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../model/CatModel.dart';
import '../model/GetAdsModel.dart';
import 'ads.dart';
import 'all_categories.dart';
import 'all_products.dart';
import 'search_products.dart';
import 'subcategories.dart';
import 'widgets/product_grid_card.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static int currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              UserCubit()
                ..getGreeting()
                ..getSocialSettings(context: context)
                ..getAds(context: context)
                ..getCat(context: context)
                ..scrol()
                ..getFeaturedProducts(context: context, page: '1', limit: 8),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {
          if (state is AddToBasketSuccessState) {
            _showSuccessSnackBar(context, 'تمت إضافة المنتج إلى السلة بنجاح');
          }
        },
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final localeCode = Localizations.localeOf(context).languageCode;

          return Scaffold(
            backgroundColor: appPageColor(context),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  const CustomAppBar(),
                  Expanded(
                    child:
                        cubit.getCatModel.isEmpty
                            ? const CircularProgressHome()
                            : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  _buildSearchBar(context)
                                      .animate()
                                      .fadeIn(duration: 300.ms)
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 400.ms,
                                        curve: Curves.easeOutCubic,
                                      ),
                                  if (cubit.showSocialLinks)
                                    _buildSocialLinks(context)
                                        .animate()
                                        .fadeIn(delay: 80.ms, duration: 260.ms)
                                        .slideY(
                                          begin: 0.16,
                                          end: 0,
                                          duration: 360.ms,
                                          curve: Curves.easeOutCubic,
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      120,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // ── Hero Banner ──
                                        _buildHeroBanner(
                                              context,
                                              cubit,
                                              localeCode,
                                            )
                                            .animate()
                                            .fadeIn(
                                              delay: 60.ms,
                                              duration: 320.ms,
                                            )
                                            .slideY(
                                              begin: 0.15,
                                              end: 0,
                                              duration: 420.ms,
                                              curve: Curves.easeOutCubic,
                                            ),

                                        // ── Categories ──
                                        _buildSectionHeader(
                                          title: 'التصنيفات',
                                          actionLabel: 'عرض الكل',
                                          onTap:
                                              () => navigateTo(
                                                context,
                                                AllCategoriesPage(
                                                  categories:
                                                      List<CatModel>.from(
                                                        cubit.getCatModel,
                                                      ),
                                                  useHomeAppBar: false,
                                                ),
                                              ), context: context,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildCategories(
                                              cubit,
                                              context,
                                              localeCode,
                                            )
                                            .animate()
                                            .fadeIn(
                                              delay: 200.ms,
                                              duration: 300.ms,
                                            )
                                            .slideX(
                                              begin: 0.1,
                                              end: 0,
                                              duration: 400.ms,
                                              curve: Curves.easeOutCubic,
                                            ),

                                        const SizedBox(height: 18),

                                        // ── Featured Products ──
                                        _buildSectionHeader(
                                          title: 'منتجات مميزة',
                                          actionLabel: 'عرض الكل',
                                          onTap:
                                              () => navigateTo(
                                                context,
                                                const AllProductsPage(),
                                              ), context: context,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildProducts(
                                              cubit,
                                              context,
                                              localeCode,
                                            )
                                            .animate()
                                            .fadeIn(
                                              delay: 300.ms,
                                              duration: 320.ms,
                                            )
                                            .slideY(
                                              begin: 0.1,
                                              end: 0,
                                              duration: 440.ms,
                                              curve: Curves.easeOutCubic,
                                            ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
      decoration: BoxDecoration(color: appHeaderBackground(context)),
      child: GestureDetector(
        onTap: () => navigateTo(context, const SearchProductsPage()),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Iconsax.filter,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ابحث في المكتبة',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'أقلام، دفاتر، ألوان، لوازم مكتبية',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: homeAccentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.search_normal,
                  color: homeTextColor,
                  size: 18,
                ),
              ),

              // Filter icon
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  HERO BANNER (ADS CAROUSEL)
  // ─────────────────────────────────────────────────────
  Widget _buildSocialLinks(BuildContext context) {
    final whatsAppNumber =
        phoneWoner.startsWith('964') ? phoneWoner : '964$phoneWoner';
    final links = [
      _SocialLink(
        label: 'إنستغرام',
        icon: FontAwesomeIcons.instagram,
        color: const Color(0xFFE4405F),
        url: 'https://www.instagram.com/madrasaty2019/',
      ),
      _SocialLink(
        label: 'فيسبوك',
        icon: FontAwesomeIcons.facebookF,
        color: const Color(0xFF1877F2),
        url: 'https://www.facebook.com/madrasatycenter',
      ),
      _SocialLink(
        label: 'تيك توك',
        icon: FontAwesomeIcons.tiktok,
        color: Colors.white,
        url: 'https://www.tiktok.com/@madrasaty2019',
      ),
      _SocialLink(
        label: 'واتساب',
        icon: FontAwesomeIcons.whatsapp,
        color: const Color(0xFF25D366),
        url:
            'https://api.whatsapp.com/send/?phone=$whatsAppNumber&text&type=phone_number&app_absent=0',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(
        color: homeTextColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Row(
        children:
            links
                .map(
                  (link) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _SocialLinkButton(
                        link: link,
                        onTap: () => _openSocialLink(context, link.url),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Future<void> _openSocialLink(BuildContext context, String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      showToastError(text: 'تعذر فتح الرابط', context: context);
    }
  }

  Widget _buildHeroBanner(
    BuildContext context,
    UserCubit cubit,
    String localeCode,
  ) {
    return ConditionalBuilder(
      condition: cubit.getAdsModel.isNotEmpty,
      builder: (context) {
        final totalImages = cubit.getAdsModel.fold<int>(
          0,
          (sum, ad) => sum + ad.images.length,
        );

        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  CarouselSlider(
                    items:
                        cubit.getAdsModel
                            .expand<Widget>(
                              (GetAds ad) => ad.images.map((String imageUrl) {
                                final formattedDate = DateFormat(
                                  'yyyy/M/d',
                                ).format(ad.createdAt);
                                final localizedTitle = ad.localizedTitle(
                                  localeCode,
                                );
                                final localizedDescription = ad
                                    .localizedDescription(localeCode);

                                return GestureDetector(
                                  onTap:
                                      () => navigateTo(
                                        context,
                                        AdsUser(
                                          tittle: localizedTitle,
                                          desc: localizedDescription,
                                          image: imageUrl,
                                          time: formattedDate,
                                        ),
                                      ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        "$url/uploads/$imageUrl",
                                        fit: BoxFit.cover,
                                      ),
                                      // Warm gradient overlay
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              homeHeroOverlayMidColor,
                                              homeHeroOverlayEndColor,
                                            ],
                                            stops: [0.3, 0.6, 1.0],
                                          ),
                                        ),
                                      ),
                                      // Text overlay
                                      Positioned(
                                        right: 20,
                                        left: 20,
                                        bottom: 12,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: homeAccentColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'عرض خاص',
                                                style: TextStyle(
                                                  color: homeTextColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              localizedTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                height: 1.25,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              localizedDescription,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.72,
                                                ),
                                                fontSize: 9,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            )
                            .toList(),
                    options: CarouselOptions(
                      height: 160,
                      viewportFraction: 1,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      onPageChanged: (index, reason) {
                        currentIndex = index;
                        cubit.slid();
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Dot indicators
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalImages,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: currentIndex == index ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color:
                        currentIndex == index
                            ? homeAccentColor
                            : homeTextColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      fallback: (context) => const SizedBox.shrink(),
    );
  }

  // ─────────────────────────────────────────────────────
  //  SECTION HEADER
  // ─────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required BuildContext context,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (actionLabel != null && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: homeAccentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: homeAccentColor.withOpacity(0.3)),
              ),
              child: Text(
                actionLabel,
                style:  TextStyle(
                  color: appTextPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                textAlign: TextAlign.end,
                style:  TextStyle(
                  color: appTextPrimary(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 20,
                decoration: BoxDecoration(
                  color: homeAccentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  //  CATEGORIES
  // ─────────────────────────────────────────────────────
  Widget _buildCategories(
    UserCubit cubit,
    BuildContext context,
    String localeCode,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemCount: cubit.getCatModel.length,
        itemBuilder: (context, i) {
          final rawImageUrl = cubit.getCatModel[i].images[0];
          final cleanImageUrl = rawImageUrl.replaceAll(RegExp(r'[\[\]]'), '');

          return GestureDetector(
            onTap:
                () => navigateTo(
                  context,
                  SubCategoriesPage(parentCategory: cubit.getCatModel[i]),
                ),
            child: Container(
              width: 76,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: appSurface(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: homeBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: homeTextColor.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: homeBorderColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.network(
                      "$url/uploads/$cleanImageUrl",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      cubit.getCatModel[i].localizedName(localeCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style:  TextStyle(
                        color: appTextPrimary(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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

  // ─────────────────────────────────────────────────────
  //  PRODUCTS GRID
  // ─────────────────────────────────────────────────────
  Widget _buildProducts(
    UserCubit cubit,
    BuildContext context,
    String localeCode,
  ) {
    if (cubit.products.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: cubit.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.61,
      ),
      itemBuilder: (context, index) {
        final product = cubit.products[index];
        return UserProductGridCard(
          cubit: cubit,
          productId: product.id.toString(),
          sellerId: product.seller.id.toString(),
          title: product.localizedTitle(localeCode),
          description: product.localizedDescription(localeCode),
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
    );
  }
}

class _SocialLink {
  const _SocialLink({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String url;
}

class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({required this.link, required this.onTap});

  final _SocialLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: link.label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.11)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(link.icon, color: link.color, size: 18),
              const SizedBox(height: 4),
              Text(
                link.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
