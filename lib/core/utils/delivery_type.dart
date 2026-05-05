const String deliveryTypeStandard = 'standard';
const String deliveryTypeExpressBasra = 'express_basra';
const String deliveryTypePickup = 'pickup';

String deliveryTypeLabel(String type) {
  switch (type) {
    case deliveryTypeExpressBasra:
      return 'توصيل سريع داخل البصرة';
    case deliveryTypePickup:
      return 'استلام من المتجر';
    case deliveryTypeStandard:
    default:
      return 'توصيل اعتيادي';
  }
}

String deliveryTypeDescription(String type) {
  switch (type) {
    case deliveryTypeExpressBasra:
      return 'خدمة أسرع للطلبات داخل البصرة';
    case deliveryTypePickup:
      return 'تستلم الطلب مباشرة من المتجر';
    case deliveryTypeStandard:
    default:
      return 'التوصيل المعتاد حسب العنوان';
  }
}
