import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homi_2/components/api_client.dart';
import 'package:homi_2/models/business.dart';

Future<List<BusinessModel>> fetchBusinesses() async {
  final response = await apiGet("/business/getBusiness/");

  if (response.statusCode == 200) {
    final List<dynamic> businessData = json.decode(response.body);
    return businessData.map((json) => BusinessModel.fromJSon(json)).toList();
  } else {
    throw Exception('failed to fetch businesses: ${response.body}');
  }
}

Future<bool> postBusiness(
  Map<String, Object?> businessData,
  BuildContext context,
) async {
  try {
    // ✅ Case 1: multipart (with image upload)
    if (businessData['image'] is File) {
      File imageFile = businessData['image'] as File;

      // Convert other fields to Map<String, String>
      final fields = Map.fromEntries(
        businessData.entries
            .where((entry) => entry.key != "image")
            .map((entry) => MapEntry(entry.key, entry.value.toString())),
      );

      // Upload file + fields
      final request = await apiUploadFile(
        "/business/getBusiness/",
        fields,
        imageFile.path,
      );

      if (request.statusCode == 200 || request.statusCode == 201) {
        final responseBody = await request.stream.bytesToString();
        log("✅ Post business response: $responseBody");
        return true;
      } else {
        final error = await request.stream.bytesToString();
        log("❌ Post business error: $error");
        return false;
      }
    }

    // ✅ Case 2: plain JSON (no image)
    final response = await apiPost(
      "/business/getBusiness/",
      headers: {"Content-Type": "application/json"},
      body: json.encode(businessData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      log("✅ Post business success: ${response.body}");
      return true;
    } else {
      log("❌ Post business error: ${response.body}");
      return false;
    }
  } catch (e) {
    log("⚠️ Post business exception: $e");
    return false;
  }
}

Future<List<Category>> fetchCategorys() async {
  final response = await apiGet("/business/getCategorys/");

  if (response.statusCode == 200) {
    final List<dynamic> categoryData = json.decode(response.body);
    return categoryData.map((json) => Category.fromJSon(json)).toList();
  } else {
    throw Exception('failed to fetch categories: ${response.body}');
  }
}

Future<List<Products>> fetchProducts() async {
  final response = await apiGet("/business/getProducts/");

  if (response.statusCode == 200) {
    final List<dynamic> productsData = json.decode(response.body);
    return productsData.map((json) => Products.fromJSon(json)).toList();
  } else {
    throw Exception('failed to fetch products: ${response.body}');
  }
}

Future<List<Products>> fetchProductsSeller() async {
  final response = await apiGet("/business/getProducts/?business=null");

  if (response.statusCode == 200) {
    final List<dynamic> productsData = json.decode(response.body);
    return productsData.map((json) => Products.fromJSon(json)).toList();
  } else {
    throw Exception('failed to fetch seller products: ${response.body}');
  }
}

Future<bool> postProducts(
  Map<String, Object?> productData,
) async {
  final response = await apiPost(
    "/business/postProducts/",
    headers: {"Content-Type": "application/json"},
    body: json.encode(productData),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    log("Product posted successfully: ${response.body}");
    return true;
  } else {
    log("Failed to post product: ${response.body}");
    return false;
  }
}
