import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:madrasati_app/features/auth/view/login.dart';

import '../../../core/styles/themes.dart';
import '../../../core/utils/delivery_type.dart';
import '../../../core/utils/order_status.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/circular_progress.dart';
import '../../../core/widgets/constant.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) =>
              UserCubit()..getOrdersUser(context: context, page: '1'),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final bool isGuest = token == '';

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appPageColor(context),
              body: Column(
                children: [
                  const CustomAppBar(
                    title: 'طلباتي',
                    subtitle: 'تابع حالة طلباتك السابقة والحالية',
                  ),
                  Expanded(
                    child:
                        isGuest
                            ? const _GuestOrdersState()
                            : ConditionalBuilder(
                              condition: state is! GetOrdersUserLoadingState,
                              builder: (context) {
                                return ConditionalBuilder(
                                  condition: cubit.ordersUser.isNotEmpty,
                                  builder: (c) {
                                    return SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        28,
                                      ),
                                      child: Column(
                                        children: [
                                          _OrdersHeader(
                                            totalOrders:
                                                cubit.ordersUser.length,
                                          ),
                                          SizedBox(height: 14),
                                          ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                cubit
                                                    .ordersUserModel!
                                                    .orders
                                                    .length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(height: 12),
                                            itemBuilder: (context, index) {
                                              if (index ==
                                                      cubit
                                                              .ordersUserModel!
                                                              .orders
                                                              .length -
                                                          1 &&
                                                  !cubit.isLastPageOrdersUser) {
                                                cubit.getOrdersUser(
                                                  page:
                                                      (cubit.currentPageOrdersUser +
                                                              1)
                                                          .toString(),
                                                  context: context,
                                                );
                                              }

                                              final order =
                                                  cubit
                                                      .ordersUserModel!
                                                      .orders[index];

                                              final formattedDate = DateFormat(
                                                'yyyy/M/d',
                                              ).format(order.createdAt);

                                              return Container(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: appSurface(context),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color: appBorder(context),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: secondPrimaryColor
                                                          .withValues(
                                                            alpha: 0.04,
                                                          ),
                                                      blurRadius: 20,
                                                      offset: const Offset(
                                                        0,
                                                        10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                orderStatusBackground(
                                                                  order.status,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  100,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            orderStatusLabel(
                                                              order.status,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                '${order.id}#',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: const TextStyle(
                                                                  color:
                                                                      secondPrimaryColor,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'تاريخ الطلب $formattedDate',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                  color:
                                                                      appTextMuted(
                                                                        context,
                                                                      ),
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 14),
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 10,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: appMutedSurface(
                                                          context,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        deliveryTypeLabel(
                                                          order.deliveryType,
                                                        ),
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          color: appTextPrimary(
                                                            context,
                                                          ),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: _OrderStat(
                                                            title: 'عدد القطع',
                                                            value:
                                                                order.totalItems
                                                                    .toString(),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: _OrderStat(
                                                            title:
                                                                'المجموع الكلي',
                                                            value:
                                                                '${NumberFormat('#,###').format(order.totalPrice)} د.ع',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  fallback:
                                      (context) => const _EmptyOrdersState(),
                                );
                              },
                              fallback:
                                  (context) => const CircularProgressOrder(),
                            ),
                  ),
                  SizedBox(height: 60,),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.totalOrders});

  final int totalOrders;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [appDarkGradientStartColor, appDarkGradientEndColor],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'طلباتي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لديك $totalOrders طلبات محفوظة في حسابك',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStat extends StatelessWidget {
  const _OrderStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: appMutedSurface(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              color: appTextMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: secondPrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestOrdersState extends StatelessWidget {
  const _GuestOrdersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: appMutedSurface(context),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.login_rounded,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'سجل الدخول لمتابعة طلباتك',
              style: const TextStyle(
                color: secondPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر هنا جميع الطلبات الحالية والسابقة بعد تسجيل الدخول.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTextMuted(context),
                fontSize: 13,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: () {
                navigateTo(context, Login());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: secondPrimaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'تسجيل الدخول',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: appMutedSurface(context),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'لا توجد طلبات بعد',
              style: const TextStyle(
                color: secondPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'عند إتمام أول طلب ستظهر بياناته هنا بشكل منظم.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTextMuted(context),
                fontSize: 13,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
