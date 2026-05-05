import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/styles/themes.dart';
import '../../../core/widgets/app_bar.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'details_orders_Admin.dart';

class OrdersAdmin extends StatelessWidget {
  const OrdersAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AdminCubit(),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            top: false,
            child: Scaffold(
              body: Column(
                children: [
                  CustomAppBarAdmin(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatusCard(
                                    label: 'قيد الانتظار',
                                    onTap: () {
                                      navigateTo(
                                        context,
                                        const DetailsOrdersAdmin(
                                          status: 'pending',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _StatusCard(
                                    label: 'قيد التوصيل',
                                    onTap: () {
                                      navigateTo(
                                        context,
                                        const DetailsOrdersAdmin(
                                          status: 'delivery',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatusCard(
                                    label: 'ملغي',
                                    onTap: () {
                                      navigateTo(
                                        context,
                                        const DetailsOrdersAdmin(
                                          status: 'cancelled',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _StatusCard(
                                    label: 'مكتمل',
                                    onTap: () {
                                      navigateTo(
                                        context,
                                        const DetailsOrdersAdmin(
                                          status: 'completed',
                                        ),
                                      );
                                    },
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primaryColor,
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
