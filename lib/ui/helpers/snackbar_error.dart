import 'package:flutter/material.dart';
import 'package:get/get.dart';

void snackbarError({required String message}) {
  return Get.snackbar(
    'Error',
    message,
    icon: const Icon(
      Icons.error_outline_rounded,
      color: Color(0xffee6c4d),
    ),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
    backgroundColor: Color(0xffee6c4d).withOpacity(0.1),
  );
}
