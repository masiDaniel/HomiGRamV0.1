import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/business_services.dart';
import 'package:homi_2/services/get_amenities.dart';
import 'package:homi_2/services/get_locations.dart';
import 'package:homi_2/services/post_house_service.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:image_picker/image_picker.dart';

class AddHousePage extends StatefulWidget {
  const AddHousePage({super.key});

  @override
  AddHousePageState createState() => AddHousePageState();
}

class AddHousePageState extends State<AddHousePage> {
  final _formKey = GlobalKey<FormState>();
  String _houseName = '';
  String _rentAmount = '';
  // int _location = 0;

  String _description = '';
  final String _bankName = '';
  final String __accountNumber = '';
  final List<String> _imageUrls = [];
  int? userIdShared;

  final PostHouseService postHouseService = PostHouseService();
  final ImagePicker _picker = ImagePicker();
  late Future<List<Locations>> futureLocations;
  late Future<List<Amenities>> futureAmenities;
  List<Locations> locations = [];
  List<Amenities> amenities = [];
  List<Amenities> selectedAmenities = [];
  List<Category> categories = [];
  bool isLoading = false;
  int? selectedLocationId;
  List<int> selectedIds = [];

  final TextEditingController houseAddressController = TextEditingController();
  final TextEditingController houseAmenitiesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadLocations();
    _loadAmenities();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await fetchCategorys();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _loadUserId() async {
    int? id = await UserPreferences.getUserId();
    setState(() {
      userIdShared = id ?? 0;
    });
  }

  Future<void> _pickImages() async {
    if (_imageUrls.length >= 16) {
      showCustomSnackBar(context, 'You can only select up to 4 images.');
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();

    final int remainingSlots = 16 - _imageUrls.length;

    setState(() {
      _imageUrls.addAll(
        images.take(remainingSlots).map((file) => file.path),
      );
    });

    if (!mounted) return;

    if (images.length > remainingSlots) {
      showCustomSnackBar(
          context, 'Some images were not added due to the 16-image limit.');
    }
  }

  void _loadLocations() {
    futureLocations = fetchLocations();

    futureLocations.then((locs) {
      setState(() {
        locations = locs;
      });
    });
  }

  void _loadAmenities() {
    futureAmenities = fetchAmenities();

    futureAmenities.then((ames) {
      setState(() {
        amenities = ames;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add House'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'House Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a house name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _houseName = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Rent Amount ie (1B - ks 4000, 2B - ks 5000)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rent amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _rentAmount = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: houseAddressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Location",
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
                TextFormField(
                  controller: houseAmenitiesController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Amenities",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        selectedIds = await showAmenitiesDialog(context);

                        if (selectedIds.isNotEmpty) {
                          // Show selected amenity names in the text field
                          houseAmenitiesController.text = amenities
                              .where((a) => selectedIds.contains(a.id))
                              .map((a) => a.name)
                              .join(", ");
                        }
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select at least one amenity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF105A01),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _pickImages,
                  child: const Text(
                    'Select Images',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                _imageUrls.isNotEmpty
                    ? Wrap(
                        spacing: 8.0,
                        children: _imageUrls.take(16).map((url) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                File(url),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageUrls.remove(url);
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : const Center(child: Text('No images selected.')),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'descripion',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a descriptiom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF105A01),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            final newHouse = GetHouse(
                              name: _houseName,
                              rentAmount: _rentAmount,
                              rating: 2,
                              description: _description,
                              images: _imageUrls,
                              amenities: selectedIds,
                              landlordId: userIdShared as int,
                              houseId: 0,
                              bankName: _bankName,
                              accountNumber: __accountNumber,
                              locationDetail: selectedLocationId,
                            );

                            setState(() {
                              isLoading = true;
                            });

                            bool success = await postHouseService
                                .postHouseWithImages(newHouse);

                            if (!context.mounted) return;

                            setState(() {
                              isLoading = false;
                            });

                            if (success) {
                              showCustomSnackBar(
                                  context, 'House added successfully!');
                              Navigator.pop(context);
                            } else {
                              showCustomSnackBar(
                                  context, 'Failed to add house.',
                                  type: SnackBarType.error);
                            }
                          }
                        },
                  child: isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFF105A01),
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Adding...',
                              style: TextStyle(color: Color(0xFF105A01)),
                            ),
                          ],
                        )
                      : const Text(
                          'Add House',
                          style: TextStyle(color: Colors.white),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                        color: Color(0xFF2D722F),
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
                            title:
                                Text("${loc.county}, ${loc.town}, ${loc.area}"),
                            onTap: () {
                              setState(() {
                                houseAddressController.text =
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

  Future<List<int>> showAmenitiesDialog(BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<Amenities> filteredAmenities = List.from(amenities);
    List<int> selectedAmenityIds = [];

    return await showDialog<List<int>>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text("Select Amenities you have"),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 350,
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            labelText: "Search amenity",
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (query) {
                            setState(() {
                              filteredAmenities = amenities
                                  .where((amenity) => amenity.name!
                                      .toLowerCase()
                                      .contains(query.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredAmenities.length,
                            itemBuilder: (context, index) {
                              final amenity = filteredAmenities[index];
                              final isSelected =
                                  selectedAmenityIds.contains(amenity.id);

                              return CheckboxListTile(
                                title: Text(amenity.name!),
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedAmenityIds.add(amenity.id!);
                                    } else {
                                      selectedAmenityIds.remove(amenity.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null), // Cancel
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, selectedAmenityIds),
                      child: const Text("Done"),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        [];
  }
}
