import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/constant.dart';
import '../../../core/widgets/show_toast.dart';
import '../../auth/view/login.dart';
import '../model/ProductsModel.dart';
import 'details.dart';

class SearchProductsPage extends StatefulWidget {
  const SearchProductsPage({super.key});

  @override
  State<SearchProductsPage> createState() => _SearchProductsPageState();
}

class _SearchProductsPageState extends State<SearchProductsPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  List<Product> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _searchProducts(_controller.text);
    });
  }

  Future<void> _searchProducts(String query) async {
    final value = query.trim();

    if (value.isEmpty || value.characters.length < 2) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _isLoading = false;
        _hasSearched = value.characters.length >= 2;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final productsModel = await _loadSearchResults(value);

      if (!mounted) return;
      setState(() {
        _results = productsModel.products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _results = [];
      });

      final String message =
          error is DioException
              ? (error.response?.data?['error']?.toString() ??
                  'حدث خطأ أثناء البحث')
              : 'حدث خطأ أثناء البحث';

      showToastError(text: message, context: context);
    }
  }

  Future<ProductsModel> _loadSearchResults(String value) async {
    final response = await DioHelper.getData(
      url: '/products/search',
      query: {'q': value, 'userId': id.isNotEmpty ? id : '0', 'limit': 12},
    );

    final productsModel = ProductsModel.fromJson(response.data);
    if (productsModel.products.isNotEmpty) {
      return productsModel;
    }

    final fallbackResponse = await DioHelper.getData(
      url: '/products/${id.isNotEmpty ? id : '0'}',
      query: {'page': 1, 'limit': 100},
    );

    final fallbackModel = ProductsModel.fromJson(fallbackResponse.data);
    final filteredProducts =
        fallbackModel.products
            .where((product) {
              return _matchesQuery(product, value);
            })
            .take(12)
            .toList();

    return ProductsModel(
      paginationProducts: PaginationProducts(
        totalItems: filteredProducts.length,
        totalPages: filteredProducts.isEmpty ? 0 : 1,
        currentPage: 1,
      ),
      products: filteredProducts,
    );
  }

  bool _matchesQuery(Product product, String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return false;

    final candidates = <String>[
      product.title,
      product.description,
      product.titleAr ?? '',
      product.descriptionAr ?? '',
    ];

    return candidates.any((candidate) {
      return _normalizeSearchText(candidate).contains(normalizedQuery);
    });
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: pageBackgroundColor,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child:
                  !_hasSearched
                      ? _buildMessageState(
                        context,
                        'ابدأ بكتابة اسم المنتج للبحث',
                      )
                      : _results.isEmpty && !_isLoading
                      ? _buildMessageState(context, 'لا توجد نتائج مطابقة')
                      : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildResultCard(context, _results[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => navigateBack(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
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
                child: Text(
                  'البحث عن منتج',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'اكتب اسم القطعة أو المنتج',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.60)),
              prefixIcon:
                  _isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.search_rounded, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: primaryColor, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: secondTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Product product) {
    final String localeCode = Localizations.localeOf(context).languageCode;
    final List<String> images =
        product.images.where((image) => image.trim().isNotEmpty).toList();
    final String imageName =
        images.isNotEmpty ? images.first.replaceAll(RegExp(r'[\[\]]'), '') : '';
    final String priceLabel = NumberFormat('#,###').format(product.price);
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
            isFavorite: product.isFavorite,
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
          borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: secondTextColor,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (token == '') {
                            navigateTo(context, const Login());
                          }
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$priceLabel ${'د.ع'}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Hero(
              tag: 'product-image-${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    imageName.isEmpty
                        ? Container(
                          width: 92,
                          height: 102,
                          color: mutedSurfaceColor,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: secondTextColor,
                            size: 26,
                          ),
                        )
                        : Image.network(
                          '$url/uploads/$imageName',
                          width: 92,
                          height: 102,
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
