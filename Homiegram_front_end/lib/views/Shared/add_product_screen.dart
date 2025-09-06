import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/services/business_services.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class AddProductPage extends StatefulWidget {
  final int businessId;

  const AddProductPage({
    super.key,
    required this.businessId,
  });
  @override
  AddProductPageState createState() => AddProductPageState();
}

class AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController productNameController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController stockAvailableController = TextEditingController();
  int? selectedCategoryId;
  File? selectedImage;
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await fetchCategorys();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> submitProduct() async {
    if (_formKey.currentState!.validate()) {
      String? token = await UserPreferences.getAuthToken(); // Fetch auth token

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$devUrl/business/postProducts/'),
      );

      request.headers['Authorization'] = 'Token $token';
      request.fields['name'] = productNameController.text;
      request.fields['description'] = productDescriptionController.text;
      request.fields['price'] = productPriceController.text;
      request.fields['stock'] = stockAvailableController.text;
      if (widget.businessId != 0) {
        request.fields['business'] = widget.businessId.toString();
      }
      request.fields['category'] = selectedCategoryId.toString();

      if (selectedImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath('image', selectedImage!.path));
      }

      try {
        var response = await request.send();

        if (response.statusCode == 201) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/animations/success.json',
                        width: 100, height: 100),
                    const SizedBox(height: 10),
                    const Text("Product added successfully!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );

          await Future.delayed(const Duration(seconds: 4));
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          showCustomSnackBar(context, "Failed to add product");
        }
      } catch (e) {
        if (!mounted) return;
        showCustomSnackBar(context, "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: productNameController,
                      decoration:
                          const InputDecoration(labelText: "Product Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a product name";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: productDescriptionController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                    ),
                    TextFormField(
                      controller: productPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Price"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a price";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: stockAvailableController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Stock Available"),
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: categories.isNotEmpty
                          ? categories.map((category) {
                              return DropdownMenuItem(
                                value: category.categoryId,
                                child: Text(category.categoryName),
                              );
                            }).toList()
                          : [],
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text("Select Image"),
                    ),
                    const SizedBox(height: 10),
                    selectedImage != null
                        ? Image.file(selectedImage!, height: 100)
                        : Container(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: submitProduct,
                      child: const Text("Submit Product"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
