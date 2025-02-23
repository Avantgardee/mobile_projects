import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe_dto.dart';
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import '../services/review_service.dart';
import '../widgets/custom_chip.dart';
import '../widgets/rating_modal.dart';
import '../widgets/rating_star.dart';
import '../widgets/review_modal.dart';

class RecipeDetailPage extends StatefulWidget {
  final RecipeDto recipe;
  final VoidCallback onAddToFavorites;
  final bool isBookmarked;
  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.onAddToFavorites,
    required this.isBookmarked,
  });
  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  int _currentPage = 0;
  bool _isBookmarked = false;
  final RatingService _ratingService = RatingService();
  final ReviewService _reviewService = ReviewService();
  final AuthService _authService = AuthService();
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
    _currentRating = widget.recipe.rating;
  }

  Future<void> _saveRating(RecipeDto recipe, int newRating) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }
      await _ratingService.rateRecipe(userId, recipe.id, newRating);
      final updatedRating = await _ratingService.getAverageRating(recipe.id);
      setState(() {
        _currentRating = updatedRating;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении оценки: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Container(
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.recipe.imageUrls.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        itemCount: widget.recipe.imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: widget.recipe.imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.recipe.imageUrls.length, (index) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20.0),
                          bottom: Radius.circular(20.0),
                        ),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.recipe.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: widget.recipe.foodSection.map((section) {
                                      return CustomChip(
                                        backgroundColor: const Color(0xFFE8F5E9),
                                        text: section,
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  RatingStars(
                                    rating: _currentRating,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return RatingModal(
                                            onSave: (newRating) {
                                              _saveRating(widget.recipe, newRating);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.recipe.description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.recipe.duration} минут',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 60,
                                child: IconButton(
                                  icon: Icon(
                                    _isBookmarked ? Icons.bookmark_added : Icons.bookmark,
                                    color: _isBookmarked ? Colors.amber : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isBookmarked = !_isBookmarked;
                                    });
                                    widget.onAddToFavorites();
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.comment),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return ReviewModal(
                                          recipeId: widget.recipe.id,
                                          reviewService: _reviewService,
                                          authService: _authService,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20.0),
                          bottom: Radius.circular(20.0),
                        ),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ингредиенты:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.recipe.ingredients.join(', '),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Шаги приготовления:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.recipe.recipeSteps.asMap().entries.map((entry) {
                                  final int index = entry.key + 1;
                                  final String step = entry.value;
                                  return Text(
                                    '$index. $step',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
