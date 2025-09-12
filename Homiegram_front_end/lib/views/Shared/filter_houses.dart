import 'package:flutter/material.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/models/locations.dart';

class FilterSheetHouses extends StatefulWidget {
  final List<Locations> locations;
  final List<Amenities> amenities;
  final Function(Map<String, dynamic>) onApply;

  const FilterSheetHouses({
    super.key,
    required this.locations,
    required this.amenities,
    required this.onApply,
  });

  @override
  State<FilterSheetHouses> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheetHouses> {
  Locations? selectedLocation;
  List<Amenities> selectedAmenities = [];
  RangeValues rentRange = const RangeValues(0, 500000);

  void resetFilters() {
    setState(() {
      selectedLocation = null;
      selectedAmenities.clear();
      rentRange = const RangeValues(0, 500000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top handle for modal
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Text(
            "Location",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
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
          // Rent range slider
          Text("Rent Range", style: Theme.of(context).textTheme.titleMedium),
          RangeSlider(
            values: rentRange,
            min: 0,
            max: 500000,
            divisions: 50,
            labels: RangeLabels(
              "${rentRange.start.toInt()}",
              "${rentRange.end.toInt()}",
            ),
            onChanged: (values) {
              setState(() => rentRange = values);
            },
          ),
          // // Amenities chips
          Text("Amenities", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.amenities.map((amenity) {
              final isSelected = selectedAmenities.contains(amenity);
              return FilterChip(
                label: Text(amenity.name!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedAmenities.add(amenity);
                    } else {
                      selectedAmenities.remove(amenity);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: resetFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF126E06),
                    side:
                        const BorderSide(color: Color(0xFF126E06), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final safeLocation = selectedLocation;
                    print("amenities $selectedAmenities");
                    widget.onApply({
                      "location": safeLocation,
                      "rent": rentRange,
                      "amenities": selectedAmenities,
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF126E06),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
