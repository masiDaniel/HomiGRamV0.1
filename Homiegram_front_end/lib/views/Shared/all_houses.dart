import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

class AllHouses extends StatefulWidget {
  const AllHouses({super.key});

  @override
  AllHousesState createState() => AllHousesState();
}

class AllHousesState extends State<AllHouses> {
  List<dynamic> houses = []; // bad for performance use the actual model

  // this is used in this class only
  Future<void> fetchHouses() async {
    String? token = await UserPreferences.getAuthToken();
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };
    final response = await http.get(Uri.parse('$devUrl/houses/gethouses/'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      setState(() {
        houses = json.decode(response.body);
      });
    } else {
      log('Failed to load houses: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('all houses'),
      ),
      body: ListView.builder(
        itemCount: houses.length,
        itemBuilder: (context, index) {
          final house = houses[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                '$devUrl${house['image']}',
              ),
              maxRadius: 30,
            ),
            title: Text(
              house['name'],
              style: GoogleFonts.carterOne(
                fontSize: 25,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Address: ${house['location']}"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text('price: ${house['rent_amount']}'),
                  const SizedBox(
                    height: 5,
                  ),
                  Text('Rating: ${house['rating']}'),
                  const SizedBox(
                    height: 5,
                  ),
                  Text('description: ${house['description']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
