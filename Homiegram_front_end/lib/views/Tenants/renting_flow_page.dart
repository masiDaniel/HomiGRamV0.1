import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:http/http.dart' as http;

class RentFlowPage extends StatefulWidget {
  final int houseId;
  final int roomId;

  const RentFlowPage({super.key, required this.houseId, required this.roomId});

  @override
  State<RentFlowPage> createState() => _RentFlowPageState();
}

class _RentFlowPageState extends State<RentFlowPage> {
  final PageController _controller = PageController();
  bool _isLoading = false;
  bool _agreementChecked = false;
  Map<String, dynamic>? _agreementData;
  List<dynamic> _charges = [];
  double _total = 0.0;

  Future<void> startRent() async {
    setState(() => _isLoading = true);
    try {
      final token = await getAccessToken();
      final response = await http.post(
        Uri.parse("$devUrl/houses/initiate-renting-process/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "house_id": widget.houseId,
          "room_id": widget.roomId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
          _agreementData = data["agreement"];
        });
        _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Error: ${response.body} code ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> signAgreement() async {
    setState(() => _isLoading = true);
    try {
      final token = await getAccessToken();
      final response = await http.post(
        Uri.parse("$devUrl/houses/sign-agremment/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "agreement_id": _agreementData!["id"],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _agreementData = data["agreement"];
        });
        _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchChargesPreview() async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse("$devUrl/houses/payment-preview/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "agreement_id": _agreementData!["id"],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _charges = data["items"];
        _total = data["total"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.body}")),
      );
    }
  }

  Future<void> initiateStkPush() async {
    setState(() => _isLoading = true);
    try {
      final token = await getAccessToken();
      final response = await http.post(
        Uri.parse("$devUrl/houses/payment-initialization/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "agreement_id": _agreementData!["id"],
        }),
      );

      print("response body ${response.body}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final message =
            responseData['message'] ?? 'Payment initiated. Check your phone.';

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        final responseData = jsonDecode(response.body);
        final error = responseData['error'] ?? 'Something went wrong.';

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
              error,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('DISMISS',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> confirmRent() async {
    if (!_agreementChecked || _agreementData == null) return;

    setState(() => _isLoading = true);
    try {
      final token = await getAccessToken();
      final response = await http.post(
        Uri.parse("$devUrl/confirm-rent/${_agreementData!["id"]}/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room successfully rented!")),
        );
        Navigator.pop(context, true); // go back after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAgreementDetails() {
    if (_agreementData == null) {
      return const Text(
        "No agreement data",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agreement Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF154D07),
              ),
            ),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.home, "House", _agreementData!["house"]),
            _buildDetailRow(
                Icons.meeting_room, "Room", _agreementData!["room"]),
            _buildDetailRow(Icons.location_on, "Location",
                _agreementData!["house_location"]),
            _buildDetailRow(Icons.person, "Tenant", _agreementData!["tenant"]),
            _buildDetailRow(Icons.info, "Status", _agreementData!["status"]),
            if (_agreementData!.containsKey("rent_amount"))
              _buildDetailRow(Icons.attach_money, "Rent",
                  _agreementData!["rent_amount"].toString()),
            if (_agreementData!.containsKey("start_date"))
              _buildDetailRow(Icons.calendar_today, "Start Date",
                  _agreementData!["start_date"]),
            if (_agreementData!.containsKey("end_date"))
              _buildDetailRow(Icons.event, "End Date",
                  _agreementData!["end_date"] ?? "Not set"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.green[700]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? "N/A",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rent Room")),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // STEP 1: Start Rent
          Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Top text
                    const Expanded(
                      child: Center(
                        child: Text(
                          "✨ Thank you for believing in us!\n\nLet’s get you settled into the rental you love. With HomiGram, finding a place that matches your vibe and rental needs has never been easier. 🏡💫",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.9,
                          ),
                        ),
                      ),
                    ),

                    // Bottom button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                startRent();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0x95154D07),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Start Renting Process",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),

          // STEP 2: Agreement Details + Sign
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rental Agreement",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildAgreementDetails(),
                  ),
                ),
                const Divider(height: 30, thickness: 3),

                // Consent checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreementChecked,
                      onChanged: (val) {
                        setState(() => _agreementChecked = val ?? false);
                      },
                      activeColor: const Color(0xFF154D07),
                      checkColor: Colors.white,
                    ),
                    const Expanded(
                      child: Text(
                        "I agree to the terms above and understand that checking this box means I'm legally bound by the contract.",
                        style: TextStyle(fontSize: 14, height: 1.4),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _agreementChecked
                              ? () async {
                                  await signAgreement();
                                  await fetchChargesPreview();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF154D07),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Proceed to Checkout",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          // STEP 3: Payment
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Payment Breakdown",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._charges.map<Widget>((item) => ListTile(
                      title: Text(item["name"]),
                      trailing: Text("KES ${item["amount"]}"),
                    )),
                const Divider(),
                Text("Total: KES $_total",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),

                // Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _agreementChecked
                              ? () {
                                  initiateStkPush();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF154D07),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Pay with M-Pesa",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
