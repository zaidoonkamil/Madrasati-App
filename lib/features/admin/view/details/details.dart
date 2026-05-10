import 'package:madrasati_app/features/admin/view/add_ads.dart';
import 'package:madrasati_app/features/admin/view/details/add_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';
import '../add_cat.dart';
import 'add_admin.dart';
import 'add_user.dart';
import 'all_person.dart';
import 'all_user_chat_admin.dart';
import 'stats.dart';
import 'whatsapp_admin.dart';

class Details extends StatelessWidget {
  const Details({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appPageColor(context),
              body: Column(
                children: [
                  const CustomAppBarAdmin(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _menuCard(
                                  context,
                                  title: "إضافة مستخدم",
                                  icon: Iconsax.user_add,
                                  onTap: () => navigateTo(context, AddUser()),
                                ),
                                _menuCard(
                                  context,
                                  title: "إضافة أدمن",
                                  icon: Iconsax.add,
                                  onTap: () => navigateTo(context, AddAdmin()),
                                ),
                                _menuCard(
                                  context,
                                  title: "رؤية المستخدمين",
                                  icon: Iconsax.people,
                                  onTap: () => navigateTo(context, AllPerson()),
                                ),
                                _menuCard(
                                  context,
                                  title: "الدردشات",
                                  icon: Iconsax.message_text,
                                  onTap:
                                      () => navigateTo(
                                        context,
                                        AllUserChatAdmin(),
                                      ),
                                ),
                                _menuCard(
                                  context,
                                  title: "الإحصائيات",
                                  icon: Iconsax.chart_2,
                                  onTap: () => navigateTo(context, Stats()),
                                ),
                                _menuCard(
                                  context,
                                  title: "ربط واتساب",
                                  icon: Iconsax.message_programming,
                                  onTap:
                                      () => navigateTo(
                                        context,
                                        const WhatsAppAdminPage(),
                                      ),
                                ),
                                _menuCard(
                                  context,
                                  title: "إضافة منتج",
                                  icon: Iconsax.additem,
                                  onTap:
                                      () => navigateTo(context, AddProducts()),
                                ),
                                _menuCard(
                                  context,
                                  title: "إضافة قسم",
                                  icon: Iconsax.add_square,
                                  onTap: () => navigateTo(context, AddCat()),
                                ),
                                _menuCard(
                                  context,
                                  title: "إضافة إعلان",
                                  icon: Iconsax.activity,
                                  onTap: () => navigateTo(context, AddAds()),
                                ),
                              ],
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
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

  Widget _menuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 24,
        height: 120,
        decoration: BoxDecoration(
          color: appSurface(context),
          border: Border.all(color: appBorder(context)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: appTextPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
