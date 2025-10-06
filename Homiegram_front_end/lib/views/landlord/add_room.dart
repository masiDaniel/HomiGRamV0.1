import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/get_rooms_service.dart';

class RoomInputPage extends StatefulWidget {
  final int apartmentId;

  const RoomInputPage({super.key, required this.apartmentId});

  @override
  RoomInputPageState createState() => RoomInputPageState();
}

class RoomInputPageState extends State<RoomInputPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _numberOfBedroomsController =
      TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  Future<void> _submitRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final newRoom = GetRooms(
      roomId: 0,
      roomName: _roomNameController.text.trim(),
      noOfBedrooms: int.parse(_numberOfBedroomsController.text.trim()),
      sizeInSqMeters: _sizeController.text.trim(),
      rentAmount: _rentController.text.trim(),
      occuiedStatus: false,
      roomImages: '',
      apartmentID: widget.apartmentId,
      tenantId: 0,
      rentStatus: false,
    );
    try {
      final response = await postRoomsByHouse(widget.apartmentId, newRoom);

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response.isNotEmpty) {
        showCustomSnackBar(context, 'Room posted successfully!');
        _clearForm();
      } else {
        showCustomSnackBar(context, 'Failed to post room.',
            type: SnackBarType.error);
      }
    } catch (e) {
      setState(() => isLoading = false);
      showCustomSnackBar(context, 'Error: $e', type: SnackBarType.error);
    }
  }

  void _clearForm() {
    _roomNameController.clear();
    _numberOfBedroomsController.clear();
    _sizeController.clear();
    _rentController.clear();
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF105A01), width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room Name
              TextFormField(
                controller: _roomNameController,
                decoration: _inputDecoration('Room Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a room name'
                    : null,
              ),
              const SizedBox(height: 16),

              // Number of Bedrooms
              TextFormField(
                controller: _numberOfBedroomsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Number of Bedrooms'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of bedrooms';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Size
              TextFormField(
                controller: _sizeController,
                decoration: _inputDecoration('Size (in sq meters)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter room size' : null,
              ),
              const SizedBox(height: 16),

              // Rent Amount
              TextFormField(
                controller: _rentController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Rent Amount (Ksh)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rent amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF105A01),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : _submitRoom,
                child: isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Submitting...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : const Text(
                        'Submit Room Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _numberOfBedroomsController.dispose();
    _sizeController.dispose();
    _rentController.dispose();
    super.dispose();
  }
}
