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

  Widget _buildOrderCard(
    BuildContext context,
    AdminCubit cubit,
    dynamic order,
  ) {
    final formattedDate = DateFormat('yyyy/M/d').format(order.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: containerColor,
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
                      valueStyle: const TextStyle(
                        color: secondTextColor,
                        fontSize: 12,
                      ),
                      labelStyle: const TextStyle(
                        color: secondTextColor,
                        fontSize: 12,
                      ),
                    ),
                    _buildInfoLine(
                      order.totalItems.toString(),
                      'عدد الطلبات',
                      valueStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      labelStyle: const TextStyle(
                        color: secondTextColor,
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
                    Text(order.phone, textAlign: TextAlign.end),
                    Text(order.address, textAlign: TextAlign.end),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mutedSurfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        deliveryTypeLabel(order.deliveryType),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: appTextPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Image.asset('assets/images/Group 142.png', fit: BoxFit.fill),
            ],
          ),
          const SizedBox(height: 8),
          Container(width: double.maxFinite, height: 1, color: Colors.grey),
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
                  width: 260,
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
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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
                                  color: Colors.grey.shade200,
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
          backgroundColor: Colors.white,
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
