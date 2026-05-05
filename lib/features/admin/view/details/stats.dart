import 'dart:math';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/circular_progress.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';
import '../../model/StatsModel.dart';

class Stats extends StatelessWidget {
  const Stats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) => AdminCubit()..getStats(context: context),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {},
        builder: (context, state) {
          final stats = AdminCubit.get(context).statsModel;

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: pageBackgroundColor,
              body: Column(
                children: [
                  const CustomAppBarBack(
                    title: 'الإحصائيات',
                    subtitle: 'نظرة تشغيلية أوسع على أداء التطبيق',
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ConditionalBuilder(
                        condition: stats != null,
                        builder: (context) => _StatsBody(stats: stats!),
                        fallback:
                            (context) =>
                                const Center(child: CircularProgress()),
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

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final StatsModel stats;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###');
    final completionRate =
        stats.orders.total == 0
            ? 0
            : ((stats.orders.status['completed'] ?? 0) /
                    stats.orders.total *
                    100)
                .round();
    final verifiedRate =
        stats.users.total == 0
            ? 0
            : (stats.users.verified / stats.users.total * 100).round();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroOverview(
            totalRevenue: currency.format(stats.orders.revenue.total),
            totalOrders: stats.orders.total,
            totalProducts: stats.products.total,
            totalUsers: stats.users.total,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'معدل الإنجاز',
                  value: '$completionRate%',
                  subtitle: 'من إجمالي الطلبات',
                  accent: const Color(0xFF1E8E5A),
                  icon: Icons.task_alt_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'توثيق الحسابات',
                  value: '$verifiedRate%',
                  subtitle: 'من إجمالي المستخدمين',
                  accent: const Color(0xFF2563EB),
                  icon: Icons.verified_user_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'الطلبات',
            subtitle: 'الحركة الحالية وحالات الطلبات',
            child: Column(
              children: [
                SizedBox(height: 220, child: _buildOrdersPieChart(stats)),
                const SizedBox(height: 12),
                _buildMiniMetrics([
                  _MiniMetric(
                    label: 'اليوم',
                    value: stats.orders.ordersNew.today.toString(),
                  ),
                  _MiniMetric(
                    label: 'الأسبوع',
                    value: stats.orders.ordersNew.thisWeek.toString(),
                  ),
                  _MiniMetric(
                    label: 'الشهر',
                    value: stats.orders.ordersNew.thisMonth.toString(),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildStatusProgress(
                  'قيد الانتظار',
                  stats.orders.status['pending'] ?? 0,
                  stats.orders.total,
                  const Color(0xFFF59E0B),
                ),
                _buildStatusProgress(
                  'قيد التوصيل',
                  stats.orders.status['delivery'] ?? 0,
                  stats.orders.total,
                  const Color(0xFF2563EB),
                ),
                _buildStatusProgress(
                  'مكتمل',
                  stats.orders.status['completed'] ?? 0,
                  stats.orders.total,
                  const Color(0xFF16A34A),
                ),
                _buildStatusProgress(
                  'ملغي',
                  stats.orders.status['cancelled'] ?? 0,
                  stats.orders.total,
                  const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'المستخدمون',
            subtitle: 'تركيبة الحسابات والنمو',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 210,
                        child: _buildUsersPieChart(stats),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _buildMetricTile(
                            'إجمالي المستخدمين',
                            stats.users.total.toString(),
                          ),
                          _buildMetricTile(
                            'الموثقون',
                            stats.users.verified.toString(),
                          ),
                          _buildMetricTile(
                            'المسؤولون',
                            stats.users.roles.admin.toString(),
                          ),
                          _buildMetricTile(
                            'المستخدمون',
                            stats.users.roles.user.toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMiniMetrics([
                  _MiniMetric(
                    label: 'اليوم',
                    value: stats.users.usersNew.today.toString(),
                  ),
                  _MiniMetric(
                    label: 'الأسبوع',
                    value: stats.users.usersNew.thisWeek.toString(),
                  ),
                  _MiniMetric(
                    label: 'الشهر',
                    value: stats.users.usersNew.thisMonth.toString(),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'المنتجات',
            subtitle: 'نشاط الإضافة والتوزيع',
            child: Column(
              children: [
                _buildMiniMetrics([
                  _MiniMetric(
                    label: 'الإجمالي',
                    value: stats.products.total.toString(),
                  ),
                  _MiniMetric(
                    label: 'اليوم',
                    value: stats.products.productsNew.today.toString(),
                  ),
                  _MiniMetric(
                    label: 'الأسبوع',
                    value: stats.products.productsNew.thisWeek.toString(),
                  ),
                  _MiniMetric(
                    label: 'الشهر',
                    value: stats.products.productsNew.thisMonth.toString(),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildListSection(
                  title: 'الأكثر نشاطاً حسب القسم',
                  emptyLabel: 'لا توجد بيانات أقسام حالياً',
                  children:
                      stats.products.byCategory
                          .take(5)
                          .map(
                            (item) => _buildMetricTile(
                              'القسم ${item.categoryId == 0 ? "غير محدد" : item.categoryId}',
                              '${item.count} منتج',
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 12),
                _buildListSection(
                  title: 'أعلى التجار حسب عدد المنتجات',
                  emptyLabel: 'لا توجد بيانات تجار حالياً',
                  children:
                      stats.products.topSellers
                          .take(5)
                          .map(
                            (item) => _buildMetricTile(
                              'التاجر ${item.userId == 0 ? "غير محدد" : item.userId}',
                              '${item.count} منتج',
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroOverview({
    required String totalRevenue,
    required int totalOrders,
    required int totalProducts,
    required int totalUsers,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [appDarkGradientStartColor, appDarkGradientEndColor],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'ملخص الأداء',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalRevenue د.ع',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'إجمالي الإيرادات المكتملة',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildHeroStat('المستخدمون', totalUsers.toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeroStat('المنتجات', totalProducts.toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeroStat('الطلبات', totalOrders.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: secondPrimaryColor.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: secondPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.end,
            style: const TextStyle(color: secondTextColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: secondPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: secondPrimaryColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.end,
            style: const TextStyle(color: secondTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetrics(List<_MiniMetric> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          items
              .map(
                (item) => Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: mutedSurfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.value,
                        style: const TextStyle(
                          color: secondPrimaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: secondTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: mutedSurfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: secondPrimaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: const TextStyle(color: secondPrimaryColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required String emptyLabel,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: secondPrimaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (children.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mutedSurfaceColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              emptyLabel,
              textAlign: TextAlign.end,
              style: const TextStyle(color: secondTextColor),
            ),
          )
        else
          ...children,
      ],
    );
  }

  Widget _buildStatusProgress(String label, int value, int total, Color color) {
    final progress = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  color: secondPrimaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: secondPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersPieChart(StatsModel stats) {
    final data = [
      stats.users.verified.toDouble(),
      stats.users.roles.admin.toDouble(),
      stats.users.roles.user.toDouble(),
    ];
    final colors = [
      const Color(0xFF16A34A),
      const Color(0xFFDC2626),
      const Color(0xFF2563EB),
    ];
    final labels = ['موثقون', 'مسؤولون', 'مستخدمون'];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: CustomPaint(
              size: const Size(180, 180),
              painter: PieChartPainter(data: data, colors: colors),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: List.generate(
            labels.length,
            (index) => _LegendChip(
              color: colors[index],
              label: labels[index],
              value: data[index].toInt().toString(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersPieChart(StatsModel stats) {
    final data = [
      (stats.orders.status['pending'] ?? 0).toDouble(),
      (stats.orders.status['delivery'] ?? 0).toDouble(),
      (stats.orders.status['completed'] ?? 0).toDouble(),
      (stats.orders.status['cancelled'] ?? 0).toDouble(),
    ];
    final colors = [
      const Color(0xFFF59E0B),
      const Color(0xFF2563EB),
      const Color(0xFF16A34A),
      const Color(0xFFDC2626),
    ];
    final labels = ['انتظار', 'توصيل', 'مكتمل', 'ملغي'];

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: CustomPaint(
                    size: const Size(180, 180),
                    painter: PieChartPainter(data: data, colors: colors),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    labels.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LegendChip(
                        color: colors[index],
                        label: labels[index],
                        value: data[index].toInt().toString(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniMetric {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: mutedSurfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: secondPrimaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: secondPrimaryColor, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  PieChartPainter({required this.data, required this.colors});

  final List<double> data;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final total = data.fold<double>(0, (sum, item) => sum + item);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -pi / 2;

    if (total == 0) {
      paint.color = Colors.grey.shade300;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * pi * 2;
      paint.color = colors[i];
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.48, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
