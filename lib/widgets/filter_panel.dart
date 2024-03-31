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

  @override
  void initState() {
    super.initState();
    currentFilter = widget.currentFilter;
    typeFilters = Map.from(widget.typeFilters);
  }

  void applyFilters() {
    widget.onApplyFilters(currentFilter, typeFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Learned Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // Larger text for the section title
              ),
              const SizedBox(height: 8),
              CupertinoSegmentedControl<String>(
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
              const Text(
                'Word Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...typeFilters.keys.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 64.0),
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
        const SizedBox(height: 8),
        Divider(
          height: 16,
          thickness: 1,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          onPressed: applyFilters,
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
}
