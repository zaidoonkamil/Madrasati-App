import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class LowStockProductsPage extends StatelessWidget {
  const LowStockProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              AdminCubit()..getLowStockProducts(context: context, reset: true),
      child: const _LowStockProductsView(),
    );
  }
}

class _LowStockProductsView extends StatefulWidget {
  const _LowStockProductsView();

  @override
  State<_LowStockProductsView> createState() => _LowStockProductsViewState();
}

class _LowStockProductsViewState extends State<_LowStockProductsView> {
  final TextEditingController _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminStates>(
      builder: (context, state) {
        final cubit = AdminCubit.get(context);
        final products = cubit.lowStockProductsModel?.products ?? [];
        final isInitialLoading =
            cubit.lowStockProductsModel == null &&
            state is GetProductsLoadingState;

        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: appPageColor(context),
            body: Column(
              children: [
                const CustomAppBarBack(
                  title: 'تنبيهات المخزون',
                  subtitle: 'منتجات قاربت على النفاد أو خلصت',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _FilterCard(
                    controller: _filterController,
                    onApply:
                        () => cubit.getLowStockProducts(
                          context: context,
                          maxStock: _filterController.text.trim(),
                          reset: true,
                        ),
                    onClear: () {
                      _filterController.clear();
                      cubit.getLowStockProducts(context: context, reset: true);
                    },
                  ),
                ),
                Expanded(
                  child:
                      isInitialLoading
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                          ? Center(
                            child: Text(
                              'لا توجد منتجات ضمن هذا الفلتر',
                              style: TextStyle(
                                color: appTextMuted(context),
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                          : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification.metrics.pixels >=
                                      notification.metrics.maxScrollExtent -
                                          140 &&
                                  !cubit.isLastPageLowStockProducts &&
                                  !cubit.isLoadingMoreLowStockProducts) {
                                cubit.getLowStockProducts(
                                  context: context,
                                  page:
                                      (cubit.currentPageLowStockProducts + 1)
                                          .toString(),
                                );
                              }
                              return false;
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  products.length +
                                  (cubit.isLastPageLowStockProducts ? 0 : 1),
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                if (index >= products.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _LowStockProductTile(
                                  product: products[index],
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.controller,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorder(context)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'مسح الفلتر',
            onPressed: onClear,
            icon: const Icon(Iconsax.close_circle),
          ),
          const SizedBox(width: 6),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: appAccentColor,
              foregroundColor: appTextPrimaryColor,
            ),
            onPressed: onApply,
            icon: const Icon(Iconsax.filter, size: 18),
            label: const Text('تطبيق'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                hintText: 'الكمية أقل من أو تساوي',
                prefixIcon: Icon(Iconsax.box),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockProductTile extends StatelessWidget {
  const _LowStockProductTile({required this.product});

  final dynamic product;

  @override
  Widget build(BuildContext context) {
    final isOut = product.stock <= 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorder(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (isOut ? appDangerColor : appAccentColor).withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isOut ? Iconsax.warning_2 : Iconsax.warning_2,
              color: isOut ? appDangerColor : appAccentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.title,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appTextPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: ${product.id}',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: appTextMuted(context), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: 'المخزون',
                      value: product.stock.toString(),
                      color: isOut ? appDangerColor : appAccentColor,
                    ),
                    _InfoChip(
                      label: 'حد التنبيه',
                      value: product.lowStockAlert.toString(),
                      color: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
