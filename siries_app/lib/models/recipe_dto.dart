class RecipeDto {
  final String id;
  final String name;
  final String description;
  final int duration;
  final List<String> foodSection;
  final List<String> imageUrls;
  final String imgUrl;
  final double rating;
  final int totalRatings;
  final int sumRatings;
  final List<String> recipeSteps;
  final List<String> ingredients;

  RecipeDto({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.foodSection,
    required this.imageUrls,
    required this.imgUrl,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.sumRatings = 0,
    this.recipeSteps = const [],
    this.ingredients = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'duration': duration,
      'foodSection': foodSection,
      'imageUrls': imageUrls,
      'imgUrl': imgUrl,
      'rating': rating,
      'totalRatings': totalRatings,
      'sumRatings': sumRatings,
      'recipeSteps': recipeSteps,
      'ingredients': ingredients,
    };
  }

  factory RecipeDto.fromMap(String id, Map<String, dynamic> map) {
    return RecipeDto(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      foodSection: List<String>.from(map['foodSection'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      imgUrl: map['imgUrl'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings'] ?? 0,
      sumRatings: map['sumRatings'] ?? 0,
      recipeSteps: List<String>.from(map['recipeSteps'] ?? []),
      ingredients: List<String>.from(map['ingredients'] ?? []),
    );
  }

  factory RecipeDto.fromFirestore(Map<String, dynamic> data, String id) {
    return RecipeDto(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      foodSection: List<String>.from(data['foodSection'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      imgUrl: data['imgUrl'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: data['totalRatings'] ?? 0,
      sumRatings: data['sumRatings'] ?? 0,
      recipeSteps: List<String>.from(data['recipeSteps'] ?? []),
      ingredients: List<String>.from(data['ingredients'] ?? []),
    );
  }
}
