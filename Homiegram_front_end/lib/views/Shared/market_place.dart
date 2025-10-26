import 'dart:io';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/services/create_chat_room.dart';
import 'package:homi_2/services/user_service.dart';
import 'package:homi_2/views/Shared/chat_page.dart';
import 'package:homi_2/views/Shared/filter_businesses.dart';
import 'package:flutter/material.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/models/get_users.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/business_services.dart';
import 'package:homi_2/services/get_locations.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/views/Shared/add_product_screen.dart';
import 'package:homi_2/views/Shared/cart_page.dart';
import 'package:homi_2/views/Shared/products_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

const devUrl = AppConstants.baseUrl;

class MarketPlace extends StatefulWidget {
  const MarketPlace({super.key});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  late Future<List<BusinessModel>> futureBusinesses;
  late Future<List<Locations>> futureLocations;
  List<BusinessModel> allBusinesses = [];
  List<Products> allProducts = [];
  List<BusinessModel> displayedBusinesses = [];
  List<Products> displayedProducts = [];
  List<Locations> locations = [];
  bool showBusinesses = true;
  File? _selectedImage;
  List<GerUsers> users = [];
  bool isLoading = false;
  List<Category> categories = [];
  Locations? selectedLocation;
  Category? selectedCategory;
  String? authToken;
  String? currentUserEmail;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadBusinessesAndLocations();
    _loadProducts();
    fetchUsers();
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

  String getCategoryNameById(int id) {
    final category = categories.firstWhere(
      (cat) => cat.categoryId == id,
      orElse: () => Category(categoryId: 0, categoryName: 'Unknown'),
    );
    return category.categoryName;
  }

  void _loadBusinessesAndLocations() {
    futureBusinesses = fetchBusinesses();
    futureLocations = fetchLocations();

    futureBusinesses.then((businesses) {
      setState(() {
        allBusinesses = businesses;
        displayedBusinesses = businesses;
      });
    });

    futureLocations.then((locs) {
      setState(() {
        locations = locs;
      });
    });
  }

  Future<void> _loadProducts() async {
    final products = await fetchProductsSeller();
    setState(() {
      allProducts = products;
      displayedProducts = products;
    });
  }

