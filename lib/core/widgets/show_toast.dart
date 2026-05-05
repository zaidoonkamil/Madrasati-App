import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showToastError({
  required String text,
  required BuildContext context,
}) =>
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message:text,
      ),);

void showToastSuccess({
  required String text,
  required BuildContext context,
}) =>
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message:text,
      ),);

void showToastInfo({
  required String text,
  required BuildContext context,
}) =>
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        message:text,
      ),);