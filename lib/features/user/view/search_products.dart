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
import '../model/CatModel.dart';
import '../model/ProductsModel.dart';
import 'details.dart';

class SearchProductsPage extends StatefulWidget {
  const SearchProductsPage({super.key});

  @override
  State<SearchProductsPage> createState() => _SearchProductsPageState();
}

class _SearchSort {
  static const relevance = 'relevance';
  static const priceLow = 'price_low';
  static const priceHigh = 'price_high';
  static const newest = 'newest';
  static const name = 'name';
}

class _SearchProductsPageState extends State<SearchProductsPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  List<Product> _results = [];
  List<CatModel> _categories = [];
  CatModel? _selectedCategory;
  bool _availableOnly = false;
  bool _favoritesOnly = false;
  bool _filtersExpanded = false;
  String _sortBy = _SearchSort.relevance;
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _loadCategories();
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _runSearchSoon();
  }

  void _runSearchSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _searchProducts(_controller.text);
    });
  }

  Future<void> _searchProducts(String query) async {
    final value = query.trim();

    if (!_hasActiveFilters && (value.isEmpty || value.characters.length < 2)) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _isLoading = false;
        _hasSearched = false;
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
      query: {
        'q': value,
        'userId': id.isNotEmpty ? id : '0',
        'limit': 100,
        if (_selectedCategory != null)
          'categoryId': _selectedCategory!.id.toString(),
        if (_minPriceController.text.trim().isNotEmpty)
          'minPrice': _minPriceController.text.trim(),
        if (_maxPriceController.text.trim().isNotEmpty)
          'maxPrice': _maxPriceController.text.trim(),
        'availableOnly': _availableOnly.toString(),
        'favoritesOnly': _favoritesOnly.toString(),
        'sortBy': _sortBy,
      },
    );

    return ProductsModel.fromJson(response.data);
  }

  Future<void> _loadCategories() async {
    try {
      final response = await DioHelper.getData(url: '/categories');
      final rawCategories =
          (response.data as List)
              .map((item) => CatModel.fromJson(item as Map<String, dynamic>))
              .toList();
      if (!mounted) return;
      setState(() {
        _categories = _flattenCategories(rawCategories);
      });
    } catch (_) {}
  }

  List<CatModel> _flattenCategories(List<CatModel> categories) {
    final result = <CatModel>[];
    for (final category in categories) {
      result.add(category);
      result.addAll(category.subcategories);
    }
    return result;
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _availableOnly ||
        _favoritesOnly ||
        _minPriceController.text.trim().isNotEmpty ||
        _maxPriceController.text.trim().isNotEmpty ||
        _sortBy != _SearchSort.relevance;
  }

  int get _activeFiltersCount {
    var count = 0;
    if (_selectedCategory != null) count++;
    if (_availableOnly) count++;
    if (_favoritesOnly) count++;
    if (_minPriceController.text.trim().isNotEmpty) count++;
    if (_maxPriceController.text.trim().isNotEmpty) count++;
    if (_sortBy != _SearchSort.relevance) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _availableOnly = false;
      _favoritesOnly = false;
      _sortBy = _SearchSort.relevance;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    _searchProducts(_controller.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appPageColor(context),
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
          const SizedBox(height: 12),
          _buildFilterToggle(),
          if (_filtersExpanded) ...[
            const SizedBox(height: 12),
            _buildFiltersPanel(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Row(
      children: [
        if (_hasActiveFilters)
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'مسح الفلاتر',
              style: TextStyle(
                color: appAccentColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_activeFiltersCount > 0) ...[
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: appAccentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _activeFiltersCount.toString(),
                      style: const TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Text(
                  'الفلاتر',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _filtersExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.tune_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersPanel(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<CatModel?>(
            value: _selectedCategory,
            isExpanded: true,
            dropdownColor: appTextPrimaryColor,
            decoration: _filterInputDecoration(''),
            items: [
              const DropdownMenuItem<CatModel?>(
                value: null,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('كل التصنيفات'),
                ),
              ),
              ..._categories.map(
                (category) => DropdownMenuItem<CatModel?>(
                  value: category,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(category.localizedName(localeCode)),
                  ),
                ),
              ),
            ],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (value) {
              setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _priceField(
                  controller: _maxPriceController,
                  hint: 'أعلى سعر',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _priceField(
                  controller: _minPriceController,
                  hint: 'أقل سعر',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _sortBy,
            isExpanded: true,
            dropdownColor: appTextPrimaryColor,
            decoration: _filterInputDecoration(''),
            items: const [
              DropdownMenuItem(
                value: _SearchSort.relevance,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('الأقرب للبحث'),
                ),
              ),
              DropdownMenuItem(
                value: _SearchSort.newest,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('الأحدث'),
                ),
              ),
              DropdownMenuItem(
                value: _SearchSort.priceLow,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('السعر من الأقل'),
                ),
              ),
              DropdownMenuItem(
                value: _SearchSort.priceHigh,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('السعر من الأعلى'),
                ),
              ),
              DropdownMenuItem(
                value: _SearchSort.name,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('الاسم'),
                ),
              ),
            ],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _sortBy = value);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterSwitch(
                  label: 'المفضلة فقط',
                  value: _favoritesOnly,
                  enabled: token.isNotEmpty,
                  onChanged: (value) {
                    setState(() => _favoritesOnly = value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterSwitch(
                  label: 'المتوفر فقط',
                  value: _availableOnly,
                  onChanged: (value) {
                    setState(() => _availableOnly = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() => _filtersExpanded = false);
                _searchProducts(_controller.text);
              },
              icon: const Icon(Icons.filter_alt_rounded, size: 19),
              label: const Text(
                'تطبيق الفلترة',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: appAccentColor,
                foregroundColor: appTextPrimaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _filterInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: appAccentColor, width: 1.2),
      ),
    );
  }

  Widget _priceField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.end,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      onChanged: (_) {
        setState(() {});
      },
      decoration: _filterInputDecoration(hint),
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
            colors: product.colors,
            sizes: product.sizes,
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
          color: appSurface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appBorder(context)),
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
                    style: TextStyle(
                      color: appTextMuted(context),
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
                          color: appMutedSurface(context),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: appTextMuted(context),
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

class _FilterSwitch extends StatelessWidget {
  const _FilterSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? () => onChanged(!value) : null,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color:
                value
                    ? appAccentColor.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  value
                      ? appAccentColor.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? appAccentColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        value
                            ? appAccentColor
                            : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                child:
                    value
                        ? const Icon(
                          Icons.check_rounded,
                          color: appTextPrimaryColor,
                          size: 14,
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
