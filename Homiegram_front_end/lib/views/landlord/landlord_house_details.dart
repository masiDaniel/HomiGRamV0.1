import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/ads.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/get_users.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/fetch_ads_service.dart';
import 'package:homi_2/services/get_locations.dart';
import 'package:homi_2/services/get_rooms_service.dart';
import 'package:homi_2/services/house_service.dart';
import 'package:homi_2/services/user_service.dart';
import 'package:homi_2/views/landlord/add_room.dart';
import 'package:homi_2/views/landlord/edit_house_details.dart';
import 'package:homi_2/views/landlord/room_details_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
const devUrl = AppConstants.baseUrl;

class HouseDetailsPage extends StatefulWidget {
  final GetHouse house;

  const HouseDetailsPage({Key? key, required this.house}) : super(key: key);

  @override
  State<HouseDetailsPage> createState() => _HouseDetailsPageState();
}

class _HouseDetailsPageState extends State<HouseDetailsPage> {
  List<GerUsers> users = [];
  GerUsers? selectedUser;
  bool isLoading = false;
  File? selectedFile;
  String? localFilePath;
  File? _selectedImage;
  List<Locations> locations = [];
  TextEditingController caretakerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    checkCaretakerStatus();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      List<Locations> fetchedLocations = await fetchLocations();
      setState(() {
        locations = fetchedLocations;
      });
    } catch (e) {
      log('error fetching locations!');
    }
  }

  String getLocationName(int locationId) {
    final location = locations.firstWhere(
      (loc) => loc.locationId == locationId,
      orElse: () => Locations(
        locationId: 0,
        area: "unknown",
      ),
    );
    return '${location.area}, ${location.town}, ${location.county}';
  }

  String getUserName(int? cartakerId) {
    // TODO : Loading caretakers id instead of user id, two different models
    // refactor it to work

    final caretaker = users.firstWhere(
      (loc) => loc.userId == cartakerId,
      orElse: () => GerUsers(firstName: "select a user"),
    );
    return '${caretaker.firstName}, ${caretaker.email}';
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

  Future<void> _assignCaretaker() async {
    if (selectedUser == null) {
      showCustomSnackBar(context, 'Please select a user');
      return;
    }

    try {
      final success = await HouseService.assignCaretaker(
        houseId: widget.house.houseId,
        userId: selectedUser!.userId,
      );

      if (!mounted) return;

      if (success) {
        showCustomSnackBar(context, 'Caretaker assigned successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        'Error assigning caretaker',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _removeCaretaker() async {
    try {
      final success = await HouseService.removeCaretaker(
        houseId: widget.house.houseId,
        caretakerId: widget.house.caretakerId!,
      );

      if (!mounted) return;

      if (success) {
        showCustomSnackBar(context, 'Caretaker removed successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Error removing caretaker!');
    }
  }

  void showAdvertCreationDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();

    Future<void> selectDate(
        BuildContext context, TextEditingController controller) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        controller.text = pickedDate.toIso8601String().split('T')[0];
        // Format: YYYY-MM-DD
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Submit an Ad'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(titleController, 'Ad Title',
                          'Please enter the ad title'),
                      _buildTextField(descriptionController, 'Description',
                          'Please enter a description'),
                      buildImagePicker(
                        imageFile: _selectedImage,
                        onImagePicked: (file) =>
                            setState(() => _selectedImage = file),
                        label: 'Image',
                        validationMessage: 'Please pick an image',
                        context: context,
                      ),
                      _buildDatePickerField(context, startDateController,
                          'Start Date', selectDate),
                      _buildDatePickerField(
                          context, endDateController, 'End Date', selectDate),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final Ad businessData = Ad(
                          title: titleController.text,
                          description: descriptionController.text,
                          startDate: dateFormat
                              .format(DateTime.parse(startDateController.text)),
                          endDate: dateFormat
                              .format(DateTime.parse(endDateController.text)),
                        );

                        postAds(businessData, _selectedImage).then((message) {
                          if (context.mounted) {
                            _showSuccessDialog(context);
                            () => Navigator.of(context).pop();
                          }
                        }).catchError((error) {
                          if (context.mounted) {
                            _showErrorDialog(context, error.toString());
                          }
                        });
                      } catch (e, stackTrace) {
                        log("ERROR during ad submission: $e");
                        log("STACKTRACE:\n$stackTrace");

                        if (context.mounted) {
                          _showErrorDialog(context, e.toString());
                        }
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          value == null || value.isEmpty ? validationMessage : null,
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

  Widget _buildDatePickerField(BuildContext context,
      TextEditingController controller, String label, Function pickerFunction) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => pickerFunction(context, controller),
        ),
      ),
      readOnly: true,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a date' : null,
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Ad submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.house.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHouseDetailsCard(),
            SizedBox(height: deviceHeight * 0.01),
            const Text(
              'Rooms',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: deviceHeight * 0.015),
            FutureBuilder(
              future: fetchRoomsByHouse(widget.house.houseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  log("this is the error  ${snapshot.error}");
                  return const Center(child: Text('Error: Server Error'));
                } else if (snapshot.hasData) {
                  final rooms = snapshot.data!;

                  if (rooms.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No rooms found for this house.\nADD A ROOM!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final isAvailable = room.tenantId == 0;

                      final backgroundColor = isAvailable
                          ? Colors.white
                          : room.rentStatus
                              ? const Color(0xFF013803)
                              : const Color(0xFF8C1A1A);

                      final borderColor = isAvailable
                          ? const Color(0xFF013803)
                          : Colors.transparent;

                      final textColor =
                          isAvailable ? const Color(0xFF2C3E50) : Colors.white;

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomDetailsPage(room: room),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.roomName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.king_bed_outlined,
                                      size: 18, color: textColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${room.noOfBedrooms} Bedrooms',
                                    style: TextStyle(
                                        fontSize: 13, color: textColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.attach_money_rounded,
                                      size: 18, color: textColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${room.rentAmount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? const Color(0xFFE8F5E9)
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAvailable
                                      ? 'Available'
                                      : getUserName(room.tenantId),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: isAvailable
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    color: isAvailable
                                        ? const Color(0xFF013803)
                                        : Colors.white,
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
                  return const Center(child: Text('No rooms available'));
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color(0xFF013803),
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_home),
            label: 'Add Room',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RoomInputPage(apartmentId: widget.house.houseId),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.tv),
            label: 'Advertise',
            onTap: () {
              showAdvertCreationDialog(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: 'Edit house',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHouseDetailsPage(
                    house: widget.house,
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(
              isCaretakerAssigned ? Icons.person_remove : Icons.person_add,
              color: Colors.white,
            ),
            backgroundColor: isCaretakerAssigned
                ? const Color(0xFF7C0F05)
                : const Color(0xFF013803),
            label:
                isCaretakerAssigned ? 'Remove Caretaker' : 'Assign Caretaker',
            onTap: () async {
              if (isCaretakerAssigned) {
                _removeCaretaker();
              } else {
                GerUsers? picked = await showCaretakerDialog(context, users);
                if (picked != null) {
                  setState(() {
                    selectedUser = picked;
                    caretakerController.text =
                        "${picked.firstName} (${picked.email})";
                  });
                }
                _assignCaretaker();
              }
            },
          ),
        ],
      ),
    );
  }

  bool isCaretakerAssigned = false;

  void checkCaretakerStatus() {
    setState(() {
      isCaretakerAssigned = widget.house.caretakerId != null;
    });
  }

  Future<GerUsers?> showCaretakerDialog(
      BuildContext context, List<GerUsers> users) async {
    TextEditingController searchController = TextEditingController();
    List<GerUsers> filteredUsers = [];
    bool hasTyped = false;

    return await showDialog<GerUsers>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select a Caretaker"),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search caretaker",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        setState(() {
                          hasTyped = query.isNotEmpty;
                          filteredUsers = query.isNotEmpty
                              ? users
                                  .where((user) =>
                                      user.firstName!
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      user.email!
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                  .toList()
                              : [];
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    hasTyped
                        ? Expanded(
                            child: filteredUsers.isNotEmpty
                                ? ListView.builder(
                                    itemCount: filteredUsers.length,
                                    itemBuilder: (context, index) {
                                      final user = filteredUsers[index];
                                      return ListTile(
                                        title: Text(
                                            "${user.firstName} (${user.email})"),
                                        onTap: () {
                                          Navigator.pop(context, user);
                                        },
                                      );
                                    },
                                  )
                                : const Center(
                                    child:
                                        Text("No matching caretakers found."),
                                  ),
                          )
                        : const Center(
                            child: Text(
                              "Start typing to search for caretakers.",
                              style: TextStyle(color: Colors.grey),
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

  Widget _buildHouseDetailsCard() {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF013803), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: deviceHeight * 0.4,
            width: double.infinity,
            child: PageView.builder(
              itemCount: widget.house.images!.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: BlurCachedImage(
                    imageUrl: "$devUrl${widget.house.images![index]}",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.house.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 5),
                    Text(getLocationName(widget.house.locationDetail!),
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attach_money,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 5),
                    Text('ksh ${widget.house.rentAmount}',
                        style: const TextStyle(
                          fontSize: 16,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue, size: 18),
                    const SizedBox(width: 5),
                    Text('Caretaker: ${getUserName(widget.house.caretakerId)}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
