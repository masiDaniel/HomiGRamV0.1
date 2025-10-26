import 'package:flutter/material.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/models/cart.dart';
import 'package:homi_2/services/cart_services.dart';
import 'package:homi_2/services/user_data.dart';

import 'package:lottie/lottie.dart';

class ProductDetailPage extends StatefulWidget {
  final Products product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CartService cartService = CartService();
  late Future<Cart?> userCartFuture;

  @override
  void initState() {
    super.initState();
    userCartFuture = _loadCart();
  }

  Future<Cart?> _loadCart() async {
    try {
      int? userId = await UserPreferences.getUserId();
      return await cartService.getCart(userId);
    } catch (e) {
      debugPrint("Error loading cart: $e");
      return null;
    }
  }

  Future<void> _addItemToCart(int productIds) async {
    final cart = await userCartFuture;
    if (cart == null) return;

    bool success = await cartService.addToCart(cart.id, productIds);

    if (success) {}
  }

  @override
  Widget build(BuildContext context) {
    String productImage = widget.product.productImage.isNotEmpty
        ? '$devUrl${widget.product.productImage}'
        : 'assets/images/ad2.jpeg';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.productName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BlurCachedImage(
                  imageUrl: productImage,
                  height: 480,
                  width: double.infinity,
                  fit: BoxFit.contain,
                )),
            const SizedBox(height: 16.0),
            Text(
              widget.product.productName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.product.productDescription,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Price: Ksh ${widget.product.productPrice}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Stock: ${widget.product.stockAvailable}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF065F09),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Purchase Options'),
                          content: const Text(
                            'Would you like to buy directly or add this item to your cart?',
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF065F09),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Lottie.asset(
                                            'assets/animations/moneySuccess.json',
                                            width: 100,
                                            height: 100,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Product purchased successfully!",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF065F09),
                              ),
                              onPressed: () {
                                // Navigator.of(context).pop();
                                _addItemToCart(widget.product.productId);
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Lottie.asset(
                                            'assets/animations/moneySuccess.json',
                                            width: 100,
                                            height: 100,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Product added to cart!",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Add to cart',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Buy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
