import 'package:find_it/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../auth/login_screen.dart';
import 'my_post_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            title: const Text("Account"),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.secondaryColor,
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            user?.displayName ?? "User",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            user?.email ?? "",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 30),

          _buildTile(
            icon: Icons.post_add_outlined,
            label: "My Posts",
            onTap: () {
              Get.to(() => const MyPostsScreen());
            },
          ),
          _buildTile(
            icon: Icons.location_on_outlined,
            label: "Address",
            onTap: () {},
          ),
          _buildTile(icon: Icons.phone_outlined, label: "Phone", onTap: () {}),
          _buildTile(
            icon: Icons.notifications_none,
            label: "Notifications",
            onTap: () {},
          ),
          _buildTile(icon: Icons.info_outline, label: "About", onTap: () {}),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.find<AuthController>().clearControllers();

                  Get.offAll(() => const LoginScreen());
                },
                child: const Text("Log Out"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.secondaryColor),
      title: Text(label, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
