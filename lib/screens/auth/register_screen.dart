import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/theme.dart';
import '../../widgets/custom_snackbar.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final RxBool agreeToTerms = false.obs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(
            () => ListView(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Create an account so you can Find",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: controller.nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "Full name",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "Valid email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.passwordController,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Strong Password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        checkColor: AppTheme.primaryColor,
                        fillColor: WidgetStateProperty.all(Colors.white),
                        value: agreeToTerms.value,
                        onChanged: (val) {
                          agreeToTerms.value = val ?? false;
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "By checking the box you agree to our Terms and Conditions.",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : () {
                              final name =
                                  controller.nameController.text.trim();
                              final email =
                                  controller.emailController.text.trim();
                              final password =
                                  controller.passwordController.text;

                              final isValidEmail = RegExp(
                                r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$",
                              ).hasMatch(email);

                              if (name.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty) {
                                showError("All fields are required!");
                              } else if (!isValidEmail) {
                                showError(
                                  "Please enter a valid email address.",
                                );
                              } else if (password.length < 6) {
                                showError(
                                  "Password must be at least 6 characters.",
                                );
                              } else if (!agreeToTerms.value) {
                                showError(
                                  "You must agree to the terms and conditions.",
                                );
                              } else {
                                controller.registerUser();
                              }
                            },
                    child:
                        controller.isLoading.value
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                            : const Text("Register"),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a member?",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Log In",
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
