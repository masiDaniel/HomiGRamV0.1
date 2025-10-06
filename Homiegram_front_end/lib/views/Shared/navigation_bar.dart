import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text("Complete Your Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                      labelText: "Phone Number - (07xxxxxxxx)"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                      labelText: "ID Number - (xxxxxxxx)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                // TODO : how do i verify this data.
                onPressed: () async {
                  if (phoneController.text.isNotEmpty &&
                      idController.text.isNotEmpty) {
                    final updatedData = {
                      'phone_number': phoneController.text,
                      'id_number': idController.text,
                    };
                    await updateUserInfo(updatedData);
                    await UserPreferences.savePartialUserData({
                      'phone_number': phoneController.text,
                      'id_number': int.parse(idController.text),
                    });

                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }
}
