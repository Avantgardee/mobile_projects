import 'package:flutter/material.dart';
import '../models/recipe_dto.dart';

class SearchModal extends StatefulWidget {
  final List<RecipeDto> recipes;
  final String initialSearchQuery;
  final List<String> initialSelectedFilters;
  final Function(String, List<String>, List<RecipeDto>) onSearch;

  const SearchModal({
    super.key,
    required this.recipes,
    required this.initialSearchQuery,
    required this.initialSelectedFilters,
    required this.onSearch,
  });

  @override
  _SearchModalState createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedFilters = [];
  List<RecipeDto> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearchQuery;
    _selectedFilters = widget.initialSelectedFilters;
    _filteredRecipes = _applyFilters(widget.recipes, _searchController.text, _selectedFilters);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterRecipes();
  }

  void _filterRecipes() {
    final query = _searchController.text.toLowerCase();
    final selectedFilters = _selectedFilters;

    setState(() {
      _filteredRecipes = _applyFilters(widget.recipes, query, selectedFilters);
    });

    widget.onSearch(query, selectedFilters, _filteredRecipes);
  }

  List<RecipeDto> _applyFilters(List<RecipeDto> recipes, String searchQuery, List<String> selectedFilters) {
    return recipes.where((recipe) {
      final matchesSearch = searchQuery.isEmpty || recipe.name.toLowerCase().contains(searchQuery);
      final matchesFilters = selectedFilters.isEmpty ||
          selectedFilters.every((filter) => recipe.foodSection.contains(filter));
      return matchesSearch && matchesFilters;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Поиск по названию',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8.0,
                children: widget.recipes
                    .expand((recipe) => recipe.foodSection)
                    .toSet()
                    .map((filter) {
                  return FilterChip(
                    label: Text(filter),
                    selected: _selectedFilters.contains(filter),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFilters.add(filter);
                        } else {
                          _selectedFilters.remove(filter);
                        }
                        _filterRecipes();
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }
}
