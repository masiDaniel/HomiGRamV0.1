import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:homi_2/views/Shared/home_page_v1.dart';
import 'package:homi_2/views/Shared/profile_page.dart';
import 'package:homi_2/views/Tenants/renting_page.dart';
import 'package:homi_2/views/Shared/search_page.dart';
import 'package:homi_2/views/landlord/management.dart';

class CustomBottomNavigartion extends StatefulWidget {
  const CustomBottomNavigartion({super.key});

  @override
  State<CustomBottomNavigartion> createState() => _HomePageState();
}

class _HomePageState extends State<CustomBottomNavigartion> {
  int _selectedIndex = 0;
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _checkUserDetails();
  }

  Future<void> _loadUserType() async {
    String? type = await UserPreferences.getUserType();
    setState(() {
      userType = type ?? 'tenant';
    });
  }

  Future<void> _checkUserDetails() async {
    String? phone = await UserPreferences.getPhoneNumber();
    int? idNumber = await UserPreferences.getIdNumber();

    if (phone == null || phone.isEmpty || idNumber == null) {
      _showUserDetailsDialog(phone, idNumber);
    }
  }

  List<Widget> get _pages {
    if ((userType ?? 'tenant') == 'landlord') {
      return const [
        HomePage(),
        SearchPage(),
        // MarketPlace(),
        LandlordManagement(),
        ProfilePage(),
      ];
    } else {
      return const [
        HomePage(),
        SearchPage(),
        // MarketPlace(),
        RentingPage(),
        ProfilePage(),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _onWillPop();
      },
      child: Scaffold(
        body: _pages.elementAt(_selectedIndex),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedItemColor: const Color(0xFF059205),
                unselectedItemColor: Colors.grey.shade500,
                showUnselectedLabels: true,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home, size: 28),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search, size: 28),
                    label: "Search",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money_outlined),
                    activeIcon: Icon(Icons.attach_money, size: 28),
                    label: "Rent",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person, size: 28),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDetailsDialog(String? phone, int? idNumber) {
    final phoneController = TextEditingController(text: phone ?? '');
    final idController =
        TextEditingController(text: idNumber?.toString() ?? '');

    bool isPhoneValid = false;
    bool isIdValid = false;

    String? phoneError;
    String? idError;

    // Determine which fields are missing
    final bool needsPhone = phone == null || phone.isEmpty;
    final bool needsId = idNumber == null || idNumber == 0;

    // Pre-validate fields that already exist
    if (!needsPhone && RegExp(r'^07\d{8}$').hasMatch(phone)) {
      isPhoneValid = true;
    }
    if (!needsId && RegExp(r'^\d{8}$').hasMatch(idNumber.toString())) {
      isIdValid = true;
    }

    void validateInputs(void Function(void Function()) setState) {
      String phoneText = phoneController.text.trim();
      String idText = idController.text.trim();

      setState(() {
        if (needsPhone) {
          // Validate phone number (07xxxxxxxx)
          if (RegExp(r'^07\d{8}$').hasMatch(phoneText)) {
            isPhoneValid = true;
            phoneError = null;
          } else {
            isPhoneValid = false;
            phoneError = "Enter a valid phone number (07xxxxxxxx)";
          }
        }

        if (needsId) {
          // Validate ID number (8 digits)
          if (RegExp(r'^\d{8}$').hasMatch(idText)) {
            isIdValid = true;
            idError = null;
          } else {
            isIdValid = false;
            idError = "Enter a valid 8-digit ID number";
          }
        }
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  "Complete Your Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF015505),
                  ),
                ),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (needsPhone) ...[
                        TextField(
                          controller: phoneController,
                          onChanged: (_) => validateInputs(setState),
                          decoration: InputDecoration(
                            labelText: "Phone Number - (07xxxxxxxx)",
                            labelStyle:
                                const TextStyle(color: Color(0xFF015505)),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF015505), width: 2),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorText: phoneError,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (needsId)
                        TextField(
                          controller: idController,
                          onChanged: (_) => validateInputs(setState),
                          decoration: InputDecoration(
                            labelText: "ID Number - (xxxxxxxx)",
                            labelStyle:
                                const TextStyle(color: Color(0xFF015505)),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF015505), width: 2),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorText: idError,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                    ],
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  ElevatedButton(
                    onPressed: (needsPhone ? isPhoneValid : true) &&
                            (needsId ? isIdValid : true)
                        ? () async {
                            final updatedData = <String, dynamic>{};
                            if (needsPhone) {
                              updatedData['phone_number'] =
                                  phoneController.text;
                            }
                            if (needsId) {
                              updatedData['id_number'] =
                                  int.tryParse(idController.text);
                            }

                            await updateUserInfo(updatedData);
                            await UserPreferences.savePartialUserData(
                                updatedData);

                            if (!mounted) return;
                            showCustomSnackBar(context, 'Profile updated!');
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF015505),
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
