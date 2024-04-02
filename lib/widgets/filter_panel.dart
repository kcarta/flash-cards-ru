import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';

class FilterPanel extends StatefulWidget {
  final String currentFilter;
  final Map<String, bool> typeFilters;
  final Function(String, Map<String, bool>) onApplyFilters;

  const FilterPanel({
    super.key,
    required this.currentFilter,
    required this.typeFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late String currentFilter;
  late Map<String, bool> typeFilters;
  String? segmentControlValue = 'all'; // Initial value for the segment control

  @override
  void initState() {
    super.initState();
    currentFilter = widget.currentFilter;
    typeFilters = Map.from(widget.typeFilters);
    updateSegmentControlValueBasedOnTypeFilters();
  }

  void applyFilters() {
    widget.onApplyFilters(currentFilter, typeFilters);
  }

  void setAllTypeFilters(bool value) {
    setState(() {
      typeFilters.updateAll((key, val) => value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 16,
          thickness: 1,
          color: Colors.grey[300],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Learned Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              CupertinoSegmentedControl<String>(
                borderColor: CupertinoColors.activeBlue,
                selectedColor: CupertinoColors.activeBlue,
                unselectedColor: CupertinoColors.white,
                children: const {
                  "all": Text('All'),
                  "learned": Text('Learned'),
                  "unlearned": Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Not Learned')),
                },
                onValueChanged: (String value) {
                  setState(() {
                    currentFilter = value;
                  });
                },
                groupValue: currentFilter,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          height: 16,
          thickness: 1,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Word Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  CupertinoSegmentedControl<String>(
                    borderColor: CupertinoColors.activeBlue,
                    selectedColor: CupertinoColors.activeBlue,
                    unselectedColor: CupertinoColors.white,
                    padding: const EdgeInsets.all(4),
                    children: const {
                      "all": Text('All'),
                      "none": Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('None')),
                    },
                    onValueChanged: (String? value) {
                      if (value != null) {
                        setAllTypeFilters(value == 'all');
                      }
                      segmentControlValue = value; // Update the state to refresh the UI
                    },
                    groupValue: segmentControlValue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...typeFilters.keys.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type.capitalize,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      CupertinoSwitch(
                        activeColor: CupertinoColors.activeBlue,
                        value: typeFilters[type] ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            typeFilters[type] = value;
                            updateSegmentControlValueBasedOnTypeFilters();
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        Divider(
          height: 16,
          thickness: 1,
          color: Colors.grey[300],
        ),
        CupertinoButton(
          onPressed: applyFilters,
          child: const Text('Apply Filters', style: TextStyle(color: CupertinoColors.activeBlue)),
        ),
      ],
    );
  }

  void updateSegmentControlValueBasedOnTypeFilters() {
    // Determine if all or none of the typeFilters are true
    final allSelected = typeFilters.values.every((value) => value);
    final noneSelected = typeFilters.values.every((value) => !value);

    setState(() {
      if (allSelected) {
        segmentControlValue = 'all';
      } else if (noneSelected) {
        segmentControlValue = 'none';
      } else {
        segmentControlValue = null; // No selection
      }
    });
  }
}
