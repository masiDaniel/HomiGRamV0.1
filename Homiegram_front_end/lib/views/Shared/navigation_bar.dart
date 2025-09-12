import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/views/Shared/home_page_v1.dart';
import 'package:homi_2/views/Shared/market_place.dart';
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
  }

  Future<void> _loadUserType() async {
    String? type = await UserPreferences.getUserType();
    setState(() {
      userType = type ?? 'tenant';
    });
  }

  List<Widget> get _pages {
    if ((userType ?? 'tenant') == 'landlord') {
      return const [
        HomePage(),
        SearchPage(),
        MarketPlace(),
        LandlordManagement(),
        ProfilePage(),
      ];
    } else {
      return const [
        HomePage(),
        SearchPage(),
        MarketPlace(),
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
        body: _pages.elementAt(_selectedIndex), // Ensure the index is valid
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.grey),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.grey),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shop, color: Colors.grey),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money, color: Colors.grey),
              label: 'Rent',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.grey),
              label: 'profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF059205),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
