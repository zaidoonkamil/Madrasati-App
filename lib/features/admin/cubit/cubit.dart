import 'package:madrasati_app/features/admin/cubit/states.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';
import '../../../core/widgets/show_toast.dart';
import '../../user/model/CatModel.dart';
import '../../user/model/GetAdsModel.dart';
import '../../user/model/ProductsModel.dart';
import '../../user/model/ProfileModel.dart';
import '../model/OrdersAgentModel.dart';
import '../model/StatsModel.dart';
import '../model/getNameUser.dart';

class AdminCubit extends Cubit<AdminStates> {
  AdminCubit() : super(AdminInitialState());
  static AdminCubit get(context) => BlocProvider.of(context);

  void slid() {
    emit(ValidationState());
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

  List<GetAds> getAdsModel = [];
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
            emit(GetAdsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  ProfileModel? profileModel;
  void getProfile({required BuildContext context}) {
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

  List<Product> products = [];
  PaginationProducts? paginationProducts;
  int currentPageProducts = 1;
  bool isLastPageProducts = false;
  ProductsModel? productsModel;
  void getProducts({required BuildContext context, required String page}) {
    emit(GetProductsLoadingState());
    DioHelper.getData(url: '/products/$id?page=$page')
        .then((value) {
          productsModel = ProductsModel.fromJson(value.data);
          products.addAll(productsModel!.products);
          paginationProducts = productsModel!.paginationProducts;
          currentPageProducts = paginationProducts!.currentPage;
          if (currentPageProducts >= paginationProducts!.totalPages) {
            isLastPageProducts = true;
          }
          emit(GetProductsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetProductsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void deleteProducts({
    required String idProducts,
    required BuildContext context,
  }) {
    emit(DeleteProductsLoadingState());

    DioHelper.deleteData(url: '/products/$idProducts')
        .then((value) {
          productsModel!.products.removeWhere(
            (ads) => ads.id.toString() == idProducts,
          );
          showToastSuccess(text: 'تم الحذف بنجاح', context: context);
          emit(DeleteProductsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(DeleteProductsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void updateProduct({
    required String productId,
    required String title,
    required String description,
    required String price,
    required String stock,
    required BuildContext context,
  }) {
    emit(UpdateProductsLoadingState());
    DioHelper.patchData(
          url: '/products/$productId',
          data: {
            'title': title,
            'description': description,
            'price': price,
            'stock': stock,
          },
        )
        .then((value) {
          final updated = Product.fromJson(value.data);
          final index = products.indexWhere(
            (item) => item.id.toString() == productId,
          );
          if (index != -1) {
            products[index] = updated;
          }
          if (productsModel != null) {
            final modelIndex = productsModel!.products.indexWhere(
              (item) => item.id.toString() == productId,
            );
            if (modelIndex != -1) {
              productsModel!.products[modelIndex] = updated;
            }
          }
          showToastSuccess(text: 'تم تحديث المنتج بنجاح', context: context);
          emit(UpdateProductsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: error.response?.data["error"] ?? "حدث خطأ غير معروف",
              context: context,
            );
            emit(UpdateProductsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  List<XFile> selectedImages = [];
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> resultList = await picker.pickMultiImage();

    if (resultList.isNotEmpty) {
      selectedImages = resultList;
      emit(SelectedImagesState());
    }
  }

  addProducts({
    required String tittle,
    required String desc,
    required String price,
    required String stock,
    required String categoryId,
    required BuildContext context,
  }) async {
    emit(AddProductsLoadingState());
    if (selectedImages.isEmpty) {
      showToastInfo(text: "الرجاء اختيار صور أولاً!", context: context);
      emit(AddProductsErrorState());
      return;
    }
    FormData formData = FormData.fromMap({
      'title': tittle,
      'description': desc,
      'price': price,
      'stock': stock,
      'userId': id,
      'categoryId': categoryId,
    }, ListFormat.multiCompatible);

    for (var file in selectedImages) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            file.path,
            filename: file.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    DioHelper.postData(
          url: '/products',
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}),
        )
        .then((value) {
          emit(AddProductsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: error.response?.data["error"],
              context: context,
            );
            emit(AddProductsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  List<CatModel> getCatModel = [];
  List<CatModel> get mainCategories =>
      getCatModel.where((item) => item.isMainCategory).toList();

  List<CatModel> get allSubcategories =>
      getCatModel.expand((item) => item.subcategories).toList();

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
            emit(GetCatErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  StatsModel? statsModel;
  void getStats({required BuildContext context}) {
    emit(GetStatsLoadingState());
    DioHelper.getData(url: '/stats')
        .then((value) {
          statsModel = StatsModel.fromJson(value.data);
          emit(GetStatsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetStatsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  OrdersAdminModel? ordersAdminModel;
  void getOrdersAdmin({
    required BuildContext context,
    required String page,
    required String status,
  }) {
    emit(GetOrdersAdminLoadingState());
    DioHelper.getData(url: '/orders/admin/status?status=$status&page=$page')
        .then((value) {
          ordersAdminModel = OrdersAdminModel.fromJson(value.data);
          emit(GetOrdersAdminSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(GetOrdersAdminErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  addAds({
    required String tittle,
    required String desc,
    required BuildContext context,
  }) async {
    emit(AddAdsLoadingState());
    if (selectedImages.isEmpty) {
      showToastInfo(text: "الرجاء اختيار صور أولاً!", context: context);
      emit(AddAdsErrorState());
      return;
    }
    FormData formData = FormData.fromMap({
      'name': tittle,
      'description': desc,
    }, ListFormat.multiCompatible);

    for (var file in selectedImages) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            file.path,
            filename: file.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    DioHelper.postData(
          url: '/ads',
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}),
        )
        .then((value) {
          emit(AddAdsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: error.response?.data["error"],
              context: context,
            );
            emit(AddAdsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void deleteAds({required String id, required BuildContext context}) {
    emit(DeleteAdsLoadingState());
    DioHelper.deleteData(url: '/ads/$id')
        .then((value) {
          getAdsModel.removeWhere(
            (getAdsModel) => getAdsModel.id.toString() == id,
          );
          showToastSuccess(text: 'تم الحذف بنجاح', context: context);
          emit(DeleteAdsSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(DeleteAdsErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  List<XFile> selectedImagesCat = [];
  Future<void> pickImagesCat() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> resultList = await picker.pickMultiImage();

    if (resultList.isNotEmpty) {
      selectedImagesCat = resultList;
      emit(SelectedImagesState());
    }
  }

  addCat({
    required String tittle,
    String? parentId,
    required BuildContext context,
  }) async {
    emit(AddCategoriesLoadingState());
    if (selectedImagesCat.isEmpty) {
      showToastInfo(text: "الرجاء اختيار صور أولاً!", context: context);
      emit(AddCategoriesErrorState());
      return;
    }
    FormData formData = FormData.fromMap({
      'name': tittle,
      if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
    }, ListFormat.multiCompatible);

    for (var file in selectedImagesCat) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            file.path,
            filename: file.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    DioHelper.postData(
          url: '/categories',
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}),
        )
        .then((value) {
          emit(AddCategoriesSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: error.response?.data["error"],
              context: context,
            );
            emit(AddCategoriesErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void deleteCategories({required String id, required BuildContext context}) {
    emit(DeleteCategoriesLoadingState());
    DioHelper.deleteData(url: '/categories/$id')
        .then((value) {
          getCatModel.removeWhere(
            (getCatModel) => getCatModel.id.toString() == id,
          );
          showToastSuccess(text: 'تم الحذف بنجاح', context: context);
          emit(DeleteCategoriesSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(DeleteCategoriesErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  bool isPasswordHidden = true;
  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    emit(PasswordVisibilityChanged());
  }

  bool isPasswordHidden2 = true;
  void togglePasswordVisibility2() {
    isPasswordHidden2 = !isPasswordHidden2;
    emit(PasswordVisibilityChanged());
  }

  String normalizePhone(String phone) {
    phone = phone.trim();

    if (phone.startsWith('964') && phone.length == 13) {
      return phone;
    } else if (phone.startsWith('0') && phone.length == 11) {
      return '964' + phone.substring(1);
    } else if (phone.length == 10) {
      return '964' + phone;
    } else {
      return phone;
    }
  }

  signUp({
    required String name,
    required String phone,
    required String password,
    required String location,
    required String role,
    required BuildContext context,
  }) {
    phone = normalizePhone(phone);
    emit(SignUpLoadingState());
    DioHelper.postData(
          url: '/users',
          data: {
            'name': name,
            'phone': phone,
            'role': role,
            'location': location,
            'password': password,
          },
        )
        .then((value) {
          emit(SignUpSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            print(error.response?.data["error"]);
            showToastError(
              text: error.response?.data["error"],
              context: context,
            );
            emit(SignUpErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  List<XFile> selectedImagesAgent = [];
  Future<void> pickImagesAgent() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> resultList = await picker.pickMultiImage();

    if (resultList.isNotEmpty) {
      selectedImagesAgent = resultList;
      emit(SelectedImagesState());
    }
  }

  signUpAgent({
    required String name,
    required String phone,
    required String password,
    required String location,
    required String role,
    required BuildContext context,
  }) async {
    phone = normalizePhone(phone);
    emit(SignUpLoadingState());
    if (selectedImagesAgent.isEmpty) {
      showToastInfo(text: "الرجاء اختيار صور أولاً!", context: context);
      emit(SignUpErrorState());
      return;
    }
    FormData formData = FormData.fromMap({
      'name': name,
      'phone': phone,
      'role': role,
      'location': location,
      'password': password,
    }, ListFormat.multiCompatible);

    for (var file in selectedImagesAgent) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            file.path,
            filename: file.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    DioHelper.postData(
          url: '/users',
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}),
        )
        .then((value) {
          emit(SignUpSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            print(error.response?.data["error"]);
            showToastError(
              text: error.response?.data["error"],
              context: context,
            );
            emit(SignUpErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  static ScrollController? scrollController;
  void initScrollController(BuildContext context) {
    if (scrollController != null) return;
    scrollController = ScrollController();
    scrollController!.addListener(() {
      if (scrollController!.position.pixels >=
              scrollController!.position.maxScrollExtent - 200 &&
          !isLastPage1 &&
          !isLoadingMoreUsers) {
        getNameUser(page: (currentPage1 + 1).toString(), context: context);
      }
    });
  }

  bool isLoadingMoreUsers = false;
  List<User> user = [];
  Pagination? pagination2;
  int currentPage1 = 1;
  bool isLastPage1 = false;
  void getNameUser({required BuildContext? context, required String page}) {
    if (isLoadingMoreUsers) return;
    isLoadingMoreUsers = true;
    emit(GetNameUserLoadingState());
    DioHelper.getData(url: '/usersOnly?page=$page')
        .then((value) {
          final newData = GetNameUser.fromJson(value.data);
          user.addAll(newData.users);
          pagination2 = newData.pagination;
          currentPage1 = pagination2!.currentPage;
          if (currentPage1 >= pagination2!.totalPages) {
            isLastPage1 = true;
          }
          emit(GetNameUserSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context!);
            emit(GetNameUserErrorState());
          } else {
            print("Unknown Error: $error");
          }
        })
        .whenComplete(() {
          isLoadingMoreUsers = false;
        });
  }

  void deleteUser({required String id, required BuildContext context}) {
    emit(DeleteUserLoadingState());
    DioHelper.deleteData(url: '/users/$id')
        .then((value) {
          user.removeWhere((getUserModel) => getUserModel.id.toString() == id);
          user.removeWhere((getUserModel) => getUserModel.id.toString() == id);
          showToastSuccess(text: 'تم الحذف بنجاح', context: context);
          emit(DeleteUserSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(DeleteUserErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void updateOrder({
    required BuildContext context,
    required String id,
    required String status,
  }) {
    emit(UpdateOrderLoadingState());
    DioHelper.patchData(
          url: '/orders/$id/status',
          token: token,
          data: {'status': status},
        )
        .then((value) {
          ordersAdminModel!.orders.removeWhere((p) => p.id.toString() == id);
          emit(UpdateOrderSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(text: error.toString(), context: context);
            print(error.toString());
            emit(UpdateOrderErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  Map<String, dynamic>? whatsAppStatus;
  String? whatsAppQrImage;

  String _whatsAppErrorMessage(DioError error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return data["error"]?.toString() ?? error.toString();
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return error.toString();
  }

  void getWhatsAppStatus({required BuildContext context}) {
    emit(WhatsAppLoadingState());
    DioHelper.getData(url: '/whatsapp/status', token: token)
        .then((value) {
          whatsAppStatus = Map<String, dynamic>.from(value.data);
          emit(WhatsAppStatusSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: _whatsAppErrorMessage(error),
              context: context,
            );
            print(_whatsAppErrorMessage(error));
            emit(WhatsAppErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void initWhatsApp({required BuildContext context}) {
    emit(WhatsAppLoadingState());
    DioHelper.postData(url: '/whatsapp/init', token: token, data: {})
        .then((value) {
          whatsAppStatus = Map<String, dynamic>.from(value.data);
          emit(WhatsAppInitSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: _whatsAppErrorMessage(error),
              context: context,
            );
            print(_whatsAppErrorMessage(error));
            emit(WhatsAppErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void getWhatsAppQr({required BuildContext context}) {
    emit(WhatsAppLoadingState());
    DioHelper.getData(url: '/whatsapp/qr', token: token)
        .then((value) {
          final data = Map<String, dynamic>.from(value.data);
          whatsAppStatus = data;
          whatsAppQrImage = data['qrImage']?.toString();
          emit(WhatsAppQrSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: _whatsAppErrorMessage(error),
              context: context,
            );
            print(_whatsAppErrorMessage(error));
            emit(WhatsAppErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void logoutWhatsApp({required BuildContext context}) {
    emit(WhatsAppLoadingState());
    DioHelper.postData(url: '/whatsapp/logout', token: token, data: {})
        .then((value) {
          whatsAppStatus = Map<String, dynamic>.from(value.data);
          whatsAppQrImage = null;
          emit(WhatsAppLogoutSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: _whatsAppErrorMessage(error),
              context: context,
            );
            print(_whatsAppErrorMessage(error));
            emit(WhatsAppErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }

  void sendWhatsAppTest({
    required BuildContext context,
    required String phone,
    required String message,
  }) {
    emit(WhatsAppLoadingState());
    DioHelper.postData(
          url: '/whatsapp/send',
          token: token,
          data: {'phone': normalizePhone(phone), 'message': message},
        )
        .then((value) {
          showToastSuccess(
            text: 'تم إرسال الرسالة التجريبية بنجاح',
            context: context,
          );
          emit(WhatsAppSendSuccessState());
        })
        .catchError((error) {
          if (error is DioError) {
            showToastError(
              text: _whatsAppErrorMessage(error),
              context: context,
            );
            print(_whatsAppErrorMessage(error));
            emit(WhatsAppErrorState());
          } else {
            print("Unknown Error: $error");
          }
        });
  }
}
