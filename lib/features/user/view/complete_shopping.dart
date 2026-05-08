import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:madrasati_app/core/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/navigation_bar/navigation_bar.dart';
import '../../../core/styles/themes.dart';
import '../../../core/utils/delivery_type.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

const _cream = appBackgroundColor;
const _inkDeep = appTextPrimaryColor;
const _accentAmber = appAccentColor;
const _cardBg = appSurfaceColor;
const _softGray = appMutedSurfaceColor;
const _textMuted = appTextMutedColor;

class CompleteShopping extends StatefulWidget {
  const CompleteShopping({super.key, required this.items});

  final List<Map<String, dynamic>> items;

  @override
  State<CompleteShopping> createState() => _CompleteShoppingState();
}

class _CompleteShoppingState extends State<CompleteShopping> {
  String _selectedDeliveryType = deliveryTypeStandard;
  bool _didFillPhoneFromProfile = false;

  void showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'تمت العملية',
        message: message,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static TextEditingController phoneController = TextEditingController();
  static TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (BuildContext context) => UserCubit()..getProfile(context: context),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {
          if (state is GetProfileSuccessState && !_didFillPhoneFromProfile) {
            final phone = UserCubit.get(context).profileModel?.phone.trim();
            if (phone != null &&
                phone.isNotEmpty &&
                phoneController.text.trim().isEmpty) {
              phoneController.text = phone;
              _didFillPhoneFromProfile = true;
            }
          }

          if (state is AddOrderSuccessState) {
            phoneController.text = '';
            locationController.text = '';
            showSuccessSnackBar(context, 'تمت عملية الطلب بنجاح');
            navigateAndFinish(context, const BottomNavBar());
          }
        },
        builder: (context, state) {
          final cubit = UserCubit.get(context);

          return Scaffold(
            backgroundColor: _cream,
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  CustomAppBarBack(
                    title: 'إكمال الشراء',
                    subtitle: 'أدخل معلومات التوصيل لإتمام الطلب',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _OrderSummaryCard(itemsCount: widget.items.length),
                            const SizedBox(height: 14),
                            _DeliveryOptionsCard(
                              selectedType: _selectedDeliveryType,
                              onChanged: (value) {
                                setState(() => _selectedDeliveryType = value);
                              },
                            ),
                            const SizedBox(height: 14),
                            const _PaymentCard(),
                            const SizedBox(height: 14),
                            _AddressForm(
                              phoneController: phoneController,
                              locationController: locationController,
                              deliveryType: _selectedDeliveryType,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: ColoredBox(
              color: bottomNavigationSafeColor,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: GestureDetector(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        cubit.addOrder(
                          context: context,
                          phone: phoneController.text.trim(),
                          location:
                              _selectedDeliveryType == deliveryTypePickup
                                  ? (locationController.text.trim().isEmpty
                                      ? 'استلام من المتجر'
                                      : locationController.text.trim())
                                  : locationController.text.trim(),
                          deliveryType: _selectedDeliveryType,
                          products: widget.items,
                        );
                      }
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: _accentAmber,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _accentAmber.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ConditionalBuilder(
                        condition: state is! AddOrderLoadingState,
                        builder:
                            (context) => Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _inkDeep.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: _inkDeep,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'تأكيد الطلب',
                                        style: const TextStyle(
                                          color: _inkDeep,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        'متابعة تجهيز ${widget.items.length} منتج',
                                        style: TextStyle(
                                          color: _inkDeep.withValues(
                                            alpha: 0.60,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        fallback:
                            (context) => const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.itemsCount});

  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _inkDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'مراجعة معلومات الطلب',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'سيتم تجهيز $itemsCount منتج بعد تأكيد بيانات التوصيل',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softGray),
        boxShadow: [
          BoxShadow(
            color: _inkDeep.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _softGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.payments_outlined, color: _accentAmber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'طريقة الدفع',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: _inkDeep,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cash on Delivery',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'نقداً عند الاستلام',
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOptionsCard extends StatelessWidget {
  const _DeliveryOptionsCard({
    required this.selectedType,
    required this.onChanged,
  });

  final String selectedType;
  final ValueChanged<String> onChanged;

  static const _options = [
    deliveryTypeStandard,
    deliveryTypeExpressBasra,
    deliveryTypePickup,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softGray),
        boxShadow: [
          BoxShadow(
            color: _inkDeep.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'طريقة الاستلام',
            style: TextStyle(
              fontSize: 16,
              color: _inkDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._options.map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DeliveryOptionTile(
                type: type,
                selected: selectedType == type,
                onTap: () => onChanged(type),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOptionTile extends StatelessWidget {
  const _DeliveryOptionTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final String type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              selected
                  ? _accentAmber.withValues(alpha: 0.14)
                  : appMutedSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _accentAmber : _softGray,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? _accentAmber : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: selected ? _accentAmber : _textMuted),
              ),
              child:
                  selected
                      ? const Icon(Icons.check, size: 14, color: _inkDeep)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    deliveryTypeLabel(type),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: _inkDeep,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    deliveryTypeDescription(type),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressForm extends StatelessWidget {
  const _AddressForm({
    required this.phoneController,
    required this.locationController,
    required this.deliveryType,
  });

  final TextEditingController phoneController;
  final TextEditingController locationController;
  final String deliveryType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'بيانات التوصيل',
            style: const TextStyle(
              fontSize: 16,
              color: _inkDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'رقم الهاتف',
            style: const TextStyle(
              fontSize: 12,
              color: _textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'ادخل رقم الهاتف',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validate: (String? value) {
              if (value == null || value.isEmpty) {
                return 'رجاءً ادخل رقم الهاتف';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            deliveryType == deliveryTypePickup
                ? 'ملاحظة اختيارية'
                : 'العنوان التفصيلي',
            style: const TextStyle(
              fontSize: 12,
              color: _textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hintText:
                deliveryType == deliveryTypePickup
                    ? 'اكتب أي ملاحظة للمتجر إن وجدت'
                    : 'ادخل العنوان بالتفصيل',
            controller: locationController,
            keyboardType: TextInputType.text,
            maxLines: 3,
            validate: (String? value) {
              if (deliveryType != deliveryTypePickup &&
                  (value == null || value.isEmpty)) {
                return 'رجاءً ادخل العنوان بالتفصيل';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
