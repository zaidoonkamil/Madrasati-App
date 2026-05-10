import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:madrasati_app/core/network/remote/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/utils/delivery_type.dart';
import '../../../core/utils/order_status.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/circular_progress.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../model/OrdersAgentModel.dart';
import '../services/order_invoice_service.dart';

class DetailsOrdersAdmin extends StatelessWidget {
  const DetailsOrdersAdmin({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) =>
              AdminCubit()
                ..getOrdersAdmin(context: context, page: '1', status: status),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = AdminCubit.get(context);

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appPageColor(context),
              body: Column(
                children: [
                  const CustomAppBarBack(
                    title: 'تفاصيل الطلبات',
                    subtitle: 'تابع الطلبات حسب الحالة الحالية',
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ConditionalBuilder(
                      condition: state is! GetOrdersAdminLoadingState,
                      builder: (context) {
                        final orders = cubit.ordersAdminModel?.orders ?? [];

                        return ConditionalBuilder(
                          condition: orders.isNotEmpty,
                          builder: (context) {
                            return ListView.separated(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: orders.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return _buildOrderCard(context, cubit, order);
                              },
                            );
                          },
                          fallback:
                              (context) => const Center(
                                child: Text('لا يوجد منتجات ليتم عرضها'),
                              ),
                        );
                      },
                      fallback: (context) => const CircularProgressOrder(),
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

  Widget _buildOrderCard(BuildContext context, AdminCubit cubit, Order order) {
    final formattedDate = DateFormat('yyyy/M/d').format(order.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        border: Border.all(color: appBorder(context), width: 1),
        borderRadius: BorderRadius.circular(8),
        color: appSurface(context),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _handleStatusTap(context, cubit, order),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: orderStatusBackground(order.status),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      orderStatusLabel(order.status),
                      style: const TextStyle(fontSize: 10, color: primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildInfoLine('${order.id}#', 'طلب رقم'),
                    _buildInfoLine(
                      formattedDate,
                      'تم الطلب',
                      valueStyle: TextStyle(
                        color: appTextMuted(context),
                        fontSize: 12,
                      ),
                      labelStyle: TextStyle(
                        color: appTextMuted(context),
                        fontSize: 12,
                      ),
                    ),
                    _buildInfoLine(
                      order.totalItems.toString(),
                      'عدد الطلبات',
                      valueStyle: TextStyle(
                        color: appTextPrimary(context),
                        fontSize: 13,
                      ),
                      labelStyle: TextStyle(
                        color: appTextMuted(context),
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat(
                            '#,###',
                          ).format(order.totalPrice).toString(),
                          style: const TextStyle(
                            color: secondPrimaryColor,
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          ' د.ع',
                          style: TextStyle(
                            color: secondPrimaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (order.discountAmount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'خصم ${NumberFormat('#,###').format(order.discountAmount)} د.ع${order.couponCode == null ? '' : ' - ${order.couponCode}'}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: appSuccessColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    Text(order.phone, textAlign: TextAlign.end),
                    if (order.secondaryPhone.isNotEmpty)
                      Text(order.secondaryPhone, textAlign: TextAlign.end),
                    Text(order.address, textAlign: TextAlign.end),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: appMutedSurface(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        deliveryTypeLabel(order.deliveryType),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: appTextPrimary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap:
                            () =>
                                const OrderInvoiceService().shareInvoice(order),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: appAccentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                color: appTextPrimaryColor,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'فاتورة PDF',
                                style: TextStyle(
                                  color: appTextPrimaryColor,
                                  fontSize: 12,
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
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: appAccentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: appAccentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: appAccentColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.maxFinite,
            height: 1,
            color: appBorder(context),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final item = order.items[i];
                final hasImage = item.productAgent.images.isNotEmpty;

                return SizedBox(
                  width: 270,
                  child: Row(
                    children: [
                      Text('${i + 1}#'),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: appBorder(context),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'ID: ${item.productAgent.id}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 11),
                              ),
                              if (hasImage)
                                Image.network(
                                  '$url/uploads/${item.productAgent.images[0]}',
                                  width: 60,
                                  height: 60,
                                )
                              else
                                Container(
                                  width: 60,
                                  height: 60,
                                  color: appMutedSurface(context),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.productAgent.title.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(height: 1.3),
                                    ),

                                    const SizedBox(height: 4),
                                    Text(
                                      'السعر : ${item.priceAtOrder}',
                                      textAlign: TextAlign.end,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'العدد : ${item.quantity}',
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(
    String value,
    String label, {
    TextStyle? valueStyle,
    TextStyle? labelStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        ),
        const SizedBox(width: 4),
        Text(' : $label', overflow: TextOverflow.ellipsis, style: labelStyle),
      ],
    );
  }

  void _handleStatusTap(BuildContext context, AdminCubit cubit, dynamic order) {
    if (status == 'pending') {
      cubit.updateOrder(
        context: context,
        id: order.id.toString(),
        status: 'delivery',
      );
      return;
    }

    if (status != 'delivery') {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: appSurface(context),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('الى اي حالة تود تحديث الطلب'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      cubit.updateOrder(
                        context: context,
                        id: order.id.toString(),
                        status: 'cancelled',
                      );
                      navigateBack(dialogContext);
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.redAccent,
                      ),
                      child: Text(
                        orderStatusLabel('cancelled'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      cubit.updateOrder(
                        context: context,
                        id: order.id.toString(),
                        status: 'completed',
                      );
                      navigateBack(dialogContext);
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primaryColor,
                      ),
                      child: Text(
                        orderStatusLabel('completed'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
