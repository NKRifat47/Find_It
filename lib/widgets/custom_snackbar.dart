import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSuccess(String message) {
  Get.snackbar(
    "Success",
    message,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );
}

void showError(String message) {
  Get.snackbar(
    "Error",
    message,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );
}
