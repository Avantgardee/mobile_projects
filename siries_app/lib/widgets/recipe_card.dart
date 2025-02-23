import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe_dto.dart';
import '../pages/recipe_detail_page.dart';
import 'custom_chip.dart';

class RecipeCard extends StatelessWidget {
  final RecipeDto recipe;
  final VoidCallback onAddToFavorites;
  final bool isBookmarked;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onAddToFavorites,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          print("Переход на детальную страницу. isBookmarked: ${isBookmarked}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(
                recipe: recipe,
                onAddToFavorites: onAddToFavorites,
                isBookmarked: isBookmarked,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (recipe.imgUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: CachedNetworkImage(
                      imageUrl: recipe.imgUrl,
                      height: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                  child: Text(
                    recipe.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF323131),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.duration} минут',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF323131),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: recipe.foodSection.map((section) {
                      return CustomChip(
                        backgroundColor: const Color(0xFFE8F5E9),
                        text: section,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 25,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.rating.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 170,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_added : Icons.bookmark,
                  color: isBookmarked ? Colors.amber : Colors.grey,
                ),
                onPressed: onAddToFavorites,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
