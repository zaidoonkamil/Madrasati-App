import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:madrasati_app/core/widgets/circular_progress.dart';

import '../../../core/styles/themes.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../model/GetNotifications.dart';

class NotificationsUser extends StatelessWidget {
  const NotificationsUser({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) =>
              UserCubit()..getNotifications(context: context),
      child: BlocBuilder<UserCubit, UserStates>(
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final notifications =
              cubit.getNotificationsModel?.logs ?? const <Log>[];
          final localeCode = Localizations.localeOf(context).languageCode;

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: pageBackgroundColor,
              body: Column(
                children: [
                  CustomAppBarBack(
                    title: 'الإشعارات',
                    subtitle: 'آخر التنبيهات والتحديثات الخاصة بك',
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          state is GetNotificationsLoadingState
                              ? const CircularProgressNotifications()
                              : notifications.isEmpty
                              ? const _EmptyNotifications()
                              : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 24),
                                physics: const BouncingScrollPhysics(),
                                itemCount: notifications.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _NotificationCard(
                                    log: notifications[index],
                                    localeCode: localeCode,
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
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.log, required this.localeCode});

  final Log log;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy/M/d').format(log.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: mutedSurfaceColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  log.localizedTitle(localeCode),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: secondPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            log.localizedMessage(localeCode),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: secondTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: mutedSurfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: secondPrimaryColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات حالياً',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'عند وصول أي إشعار جديد سيظهر هنا مباشرة',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondTextColor,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
