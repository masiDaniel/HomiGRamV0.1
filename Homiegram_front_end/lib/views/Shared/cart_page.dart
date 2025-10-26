import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/cart.dart';
import 'package:homi_2/services/cart_services.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:lottie/lottie.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService();
  late Future<Cart?>
      userCartFuture; // Use Future instead of manually handling state

  @override
  void initState() {
    super.initState();
    userCartFuture = _loadCart();
  }

  Future<Cart?> _loadCart() async {
    int? userId = await UserPreferences.getUserId();
    return await cartService.getCart(userId);
  }

//  TODO creation is not working seamlesly i the frontend
  Future<void> _createCart() async {
    int? userId = await UserPreferences.getUserId();
    if (userId == null) return;

    try {
      Cart? newCart = await cartService.createCart(userId);
      if (newCart != null) {
        if (!mounted) return;

        showCustomSnackBar(context, "cart created succesfully!");
        setState(() {
          userCartFuture = Future.value(newCart);
        });
      }
      if (!mounted) return;

      showCustomSnackBar(context, "Creation failed!");
    } catch (e) {
      debugPrint("Error creating cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO :  style this page better, meaningful information
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),
      body: FutureBuilder<Cart?>(
        future: userCartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show network or server error
            return Center(
              child: Lottie.asset(
                'assets/animations/notFound.json',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            );
          }

          final userCart = snapshot.data;
          if (userCart == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No cart found. Create one to start shopping."),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Create Cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return userCart.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/empty_cart.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Your cart is empty!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: userCart.products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("Product ID: ${userCart.products[index]}"),
                    );
                  },
                );
        },
      ),
    );
  }
}
