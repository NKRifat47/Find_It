import 'dart:io';
import 'package:find_it/controllers/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final postController = Get.put(PostController());

  final List<File> _selectedImages = [];
  final ImagePicker picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (_selectedImages.length < 3) {
          _selectedImages.add(File(image.path));
        } else {
          Get.snackbar("Limit reached", "You can upload up to 3 images only");
        }
      });
    }
  }

  Future<void> _submitPost() async {
    final title = titleController.text.trim();
    final desc = descriptionController.text.trim();

    if (title.isEmpty || desc.isEmpty || _selectedImages.isEmpty) {
      Get.snackbar(
        "Missing fields",
        "Please fill all fields and add at least one image.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    postController.isUploading.value = true;

    final success = await postController.createPost(
      title: title,
      description: desc,
      images: _selectedImages,
    );

    postController.isUploading.value = false;

    if (success) {
      Get.snackbar(
        "Success",
        "Post created successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      titleController.clear();
      descriptionController.clear();
      setState(() => _selectedImages.clear());

      await Future.delayed(const Duration(milliseconds: 800));
      if (Get.isOverlaysOpen) {
        Get.back(result: true);
      }
    } else {
      Get.snackbar(
        "Failed",
        "Something went wrong, please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text("Create Post"),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              textInputAction: TextInputAction.next,
              controller: titleController,
              decoration: const InputDecoration(hintText: "Add Title"),
            ),
            const SizedBox(height: 15),
            TextField(
              textInputAction: TextInputAction.newline,
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "Add Description"),
            ),
            const SizedBox(height: 20),

            Row(
              children: List.generate(3, (index) {
                if (index < _selectedImages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child:
                              index == _selectedImages.length
                                  ? const Icon(Icons.add, size: 30)
                                  : Text(
                                    "Picture",
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                        ),
                      ),
                    ),
                  );
                }
              }),
            ),

            const SizedBox(height: 30),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      postController.isUploading.value ? null : _submitPost,
                  child:
                      postController.isUploading.value
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                          : const Text("POST"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
