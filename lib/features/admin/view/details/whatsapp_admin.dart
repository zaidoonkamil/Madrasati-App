import 'dart:convert';
import 'dart:typed_data';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class WhatsAppAdminPage extends StatelessWidget {
  const WhatsAppAdminPage({super.key});

  static final TextEditingController phoneController = TextEditingController();
  static final TextEditingController messageController = TextEditingController(
    text: 'هذه رسالة تجريبية من لوحة تحكم متجر Auto Parts',
  );
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit()..getWhatsAppStatus(context: context),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          final cubit = AdminCubit.get(context);
          if (state is WhatsAppInitSuccessState) {
            cubit.getWhatsAppQr(context: context);
          }
          if (state is WhatsAppLogoutSuccessState) {
            cubit.getWhatsAppStatus(context: context);
          }
          if (state is WhatsAppSendSuccessState) {
            cubit.getWhatsAppStatus(context: context);
          }
        },
        builder: (context, state) {
          final cubit = AdminCubit.get(context);
          final status = cubit.whatsAppStatus ?? {};
          final qrBytes = _decodeQr(
            cubit.whatsAppQrImage ?? status['qrImage']?.toString(),
          );
          final statusText = status['status']?.toString() ?? 'idle';
          final connectedNumber = status['connectedNumber']?.toString();
          final lastError = status['lastError']?.toString();

          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: appBackgroundColor,
              body: Column(
                children: [
                  const CustomAppBarBack(
                    title: 'ربط واتساب',
                    subtitle: 'اربط واتساب الأدمن لإرسال الرسائل من النظام',
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: primaryColor,
                      onRefresh: () async {
                        cubit.getWhatsAppStatus(context: context);
                        cubit.getWhatsAppQr(context: context);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _StatusCard(
                              status: statusText,
                              connectedNumber: connectedNumber,
                              lastError: lastError,
                            ),
                            const SizedBox(height: 14),
                            _ActionPanel(
                              isLoading: state is WhatsAppLoadingState,
                              onInit:
                                  () => cubit.initWhatsApp(context: context),
                              onFetchQr:
                                  () => cubit.getWhatsAppQr(context: context),
                              onRefresh:
                                  () =>
                                      cubit.getWhatsAppStatus(context: context),
                              onLogout:
                                  () => cubit.logoutWhatsApp(context: context),
                            ),
                            const SizedBox(height: 14),
                            _QrCard(qrBytes: qrBytes, status: statusText),
                            const SizedBox(height: 14),
                            Form(
                              key: formKey,
                              child: _TestMessageCard(
                                isLoading: state is WhatsAppLoadingState,
                                phoneController: phoneController,
                                messageController: messageController,
                                onSend: () {
                                  if (formKey.currentState!.validate()) {
                                    cubit.sendWhatsAppTest(
                                      context: context,
                                      phone: phoneController.text.trim(),
                                      message: messageController.text.trim(),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
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

  Uint8List? _decodeQr(String? dataUrl) {
    if (dataUrl == null || dataUrl.isEmpty) return null;
    final parts = dataUrl.split(',');
    final payload = parts.isNotEmpty ? parts.last : dataUrl;
    try {
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.connectedNumber,
    required this.lastError,
  });

  final String status;
  final String? connectedNumber;
  final String? lastError;

  Color get _statusColor {
    switch (status) {
      case 'ready':
        return successColor;
      case 'qr_ready':
      case 'authenticated':
      case 'initializing':
      case 'reconnecting':
        return primaryColor;
      case 'auth_failure':
      case 'failed':
      case 'disconnected':
        return accentColor;
      default:
        return secondTextColor;
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'ready':
        return 'متصل وجاهز للإرسال';
      case 'qr_ready':
        return 'الـ QR جاهز للمسح';
      case 'authenticated':
        return 'تمت المصادقة، بانتظار الجاهزية';
      case 'initializing':
        return 'جاري تشغيل جلسة واتساب';
      case 'reconnecting':
        return 'جاري إعادة الاتصال';
      case 'disconnected':
        return 'تم قطع الاتصال';
      case 'failed':
        return 'فشل تشغيل واتساب';
      case 'auth_failure':
        return 'فشل في المصادقة';
      default:
        return 'غير مرتبط';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [appDarkGradientStartColor, appDarkGradientEndColor],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              const Text(
                'حالة الاتصال',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _statusLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          if (connectedNumber != null && connectedNumber!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'الرقم المرتبط: $connectedNumber',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (lastError != null && lastError!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              lastError!,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFFFFC9C2), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.isLoading,
    required this.onInit,
    required this.onFetchQr,
    required this.onRefresh,
    required this.onLogout,
  });

  final bool isLoading;
  final VoidCallback onInit;
  final VoidCallback onFetchQr;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        _MiniActionButton(
          title: 'تشغيل',
          icon: Icons.power_settings_new_rounded,
          onTap: isLoading ? null : onInit,
        ),
        _MiniActionButton(
          title: 'جلب QR',
          icon: Icons.qr_code_2_rounded,
          onTap: isLoading ? null : onFetchQr,
        ),
        _MiniActionButton(
          title: 'تحديث',
          icon: Icons.refresh_rounded,
          onTap: isLoading ? null : onRefresh,
        ),
        _MiniActionButton(
          title: 'تسجيل خروج',
          icon: Icons.logout_rounded,
          isDanger: true,
          onTap: isLoading ? null : onLogout,
        ),
      ],
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? accentColor : secondPrimaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.qrBytes, required this.status});

  final Uint8List? qrBytes;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'QR الربط',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'إذا ظهر الـ QR، امسحه من تطبيق واتساب في هاتفك عبر الأجهزة المرتبطة.',
            textAlign: TextAlign.right,
            style: TextStyle(color: secondTextColor, height: 1.5),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 230,
              height: 230,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child:
                  qrBytes != null
                      ? Image.memory(qrBytes!, fit: BoxFit.contain)
                      : Center(
                        child: Text(
                          status == 'ready'
                              ? 'واتساب متصل بالفعل'
                              : 'اضغط "تشغيل" ثم "جلب QR"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: secondTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestMessageCard extends StatelessWidget {
  const _TestMessageCard({
    required this.isLoading,
    required this.phoneController,
    required this.messageController,
    required this.onSend,
  });

  final bool isLoading;
  final TextEditingController phoneController;
  final TextEditingController messageController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'رسالة تجريبية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'أرسل رسالة اختبار للتأكد أن الحساب المرتبط يرسل فعلاً.',
            textAlign: TextAlign.right,
            style: TextStyle(color: secondTextColor, height: 1.5),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: phoneController,
            hintText: 'رقم الهاتف',
            keyboardType: TextInputType.phone,
            validate: (value) {
              if (value == null || value.isEmpty) {
                return 'رجاءً أدخل رقم الهاتف';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: messageController,
            hintText: 'نص الرسالة',
            maxLines: 4,
            validate: (value) {
              if (value == null || value.isEmpty) {
                return 'رجاءً أدخل الرسالة';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ConditionalBuilder(
            condition: !isLoading,
            builder: (_) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'إرسال رسالة تجريبية',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            fallback:
                (_) => const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
          ),
        ],
      ),
    );
  }
}