  Future<void> _refreshBusinesses() async {
    final businesses = await fetchBusinesses();
    setState(() {
      allBusinesses = businesses;
      displayedBusinesses = businesses;
    });
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedUsers = await UserService.fetchUsers();
      if (!mounted) return;
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Error fetching users!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a Business or Sell a Product'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF065F09)),
                onPressed: () => showBusinessCreationDialog(context),
                child: const Text(
                  'Business',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF065F09)),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProductPage(
                              businessId: 0,
                            )),
                  );

                  _loadProducts();
                },
                child: const Text(
                  'Product',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showBusinessCreationDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController businessNameController =
        TextEditingController();
    final TextEditingController contactNumberController =
        TextEditingController();
    final TextEditingController businessEmailController =
        TextEditingController();
    final TextEditingController businessAddressController =
        TextEditingController();
    int? selectedLocationId;

    void showLocationDialog(BuildContext context) {
      TextEditingController searchController = TextEditingController();
      List<Locations> filteredLocations = List.from(locations);

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text(
                    "Select Business Location (county, constituency, Location)"),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: "Search Location",
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (query) {
                          setState(() {
                            filteredLocations = locations
                                .where((loc) =>
                                    loc.county!
                                        .toLowerCase()
                                        .contains(query.toLowerCase()) ||
                                    loc.town!
                                        .toLowerCase()
                                        .contains(query.toLowerCase()) ||
                                    loc.area!
                                        .toLowerCase()
                                        .contains(query.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Can’t find your location? No worries! Reach out to us at help.homigram@gmail.com",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 135, 207, 137),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredLocations.length,
                          itemBuilder: (context, index) {
                            final loc = filteredLocations[index];
                            return ListTile(
                              title: Text(
                                  "${loc.county}, ${loc.town}, ${loc.area}"),
                              onTap: () {
                                setState(() {
                                  businessAddressController.text =
                                      "${loc.county}, ${loc.town}, ${loc.area}";
                                  selectedLocationId = loc.locationId;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a Business'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: businessNameController,
                    decoration:
                        const InputDecoration(labelText: 'Business Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the business name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: contactNumberController,
                    decoration: const InputDecoration(
                        labelText: 'Business Contact Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the contact number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: businessEmailController,
                    decoration: const InputDecoration(
                        labelText: 'Business Email Address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the email address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: businessAddressController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Business Location",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => showLocationDialog(context),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildImagePicker(
                    imageFile: _selectedImage,
                    onImagePicked: (file) =>
                        setState(() => _selectedImage = file),
                    label: 'Business Image',
                    validationMessage: 'Please pick an image',
                    context: context,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF023304)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 95, 9)),
              onPressed: () async {
                int? id = await UserPreferences.getUserId();
                if (formKey.currentState!.validate()) {
                  final businessData = {
                    'name': businessNameController.text,
                    'contact_number': contactNumberController.text,
                    'email': businessEmailController.text,
                    'location': selectedLocationId,
                    'owner': id,
                    'image': _selectedImage,
                  };

                  postBusiness(businessData, context).then((success) {
                    if (success) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Success'),
                            content:
                                const Text('Business created successfully!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _refreshBusinesses();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _filterResults(String query) {
    setState(() {
      displayedBusinesses = allBusinesses
          .where((business) =>
              business.businessName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      displayedProducts = allProducts
          .where((product) =>
              product.productName.toLowerCase().contains(query.toLowerCase()))
          .toList();
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

  String? getBusinessPhoneNumber(int businessId, List<GerUsers> users) {
    try {
      final matchedUser = users.firstWhere((user) => user.userId == businessId);

      return matchedUser.phoneNumber;
    } catch (e) {
      return null;
    }
  }

  String? getNameOfSeller(int sellerId, List<GerUsers> users) {
    try {
      final matchedUser = users.firstWhere((user) => user.userId == sellerId);
      String? fullName = " ${matchedUser.firstName}  ${matchedUser.lastName}";

      return fullName;
    } catch (e) {
      return null;
    }
  }

  void _onApplyFilters(Map<String, dynamic> filters) {
    setState(() {
      selectedLocation =
          filters["location"] is Locations ? filters["location"] : null;
      selectedCategory =
          filters["category"] is Category ? filters["category"] : null;
      // minRent = filters["min_rent"] ?? 0;
      // maxRent = filters["max_rent"] ?? 1000000;
    });

    applyFilters();
  }

  void applyFilters() {
    setState(() {
      final safeSearchQuery = searchQuery.toLowerCase();

      displayedBusinesses = allBusinesses.where((house) {
        final matchesSearch =
            house.businessName.toLowerCase().contains(safeSearchQuery);

        final matchesLocation = selectedLocation == null ||
            house.businessAddress == selectedLocation!.locationId;
        final matchesCategory = selectedCategory == null ||
            house.businessTypeId == selectedCategory!.categoryId;

        // final matchesAmenities = selectedAmenities.isEmpty ||
        //     selectedAmenities.every((a) => house.amenities.contains(a.name));

        // final rentValue = int.tryParse(house.rentAmount) ?? 0;
        // final safeMinRent = minRent ?? 0;
        // final safeMaxRent = maxRent ?? 1000000;
        // final matchesRent =
        //     rentValue >= safeMinRent && rentValue <= safeMaxRent;

        return matchesSearch && matchesLocation && matchesCategory;
        // matchesAmenities &&
        // matchesRent;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search Business Or Product...',
            border: InputBorder.none,
          ),
          onChanged: _filterResults,
        ),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
            ),
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(48),
                  ),
                ),
                builder: (_) => FilterSheetBusinesses(
                  locations: locations,
                  categories: categories,
                  onApply: _onApplyFilters,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => _showPopup(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _refreshBusinesses,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => showBusinesses = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: showBusinesses
                      ? const Color(0xFF126E06)
                      : const Color(0xFFADE0A8),
                ),
                child: const Text(
                  "Businesses",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => setState(() => showBusinesses = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !showBusinesses
                      ? const Color(0xFF126E06)
                      : const Color(0xFFADE0A8),
                ),
                child: const Text(
                  "Products",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          Expanded(
            child: showBusinesses ? _buildBusinessList() : _buildProductList(),
          ),
        ]),
      )),
    );
  }

  Widget buildImagePicker({
    required File? imageFile,
    required Function(File?) onImagePicked,
    required String label,
    required String validationMessage,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(source: ImageSource.gallery);
            if (picked != null) {
              onImagePicked(File(picked.path));
            }
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: imageFile != null
                ? Image.file(imageFile, fit: BoxFit.cover)
                : const Center(child: Text('Tap to pick image')),
          ),
        ),
        const SizedBox(height: 8),
        if (imageFile == null)
          Text(validationMessage, style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  // **Build Business List**
  Widget _buildBusinessList() {
    return RefreshIndicator(
      onRefresh: _refreshBusinesses,
      child: FutureBuilder<List<Locations>>(
        future: futureLocations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Colors.green, strokeWidth: 6.0),
                  SizedBox(height: 10),
                  Text("Loading, please wait...",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Lottie.asset(
                'assets/animations/notFound.json',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            List<Locations> locations = snapshot.data!;
            Map<int, Locations> locationMap = {
              for (var location in locations) location.locationId: location
            };

            return displayedBusinesses.isNotEmpty
                ? ListView.builder(
                    itemCount: displayedBusinesses.length,
                    itemBuilder: (context, index) {
                      BusinessModel business = displayedBusinesses[index];
                      String businessImage = business.businessImage.isNotEmpty
                          ? '$devUrl${business.businessImage}'
                          : 'assets/images/mustGo.jpeg';

                      Locations? businessLocation =
                          locationMap[business.businessAddress];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsPage(
                                  businessObject: business,
                                  businessId: business.businessId,
                                  businessName: business.businessName,
                                  businessOwnerId: business.businessOwnerId,
                                  businessPhoneNumber: business.contactNumber,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: BlurCachedImage(
                                      imageUrl: businessImage,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        business.businessName,
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF126E06),
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        businessLocation != null
                                            ? 'Location: ${businessLocation.area}, ${businessLocation.county}, ${businessLocation.town}'
                                            : 'Location: Unknown',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Text(
                                        'Contact: ${business.contactNumber}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Text(
                                        'Category: ${getCategoryNameById(business.businessTypeId)}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No businesses.'));
          } else {
            return const Center(child: Text('No locations available'));
          }
        },
      ),
    );
  }

  Widget _buildProductList() {
    return displayedProducts.isNotEmpty
        ? GridView.builder(
            itemCount: displayedProducts.length,
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 12.0, // space between columns
              mainAxisSpacing: 12.0, // space between rows
              childAspectRatio: 0.8, // controls card height
            ),
            itemBuilder: (context, index) {
              Products product = displayedProducts[index];
              String productImage = product.productImage.isNotEmpty
                  ? '$devUrl${product.productImage}'
                  : 'assets/images/mustGo.jpeg';

              return InkWell(
                onTap: () {
                  final parentContext = context;
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (sheetContext) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.message,
                              ),
                              title: const Text("Message Seller"),
                              onTap: () async {
                                Navigator.pop(sheetContext);
                                final chatRoom =
                                    await getOrCreatePrivateChatRoom(
                                        product.seller);

                                if (!parentContext.mounted) return;
                                Navigator.push(
                                  parentContext,
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(
                                      chat: chatRoom,
                                      token: authToken!,
                                      userEmail: currentUserEmail!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.phone,
                              ),
                              title: const Text("Call Seller"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                makePhoneCall(
                                  getBusinessPhoneNumber(
                                      product.seller, users)!,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  elevation: 4,
                  color: Theme.of(context).cardColor,
                  shadowColor: Theme.of(context).shadowColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: BlurCachedImage(
                          imageUrl: productImage,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Price: ${product.productPrice}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seller: ${getNameOfSeller(product.seller, users)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : const Center(child: Text('No Products.'));
  }
}
