import 'package:flutter/material.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/models/locations.dart';

class FilterSheetBusinesses extends StatefulWidget {
  final List<Locations> locations;
  final List<Category> categories;
  final Function(Map<String, dynamic>) onApply;

  const FilterSheetBusinesses({
    super.key,
    required this.locations,
    required this.categories,
    required this.onApply,
  });

  @override
  State<FilterSheetBusinesses> createState() => _FilterSheetBusinessesState();
}

class _FilterSheetBusinessesState extends State<FilterSheetBusinesses> {
  Locations? selectedLocation;
  Category? selectedCategory;

  void resetFilters() {
    setState(() {
      selectedLocation = null;
      selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small drag handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Location dropdown
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Location",
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Locations>(
            value: selectedLocation,
            items: widget.locations.map((location) {
              return DropdownMenuItem<Locations>(
                value: location,
                child: Text(
                  '${location.county!}, ${location.town!}, ${location.area!}',
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedLocation = value);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          const SizedBox(height: 16),

          // Category dropdown
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Category",
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Category>(
            value: selectedCategory,
            items: widget.categories.map((category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.categoryName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedCategory = value);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: resetFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF126E06),
                  side: const BorderSide(color: Color(0xFF126E06), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  "Reset",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApply({
                    "location": selectedLocation,
                    "category": selectedCategory,
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF126E06),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 3,
                ),
                child: const Text(
                  "Apply",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
