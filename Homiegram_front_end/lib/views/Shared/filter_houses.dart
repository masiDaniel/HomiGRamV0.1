import 'package:flutter/material.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/models/locations.dart';

class FilterSheet extends StatefulWidget {
  final List<Locations> locations;
  final List<Amenities> amenities;
  final Function(Map<String, dynamic>) onApply;

  const FilterSheet({
    super.key,
    required this.locations,
    required this.amenities,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  Locations? selectedLocation;
  List<Amenities> selectedAmenities = [];
  RangeValues rentRange = const RangeValues(2000, 5000);

  void resetFilters() {
    setState(() {
      selectedLocation = null;
      selectedAmenities.clear();
      rentRange = const RangeValues(2000, 5000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location dropdown
          Text("Location", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButton<Locations>(
            value: selectedLocation,
            items: widget.locations.map((location) {
              return DropdownMenuItem<Locations>(
                value: location,
                child: Text(
                    '${location.county!}, ${location.town!}, ${location.area!}'),
              );
            }).toList(),
            onChanged: (Locations? value) {
              setState(() {
                selectedLocation = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // // Amenities chips
          // Text("Amenities", style: Theme.of(context).textTheme.titleMedium),
          // const SizedBox(height: 8),
          // Wrap(
          //   spacing: 8,
          //   children: widget.amenities.map((amenity) {
          //     final isSelected = selectedAmenities.contains(amenity);
          //     return FilterChip(
          //       label: Text(amenity.name!),
          //       selected: isSelected,
          //       onSelected: (selected) {
          //         setState(() {
          //           if (selected) {
          //             selectedAmenities.add(amenity);
          //           } else {
          //             selectedAmenities.remove(amenity);
          //           }
          //         });
          //       },
          //     );
          //   }).toList(),
          // ),

          // const SizedBox(height: 16),

          // // Rent range slider
          // Text("Rent Range", style: Theme.of(context).textTheme.titleMedium),
          // RangeSlider(
          //   values: rentRange,
          //   min: 0,
          //   max: 10000,
          //   divisions: 50,
          //   labels: RangeLabels(
          //     "${rentRange.start.toInt()}",
          //     "${rentRange.end.toInt()}",
          //   ),
          //   onChanged: (values) {
          //     setState(() => rentRange = values);
          //   },
          // ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: resetFilters,
                child: const Text("Reset"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF126E06),
                ),
                onPressed: () {
                  final safeLocation = selectedLocation ?? "";
                  final safeAmenities = selectedAmenities.toList();
                  print("these are the amenities $selectedAmenities");
                  // final safeMinRent = rentRange?.start.toInt() ?? 0;
                  // final safeMaxRent = rentRange?.end.toInt() ?? 1000000;

                  widget.onApply({
                    "location": safeLocation,
                    "amenities": safeAmenities,
                    // "min_rent": safeMinRent,
                    // "max_rent": safeMaxRent,
                  });
                  Navigator.pop(context);
                },
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
