import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/services/business_services.dart';
// import 'package:homi_2/services/create_chat_room.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:homi_2/views/Shared/add_product_screen.dart';
import 'package:homi_2/views/Shared/business_edit_page.dart';
import 'package:homi_2/views/Shared/pproduct_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductsPage extends StatefulWidget {
  final BusinessModel businessObject;
  final int businessId;
  final String businessName;
  final int businessOwnerId;
  final String businessPhoneNumber;

  const ProductsPage(
      {super.key,
      required this.businessObject,
      required this.businessId,
      required this.businessName,
      required this.businessOwnerId,
      required this.businessPhoneNumber});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  late Future<List<Products>> futureProducts;
  int? userId;

  @override
  void initState() {
    super.initState();

    futureProducts = fetchProducts();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    int? id = await UserPreferences.getUserId();
    setState(() {
      userId = id ?? 0; // Default to 'tenant' if null
    });
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products for ${widget.businessName}'),
      ),
      body: FutureBuilder<List<Products>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 6.0,
                  ),
                  SizedBox(height: 10),
                  Text("Loading, please wait...",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              )),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Products> filteredProducts = snapshot.data!
                .where((product) => product.businessId == widget.businessId)
                .toList();

            if (filteredProducts.isEmpty) {
              return const Center(child: Text('No products available.'));
            }

            return ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: product.productImage.isNotEmpty
                              ? BlurCachedImage(
                                  imageUrl: '$devUrl${product.productImage}',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/ad2.jpeg',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          product.productName,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(product.productDescription),
                        const SizedBox(height: 4.0),
                        Text(
                          'Price: Ksh ${product.productPrice}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 6, 95, 9)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(product: product),
                                ),
                              );
                            },
                            child: const Text(
                              'View Details',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No products available.'));
          }
        },
      ),
      floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: const Color(0xFF065F09),
          foregroundColor: Colors.white,
          overlayColor: const Color.fromARGB(255, 11, 71, 1),
          overlayOpacity: 0.8,
          elevation: 8.0,
          spaceBetweenChildren: 15,
          children: userId == widget.businessOwnerId
              ? [
                  SpeedDialChild(
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                    backgroundColor: const Color(0xFF03AA19),
                    label: 'Add product',
                    labelStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    labelBackgroundColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddProductPage(
                                  businessId: widget.businessId,
                                )),
                      );
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    backgroundColor: const Color(0xFF03AA19),
                    label: 'Edit business profile',
                    labelStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    labelBackgroundColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessEditPage(
                            business: widget.businessObject,
                          ),
                        ),
                      );
                    },
                  ),
                ]
              : [
                  // SpeedDialChild(
                  //   child: const Icon(
                  //     Icons.info,
                  //     color: Colors.white,
                  //   ),
                  //   backgroundColor: const Color(0xFF03AA19),
                  //   label: 'Business info',
                  //   labelStyle: const TextStyle(
                  //     fontSize: 16.0,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  //   labelBackgroundColor: Colors.white,
                  //   onTap: () {},
                  // ),
                  SpeedDialChild(
                    child: const Icon(Icons.call),
                    label: 'Call business',
                    onTap: () {
                      makePhoneCall(widget.businessPhoneNumber);
                    },
                  ),
                  // SpeedDialChild(
                  //   child: const Icon(Icons.message),
                  //   label: 'Message business',
                  //   onTap: () {
                  //     getOrCreatePrivateChatRoom(widget.businessId);
                  //   },
                  // ),
                ]),
    );
  }
}
