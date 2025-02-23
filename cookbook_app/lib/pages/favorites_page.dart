import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../services/profile_service.dart';
import '../models/recipe_dto.dart';
import '../widgets/recipe_card.dart';
import '../widgets/app_drawer.dart';
import 'auth_screen.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  final ProfileService _profileService = ProfileService();

  late Stream<List<RecipeDto>> _recipesStream;
  List<String> _favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes();
    _recipesStream = _recipeService.getRecipesStream();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        actions: [
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
      body: StreamBuilder<List<RecipeDto>>(
        stream: _recipesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Рецепты не найдены'));
          }

          final favoriteRecipes = snapshot.data!.where((recipe) => _favoriteRecipes.contains(recipe.id)).toList();

          if (favoriteRecipes.isEmpty) {
            return const Center(child: Text('Нет избранных рецептов'));
          }

          return ListView.builder(
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = favoriteRecipes[index];
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
          );
        },
      ),
    );
  }
}
