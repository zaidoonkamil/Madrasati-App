import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:madrasati_app/core/widgets/show_toast.dart';
import 'package:madrasati_app/features/user/view/favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/styles/themes.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/constant.dart';
import '../../auth/view/login.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../model/ProfileModel.dart';

// ═══════════════════════════════════════════════════════
//  PALETTE (matches Home page)
// ═══════════════════════════════════════════════════════
const _cream = appBackgroundColor;
const _inkDeep = appTextPrimaryColor;
const _inkMid = appTextSecondaryColor;
const _accentAmber = appAccentColor;
const _accentGreen = appSuccessColor;
const _accentRose = appDangerColor;
const _cardBg = appSurfaceColor;
const _softGray = appMutedSurfaceColor;
const _textMuted = appTextMutedColor;

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit()..getProfile(context: context),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final bool isLoggedIn = token != '';
          final bool isAdmin = adminOrUser == 'admin';

          return Scaffold(
            backgroundColor: _cream,
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  // ── App Bar ──
                  const CustomAppBar(
                    title: 'حسابي',
                    subtitle: 'إدارة بياناتك وتفضيلاتك',
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                        child: Column(
                          children: [
                            // ── Profile Header card ──
                            (isLoggedIn
                                    ? cubit.profileModel != null
                                        ? _ProfileHeader(cubit: cubit)
                                        : const _ProfileHeaderSkeleton()
                                    : const _GuestHeader())
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideY(
                                  begin: 0.15,
                                  end: 0,
                                  duration: 400.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            const SizedBox(height: 10),

                            // ── Stats Row (only when logged in) ──
                            if (isLoggedIn && cubit.profileModel != null)
                              _StatsRow(profile: cubit.profileModel!)
                                  .animate()
                                  .fadeIn(delay: 80.ms, duration: 280.ms),

                            if (isLoggedIn && cubit.profileModel != null)
                              const SizedBox(height: 14),

                            // ── Section label ──
                            _SectionLabel(
                              label: 'الإعدادات والمزيد',
                            ).animate().fadeIn(delay: 120.ms, duration: 260.ms),

                            const SizedBox(height: 10),

                            // ── WhatsApp tile ──
                            _ActionTile(
                                  title: 'واتساب',
                                  subtitle: 'دردش معنا مباشرة عبر واتساب',
                                  icon: FontAwesomeIcons.whatsapp,
                                  accentColor: _accentGreen,
                                  onTap: () async {
                                    final uri = Uri.parse(
                                      'https://api.whatsapp.com/send/?phone=9647703272065&text&type=phone_number&app_absent=0',
                                    );
                                    final opened = await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    if (!opened && context.mounted) {
                                      showToastError(
                                        text: 'تعذر فتح الرابط',
                                        context: context,
                                      );
                                    }
                                  },
                                )
                                .animate()
                                .fadeIn(delay: 160.ms, duration: 260.ms)
                                .slideX(
                                  begin: 0.06,
                                  end: 0,
                                  duration: 340.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            const SizedBox(height: 10),

                            // ── Favorites tile ──
                            if (!isAdmin)
                              _ActionTile(
                                    title: 'المفضلة',
                                    subtitle:
                                        'المنتجات التي حفظتها للرجوع إليها',
                                    icon: Iconsax.heart,
                                    accentColor: _accentRose,
                                    onTap: () {
                                      if (isLoggedIn) {
                                        navigateTo(context, Favorites());
                                      } else {
                                        showToastInfo(
                                          text: 'يجب عليك تسجيل الدخول أولاً',
                                          context: context,
                                        );
                                      }
                                    },
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 260.ms)
                                  .slideX(
                                    begin: 0.06,
                                    end: 0,
                                    duration: 340.ms,
                                    curve: Curves.easeOutCubic,
                                  ),

                            const SizedBox(height: 10),

                            // ── Login / Logout ──
                            if (isLoggedIn)
                              _ActionTile(
                                    title: 'تسجيل الخروج',
                                    subtitle:
                                        'إنهاء الجلسة الحالية والعودة للزائر',
                                    icon: Iconsax.logout,
                                    accentColor: _accentAmber,
                                    onTap: () => signOut(context),
                                  )
                                  .animate()
                                  .fadeIn(delay: 240.ms, duration: 260.ms)
                                  .slideX(
                                    begin: 0.06,
                                    end: 0,
                                    duration: 340.ms,
                                    curve: Curves.easeOutCubic,
                                  )
                            else
                              _LoginButton().animate().fadeIn(
                                delay: 240.ms,
                                duration: 260.ms,
                              ),

                            // ── Delete account ──
                            if (isLoggedIn && !isAdmin) ...[
                              const SizedBox(height: 10),
                              _ActionTile(
                                    title: 'حذف الحساب',
                                    subtitle: 'حذف نهائي لجميع بيانات الحساب',
                                    icon: Iconsax.trash,
                                    accentColor: _accentRose,
                                    onTap:
                                        () => _showDeleteDialog(context, cubit),
                                  )
                                  .animate()
                                  .fadeIn(delay: 280.ms, duration: 260.ms)
                                  .slideX(
                                    begin: 0.06,
                                    end: 0,
                                    duration: 340.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                            ],
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

  void _showDeleteDialog(BuildContext context, UserCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => Dialog(
            backgroundColor: _cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _accentRose.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Iconsax.trash,
                      color: _accentRose,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'حذف الحساب',
                    style: TextStyle(
                      color: _inkDeep,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'هل أنت متأكد من حذف حسابك بشكل نهائي؟\nلن تتمكن من التراجع عن هذا الإجراء.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 13,
                      height: 1.6,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: _softGray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: _inkMid,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => cubit.deleteAccount(context: context),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: _accentRose,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'حذف نهائي',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PROFILE HEADER — LOGGED IN
// ═══════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.cubit});
  final UserCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _inkDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Actions column
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accentAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accentAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'عميل مميز',
                  style: TextStyle(
                    color: _accentAmber,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Name & phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cubit.profileModel!.name,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      cubit.profileModel!.phone,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.60),
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(Iconsax.call, color: _accentAmber, size: 13),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _accentAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accentAmber.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const Icon(Iconsax.user, color: _accentAmber, size: 28),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PROFILE HEADER SKELETON (loading)
// ═══════════════════════════════════════════════════════
class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      decoration: BoxDecoration(
        color: _inkDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _accentAmber, strokeWidth: 2),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  GUEST HEADER
// ═══════════════════════════════════════════════════════
class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _inkDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'أهلاً بك في مدرستي',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سجّل الدخول للوصول إلى المفضلة وإدارة حسابك',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 11,
                    height: 1.6,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Icon(
              Iconsax.user,
              color: Colors.white.withValues(alpha: 0.5),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STATS ROW
// ═══════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        label: 'طلباتي',
        value: profile.ordersCount.toString(),
        icon: Iconsax.bag_2,
      ),
      (
        label: 'المفضلة',
        value: profile.favoritesCount.toString(),
        icon: Iconsax.heart,
      ),
    ];

    return Row(
      children:
          stats.map((s) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _softGray),
                ),
                child: Column(
                  children: [
                    Icon(s.icon, color: _accentAmber, size: 20),
                    const SizedBox(height: 6),
                    Text(
                      s.value,
                      style: const TextStyle(
                        color: _inkDeep,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      s.label,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 10,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SECTION LABEL
// ═══════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _inkDeep,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(width: 7),
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _accentAmber,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ACTION TILE
// ═══════════════════════════════════════════════════════
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accentColor = _accentAmber,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softGray),
          boxShadow: [
            BoxShadow(
              color: _inkDeep.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Arrow
            Icon(Iconsax.arrow_left_2, color: _textMuted, size: 16),
            const Spacer(),
            // Text
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: _inkDeep,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 10.5,
                      height: 1.5,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: accentColor.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  LOGIN BUTTON
// ═══════════════════════════════════════════════════════
class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateTo(context, Login()),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _accentAmber,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Iconsax.login, color: _inkDeep, size: 20),
            SizedBox(width: 8),
            Text(
              'تسجيل الدخول',
              style: TextStyle(
                color: _inkDeep,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
