import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_modal.dart';
import 'auth_screen.dart';
import '../models/recipe_dto.dart';
import '../widgets/recipe_card.dart';
import '../services/recipe_service.dart';
import '../services/profile_service.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  final ProfileService _profileService = ProfileService();
  late Stream<List<RecipeDto>> _recipesStream;
  List<RecipeDto> _recipes = [];
  List<RecipeDto> _filteredRecipes = [];
  List<String> _favoriteRecipes = [];
  String _searchQuery = '';
  List<String> _selectedFilters = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _loadFavoriteRecipes();
    _recipesStream = _recipeService.getRecipesStream();

    _recipesStream.listen((recipes) {
      setState(() {
        _recipes = recipes;
        _filteredRecipes = _applyFilters(recipes, _searchQuery, _selectedFilters);
      });
    });
  }

  Future<void> _loadFavoriteRecipes() async {
    try {
      final userProfile = await _profileService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _favoriteRecipes = userProfile.favoriteRecipes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке избранных: $e')),
      );
    }
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SearchModal(
          recipes: _recipes,
          initialSearchQuery: _searchQuery,
          initialSelectedFilters: _selectedFilters,
          onSearch: (searchQuery, selectedFilters, filteredRecipes) {
            setState(() {
              _searchQuery = searchQuery;
              _selectedFilters = selectedFilters;
              _filteredRecipes = filteredRecipes;
            });
          },
        );
      },
    );
  }

  List<RecipeDto> _applyFilters(List<RecipeDto> recipes, String searchQuery, List<String> selectedFilters) {
    return recipes.where((recipe) {
      final matchesSearch = searchQuery.isEmpty || recipe.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilters = selectedFilters.isEmpty ||
          selectedFilters.every((filter) => recipe.foodSection.contains(filter));
      return matchesSearch && matchesFilters;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список'),
        actions: [
          IconButton(
            onPressed: () {
              _showSearchModal(context);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () async {
              try {
                await _authService.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (Route<dynamic> route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при выходе: $e')),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _filteredRecipes.isEmpty
          ? const Center(child: Text('Рецепты не найдены'))
          : ListView.builder(
        itemCount: _filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _filteredRecipes[index];
          final isBookmarked = _favoriteRecipes.contains(recipe.id);

          return RecipeCard(
            recipe: recipe,
            onAddToFavorites: () async {
              try {
                await _profileService.toggleFavoriteRecipe(recipe);
                await _loadFavoriteRecipes();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            },
            isBookmarked: isBookmarked,
          );
        },
      ),
    );
  }
}
