import 'dart:async';

import 'package:dio/dio.dart';
import 'package:madrasati_app/core/%20navigation/navigation.dart';
import 'package:madrasati_app/core/navigation_bar/navigation_bar.dart';
import 'package:madrasati_app/core/widgets/show_toast.dart';
import 'package:madrasati_app/features/user/cubit/states.dart';
import 'package:madrasati_app/features/user/model/CatModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';
import '../model/BsketModel.dart';
import '../model/CatProductsModel.dart';
import '../model/FavoritesModel.dart';
import '../model/GetAdsModel.dart';
import '../model/GetNotifications.dart';
import '../model/GetProductsDetails.dart';
import '../model/OrdersUserModel.dart';
import '../model/ProductsModel.dart';
import '../model/ProfileModel.dart';

class UserCubit extends Cubit<UserStates> {
  UserCubit() : super(UserInitialState());
  static UserCubit get(context) => BlocProvider.of(context);

  void slid() {
    emit(ValidationState());
  }

  List<Map<String, dynamic>> faqs = [];
  List<Map<String, dynamic>> customRequests = [];

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  void getFaqs({required BuildContext context}) {
    DioHelper.getData(url: '/faqs')
        .then((value) {
          faqs = _parseList(value.data);
          emit(ValidationState());
        })
        .catchError((error) {
          showToastError(text: 'تعذر جلب الأسئلة', context: context);
        });
  }

  void getCustomRequests({required BuildContext context}) {
    if (id.isEmpty) return;
    DioHelper.getData(url: '/custom-requests/user/$id')
        .then((value) {
          customRequests = _parseList(value.data);
          emit(ValidationState());
        })
        .catchError((error) {
          showToastError(text: 'تعذر جلب الطلبات المخصصة', context: context);
        });
  }

  void addCustomRequest({
    required BuildContext context,
    required String description,
  }) {
    if (description.trim().isEmpty) {
      showToastInfo(text: 'اكتب وصف الطلب أولاً', context: context);
      return;
    }
    DioHelper.postData(
          url: '/custom-requests',
          data: {'userId': id, 'description': description.trim()},
        )
        .then((_) {
          showToastSuccess(text: 'تم إرسال الطلب المخصص', context: context);
          getCustomRequests(context: context);
        })
        .catchError((error) {
          showToastError(text: 'تعذر إرسال الطلب', context: context);
        });
  }

  int getTotalPrice() {
    int total = 0;
    for (var item in basketModel) {
      total += (item.product.price * item.quantity);
    }
    return total;
  }

