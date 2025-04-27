import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home/home_screen.dart';
import '../widgets/custom_snackbar.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  var isLoading = false.obs;
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRememberedEmail();
  }

  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  Future<void> loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  Future<void> saveEmailToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      await prefs.setString('remembered_email', emailController.text.trim());
    } else {
      await prefs.remove('remembered_email');
    }
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      isLoading.value = true;
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCred.user!.updateDisplayName(name);

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        "uid": userCred.user!.uid,
        "name": name,
        "email": email,
        "createdAt": DateTime.now(),
      });

      showSuccess("Account created successfully!");
      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Registration failed.");
    } catch (e) {
      showError("Something went wrong. Try again.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final isValidEmail = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$",
    ).hasMatch(email);

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter email and password.");
      return;
    } else if (!isValidEmail) {
      showError("Please enter a valid email.");
      return;
    }

    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await saveEmailToPrefs();

      showSuccess("Login successful!");
      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Login failed.");
    } catch (e) {
      showError("Something went wrong.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
    showSuccess("Logged out.");
  }
}