  bool isLiked = false;

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 18) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير';
    }
  }

  int quantity = 1;
  bool showTick = false;
  String? selectedProductColor;
  String? selectedProductSize;

  void selectProductColor(String value) {
    selectedProductColor = value;
    emit(ValidationState());
  }

  String? appliedCouponCode;
  int couponDiscount = 0;

  int getFinalTotalPrice() {
    final total = getTotalPrice() - couponDiscount;
    return total < 0 ? 0 : total;
  }

  void clearCoupon() {
    appliedCouponCode = null;
    couponDiscount = 0;
    emit(ValidationState());
  }

  void applyCoupon({required BuildContext context, required String code}) {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      showToastInfo(text: 'اكتب رمز الكوبون أولاً', context: context);
      return;
    }

    emit(ApplyCouponLoadingState());
    DioHelper.postData(
          url: '/coupons/validate',
          data: {
            'code': cleanCode,
            'userId': id,
            'totalPrice': getTotalPrice(),
          },
        )
        .then((value) {
          appliedCouponCode = value.data['code']?.toString();
          final discount = value.data['discountAmount'];
          couponDiscount =
              discount is num
                  ? discount.round()
                  : int.tryParse('$discount') ?? 0;
          showToastSuccess(text: 'تم تطبيق الكوبون', context: context);
          emit(ApplyCouponSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text:
                  error.response?.data['error']?.toString() ?? error.toString(),
              context: context,
            );
          }
          emit(ApplyCouponErrorState());
        });
  }

  void selectProductSize(String value) {
    selectedProductSize = value;
    emit(ValidationState());
  }

  void add() {
    quantity++;
    emit(AddState());
  }

  void minus({required BuildContext context}) {
    quantity--;
    if (quantity <= 0) {
      showToastInfo(text: 'اقل عدد للطلب', context: context);
      quantity = 0;
      return;
    }
    emit(AddState());
  }

  void addBasket({required int index}) {
    if (basketModel[index].quantity >= basketModel[index].product.stock) {
      return;
    }
    basketModel[index].quantity++;
    checkIfChanged(index);
    emit(AddState());
  }

  void minusBasket({required int index, required BuildContext context}) {
    if (basketModel[index].quantity > 1) {
      basketModel[index].quantity--;
      checkIfChanged(index);
    } else {
      showToastInfo(text: 'اقل عدد للطلب', context: context);
    }
    emit(AddState());
  }

  void checkIfChanged(int index) {
    if (basketModel[index].quantity != basketModel[index].originalQuantity) {
      showTick = true;
    } else {
      showTick = false;
    }
  }

  List<GetAds> getAdsModel = [];
  bool showSocialLinks = true;

  void getSocialSettings({required BuildContext context}) {
    DioHelper.getData(url: '/app-settings/social')
        .then((value) {
          showSocialLinks = value.data['showSocialLinks'] != false;
          emit(ValidationState());
        })
        .catchError((error) {
          showSocialLinks = true;
          emit(ValidationState());
        });
  }

  void getAds({required BuildContext context}) {
    emit(GetAdsLoadingState());
    DioHelper.getData(url: '/ads')
        .then((value) {
          getAdsModel =
              (value.data as List)
                  .map((item) => GetAds.fromJson(item as Map<String, dynamic>))
                  .toList();
          emit(GetAdsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetAdsErrorStates());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  ProfileModel? profileModel;
  void getProfile({required BuildContext context}) {
    if (token == '') {
      return;
    }

    emit(GetProfileLoadingState());
    DioHelper.getData(url: '/profile', token: token)
        .then((value) {
          profileModel = ProfileModel.fromJson(value.data);
          emit(GetProfileSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetProfileErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void deleteAccount({required BuildContext context}) {
    emit(DeleteProfileLoadingState());
    DioHelper.deleteData(url: '/users/$id')
        .then((value) {
          token = '';
          emit(DeleteProfileSuccessState());
          navigateAndFinish(context, BottomNavBar());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(DeleteProfileErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  ScrollController scrollControllerCatt = ScrollController();
  double scrollPosition = 0.0;
  void scrol() {
    Future.delayed(Duration.zero, () {
      Timer.periodic(Duration(seconds: 5), (timer) {
        if (scrollControllerCatt.hasClients) {
          scrollPosition += 200;
          if (scrollPosition >= scrollControllerCatt.position.maxScrollExtent) {
            scrollPosition = 0;
          }
          scrollControllerCatt.animateTo(
            scrollPosition,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  List<CatModel> getCatModel = [];
  List<CatModel> get mainCategories =>
      getCatModel.where((item) => item.isMainCategory).toList();

  List<CatModel> subcategoriesForMain(int mainCategoryId) {
    final CatModel? category = getCatModel.cast<CatModel?>().firstWhere(
      (item) => item?.id == mainCategoryId,
      orElse: () => null,
    );
    return category?.subcategories ?? [];
  }

  void getCat({required BuildContext context}) {
    emit(GetCatLoadingState());
    DioHelper.getData(url: '/categories')
        .then((value) {
          getCatModel =
              (value.data as List)
                  .map(
                    (item) => CatModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
          emit(GetCatSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetCatErrorStates());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  List<Product> products = [];
  PaginationProducts? paginationFeaturedProducts;
  int currentPageFeaturedProducts = 1;
  bool isLastPageFeaturedProducts = false;
  bool isLoadingMoreFeaturedProducts = false;
  bool isFeaturedScrollInitialized = false;
  final ScrollController scrollControllerFeatured = ScrollController();

  void initFeaturedScrollController(BuildContext context, {int limit = 12}) {
    if (isFeaturedScrollInitialized) {
      return;
    }
    isFeaturedScrollInitialized = true;

    scrollControllerFeatured.addListener(() {
      if (scrollControllerFeatured.position.pixels >=
              scrollControllerFeatured.position.maxScrollExtent - 220 &&
          !isLastPageFeaturedProducts &&
          !isLoadingMoreFeaturedProducts) {
        getFeaturedProducts(
          context: context,
          page: (currentPageFeaturedProducts + 1).toString(),
          limit: limit,
          loadMore: true,
        );
      }
    });
  }

  void getFeaturedProducts({
    required BuildContext context,
    String page = '1',
    int limit = 8,
    bool loadMore = false,
  }) {
    if (loadMore &&
        (isLoadingMoreFeaturedProducts || isLastPageFeaturedProducts)) {
      return;
    }

    if (!loadMore) {
      products = [];
      currentPageFeaturedProducts = 1;
      isLastPageFeaturedProducts = false;
      emit(GetProductsLoadingState());
    } else {
      isLoadingMoreFeaturedProducts = true;
    }

    final String userId = id.isNotEmpty ? id : '0';
    DioHelper.getData(
          url: '/products/featured?userId=$userId&page=$page&limit=$limit',
        )
        .then((value) {
          final featuredData = ProductsModel.fromJson(value.data);
          final incomingProducts = featuredData.products.where(
            (item) => !products.any((existing) => existing.id == item.id),
          );
          products.addAll(incomingProducts);
          paginationFeaturedProducts = featuredData.paginationProducts;
          currentPageFeaturedProducts = paginationFeaturedProducts!.currentPage;
          if (currentPageFeaturedProducts >=
              paginationFeaturedProducts!.totalPages) {
            isLastPageFeaturedProducts = true;
          }
          emit(GetProductsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetProductsErrorStates());
          } else {
            print("Unknown Error: $error");
          }
        })
        .whenComplete(() {
          isLoadingMoreFeaturedProducts = false;
        });
  }

  List<BsketModel> basketModel = [];
  void getBasket({required BuildContext context}) {
    emit(GetBasketLoadingState());
    DioHelper.getData(url: '/basket/$id')
        .then((value) {
          basketModel =
              (value.data as List)
                  .map((cat) => BsketModel.fromJson(cat))
                  .toList();
          emit(GetBasketSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetBasketErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void deleteBasket({required String idItem, required BuildContext context}) {
    emit(DeleteBasketLoadingState());

    DioHelper.deleteData(url: '/basket/$id/item/$idItem')
        .then((value) {
          basketModel.removeWhere((ads) => ads.id.toString() == idItem);
          showToastSuccess(text: 'تم الحذف بنجاح', context: context);
          emit(DeleteBasketSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(DeleteBasketErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  static ScrollController? scrollControllerCat;
  List<ProductCat> productCat = [];
  PaginationCatProducts? paginationCatProducts;
  int currentPageCatProducts = 1;
  bool isLastPageCatProducts = false;
  bool isLoadingMoreCatProducts = false;
  CatProductsModel? catCatProductsModel;
  void initScrollControllerCat(BuildContext context, String categoriesId) {
    scrollControllerCat?.dispose();
    scrollControllerCat = ScrollController();
    scrollControllerCat!.addListener(() {
      if (scrollControllerCat!.position.pixels >=
              scrollControllerCat!.position.maxScrollExtent - 200 &&
          !isLastPageCatProducts &&
          !isLoadingMoreCatProducts) {
        getCatCatProducts(
          page: (currentPageCatProducts + 1).toString(),
          context: context,
          id: categoriesId,
        );
      }
    });
  }

  void getCatCatProducts({
    required BuildContext context,
    required String page,
    required String id,
  }) {
    if (page == '1') {
      productCat = [];
      currentPageCatProducts = 1;
      isLastPageCatProducts = false;
      paginationCatProducts = null;
    }
    if (isLoadingMoreCatProducts || isLastPageCatProducts) return;
    isLoadingMoreCatProducts = true;
    emit(GetProductsLoadingState());
    DioHelper.getData(url: '/categories/$id/products?page=$page')
        .then((value) {
          catCatProductsModel = CatProductsModel.fromJson(value.data);
          final newProducts =
              catCatProductsModel!.products
                  .where(
                    (p) => !productCat.any((existing) => existing.id == p.id),
                  )
                  .toList();
          productCat.addAll(newProducts);
          paginationCatProducts = catCatProductsModel!.paginationCatProducts;
          currentPageCatProducts = paginationCatProducts!.currentPage;
          if (currentPageCatProducts >= paginationCatProducts!.totalPages) {
            isLastPageCatProducts = true;
          }
          emit(GetProductsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            emit(GetProductsErrorStates());
          } else {
            print("Unknown Error: $error");
          }
        })
        .whenComplete(() {
          isLoadingMoreCatProducts = false;
        });
  }

  void deleteProductFromSection({
    required String productId,
    required BuildContext context,
  }) {
    emit(DeleteProductLoadingState());
    DioHelper.deleteData(url: '/products/$productId')
        .then((value) {
          productCat.removeWhere((item) => item.id.toString() == productId);
          products.removeWhere((item) => item.id.toString() == productId);
          showToastSuccess(text: 'تم حذف المنتج بنجاح', context: context);
          emit(DeleteProductSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            emit(DeleteProductErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  FavoritesModel? favoritesModel;
  void getFavorites({required BuildContext context}) {
    emit(GetFavoritesLoadingState());
    DioHelper.getData(url: '/allfavorites/$id')
        .then((value) {
          favoritesModel = FavoritesModel.fromJson(value.data);
          emit(GetFavoritesSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetFavoritesErrorStates());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void updateFavorites({
    required String idItem,
    required BuildContext context,
  }) {
    emit(UpdateFavoritesLoadingState());
    DioHelper.postData(url: '/favorites/$id/add/$idItem')
        .then((value) {
          favoritesModel!.productsFavorites = List.from(
            favoritesModel!.productsFavorites,
          )..removeWhere((ads) => ads.id.toString() == idItem);
          emit(UpdateFavoritesSuccessState());
          showToastSuccess(text: 'تم الحذف بنجاح', context: context);
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(UpdateFavoritesErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void updateFavoritesDetails({
    required String idItem,
    required BuildContext context,
  }) {
    emit(UpdateFavoritesLoadingState());
    DioHelper.postData(url: '/favorites/$id/add/$idItem')
        .then((value) {
          isLiked = !isLiked;
          emit(UpdateFavoritesSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(UpdateFavoritesErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void addToBasket({
    required String productId,
    required String quantity,
    String? selectedColor,
    String? selectedSize,
    required BuildContext context,
  }) {
    emit(AddToBasketLoadingState());
    DioHelper.postData(
          url: '/basket',
          data: {
            'productId': productId,
            'quantity': quantity,
            'userId': id,
            if (selectedColor != null) 'selectedColor': selectedColor,
            if (selectedSize != null) 'selectedSize': selectedSize,
          },
        )
        .then((value) {
          emit(AddToBasketSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text:
                  error.response?.data['error'].toString() ?? error.toString(),
              context: context,
            );
            emit(AddToBasketErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  addOrder({
    required BuildContext context,
    required String phone,
    String? secondaryPhone,
    required String location,
    required String deliveryType,
    required List<Map<String, dynamic>> products,
    String? couponCode,
  }) {
    emit(AddOrderLoadingState());
    DioHelper.postData(
          url: '/orders/$id',
          data: {
            'phone': phone,
            if (secondaryPhone != null && secondaryPhone.trim().isNotEmpty)
              'secondaryPhone': secondaryPhone.trim(),
            'address': location,
            'deliveryType': deliveryType,
            'products': products,
            if (couponCode != null && couponCode.trim().isNotEmpty)
              'couponCode': couponCode.trim(),
          },
        )
        .then((value) {
          emit(AddOrderSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            print(error.response?.data);
            showToastError(
              text: error.response?.data["error"] ?? "حدث خطأ غير معروف",
              context: context,
            );
            emit(AddOrderErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  List<Order> ordersUser = [];
  PaginationOrdersUser? paginationOrdersUser;
  int currentPageOrdersUser = 1;
  bool isLastPageOrdersUser = false;
  OrdersUserModel? ordersUserModel;
  void getOrdersUser({required BuildContext context, required String page}) {
    if (token == '') {
      return;
    }
    emit(GetOrdersUserLoadingState());
    DioHelper.getData(url: '/orders/$id?page=$page')
        .then((value) {
          ordersUserModel = OrdersUserModel.fromJson(value.data);
          ordersUser.addAll(ordersUserModel!.orders);
          paginationOrdersUser = ordersUserModel!.paginationOrdersUser;
          currentPageOrdersUser = paginationOrdersUser!.currentPage;
          if (currentPageOrdersUser >= paginationOrdersUser!.totalPages) {
            isLastPageOrdersUser = true;
          }
          emit(GetOrdersUserSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetOrdersUserErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  GetNotifications? getNotificationsModel;
  void getNotifications({required BuildContext context}) {
    emit(GetNotificationsLoadingState());
    DioHelper.getData(url: '/notifications-log?user_id=$id')
        .then((value) {
          getNotificationsModel = GetNotifications.fromJson(value.data);
          emit(GetNotificationsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetNotificationsErrorStates());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  GetProductsDetails? getProductsDetailsModel;
  void getProductsDetails({
    required BuildContext context,
    required String sellerId,
  }) {
    emit(GetProductsDetailsLoadingState());
    DioHelper.getData(url: '/products/$sellerId?page=1')
        .then((value) {
          getProductsDetailsModel = GetProductsDetails.fromJson(value.data);
          emit(GetProductsDetailsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetProductsDetailsErrorStates());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  @override
  Future<void> close() {
    scrollControllerFeatured.dispose();
    return super.close();
  }
}
