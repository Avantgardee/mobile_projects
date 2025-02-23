import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_dto.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RecipeDto>> getRecipesStream() {
    return _firestore.collection('recipes').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return RecipeDto.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addRecipe(RecipeDto recipe) async {
    final docRef = await _firestore.collection('recipes').add(recipe.toMap());

    final generatedId = docRef.id;

    await docRef.update({'id': generatedId});
  }

  // Future<void> loadRecipes() async {
  //   final List<RecipeDto> recipes = [
  //     RecipeDto(
  //       id: '5',
  //       name: 'Панна котта',
  //       description: 'Итальянский десерт с ванилью и ягодным соусом.',
  //       duration: 60,
  //       foodSection: ['Десерты', 'Итальянская кухня'],
  //       imageUrls: [
  //         'https://example.com/panna_cotta1.jpg',
  //         'https://example.com/panna_cotta2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/panna_cotta_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Подогреть сливки с ванилью и сахаром.',
  //         'Добавить желатин и перемешать до растворения.',
  //         'Разлить по формочкам и охладить в холодильнике 4 часа.',
  //         'Приготовить ягодный соус, смешав ягоды с сахаром.',
  //         'Подавать панна котту с соусом.',
  //       ],
  //       ingredients: [
  //         'Сливки',
  //         'Ваниль',
  //         'Сахар',
  //         'Желатин',
  //         'Ягоды',
  //       ],
  //     ),
  //     RecipeDto(
  //       id: '6',
  //       name: 'Лазанья',
  //       description: 'Многослойная паста с мясным соусом и сыром.',
  //       duration: 90,
  //       foodSection: ['Итальянская кухня', 'Основные блюда'],
  //       imageUrls: [
  //         'https://example.com/lasagna1.jpg',
  //         'https://example.com/lasagna2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/lasagna_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Приготовить мясной соус, обжарив фарш с луком и томатами.',
  //         'Слоить листы лазаньи с соусом и сыром.',
  //         'Запекать в духовке 40 минут.',
  //         'Подавать горячим.',
  //       ],
  //       ingredients: [
  //         'Листы лазаньи',
  //         'Фарш',
  //         'Лук',
  //         'Томатный соус',
  //         'Сыр',
  //         'Сливки',
  //       ],
  //     ),
  //     RecipeDto(
  //       id: '7',
  //       name: 'Тирамису',
  //       description: 'Итальянский десерт с кофе и маскарпоне.',
  //       duration: 50,
  //       foodSection: ['Десерты', 'Итальянская кухня'],
  //       imageUrls: [
  //         'https://example.com/tiramisu1.jpg',
  //         'https://example.com/tiramisu2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/tiramisu_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Приготовить кофе и охладить.',
  //         'Взбить маскарпоне с сахаром.',
  //         'Собрать десерт, чередуя печенье савоярди с кремом.',
  //         'Посыпать какао.',
  //         'Охладить перед подачей.',
  //       ],
  //       ingredients: [
  //         'Маскарпоне',
  //         'Печенье савоярди',
  //         'Кофе',
  //         'Сахар',
  //         'Какао',
  //       ],
  //     ),
  //     RecipeDto(
  //       id: '8',
  //       name: 'Ризотто с грибами',
  //       description: 'Итальянское ризотто с ароматными грибами и пармезаном.',
  //       duration: 40,
  //       foodSection: ['Итальянская кухня', 'Основные блюда'],
  //       imageUrls: [
  //         'https://example.com/risotto1.jpg',
  //         'https://example.com/risotto2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/risotto_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Обжарить лук и грибы на сливочном масле.',
  //         'Добавить рис и обжарить до прозрачности.',
  //         'Постепенно вливать бульон, помешивая.',
  //         'Добавить пармезан и подавать горячим.',
  //       ],
  //       ingredients: [
  //         'Рис арборио',
  //         'Грибы',
  //         'Лук',
  //         'Сливочное масло',
  //         'Бульон',
  //         'Пармезан',
  //       ],
  //     ),
  //     RecipeDto(
  //       id: '9',
  //       name: 'Стейк из лосося',
  //       description: 'Нежный стейк из лосося с лимоном и зеленью.',
  //       duration: 20,
  //       foodSection: ['Рыбные блюда', 'Основные блюда'],
  //       imageUrls: [
  //         'https://example.com/salmon1.jpg',
  //         'https://example.com/salmon2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/salmon_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Обжарить стейк лосося на сковороде с двух сторон.',
  //         'Добавить лимонный сок и зелень.',
  //         'Подавать с овощами или рисом.',
  //       ],
  //       ingredients: [
  //         'Стейк лосося',
  //         'Лимон',
  //         'Зелень',
  //         'Оливковое масло',
  //         'Соль',
  //         'Перец',
  //       ],
  //     ),
  //     RecipeDto(
  //       id: '10',
  //       name: 'Фалафель',
  //       description: 'Жареные шарики из нута с пряностями.',
  //       duration: 30,
  //       foodSection: ['Закуски', 'Вегетарианские блюда'],
  //       imageUrls: [
  //         'https://example.com/falafel1.jpg',
  //         'https://example.com/falafel2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/falafel_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Измельчить нут в блендере с пряностями.',
  //         'Сформировать шарики и обжарить во фритюре.',
  //         'Подавать с соусом тахини или хумусом.',
  //       ],
  //       ingredients: [
  //         'Нут',
  //         'Чеснок',
  //         'Кинза',
  //         'Кумин',
  //         'Мука',
  //         'Масло для жарки',
  //       ],
  //     ),
  //     RecipeDto(
  //       id: '11',
  //       name: 'Чизкейк',
  //       description: 'Нежный чизкейк с ягодным топпингом.',
  //       duration: 120,
  //       foodSection: ['Десерты', 'Американская кухня'],
  //       imageUrls: [
  //         'https://example.com/cheesecake1.jpg',
  //         'https://example.com/cheesecake2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/cheesecake_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Приготовить основу из печенья и масла.',
  //         'Смешать сливочный сыр, сахар и яйца.',
  //         'Выпекать в духовке 1 час.',
  //         'Охладить и украсить ягодами.',
  //       ],
  //       ingredients: [
  //         'Печенье',
  //         'Сливочное масло',
  //         'Сливочный сыр',
  //         'Сахар',
  //         'Яйца',
  //         'Ягоды',
  //       ],
  //     ),
  //     RecipeDto(
  //       id: '12',
  //       name: 'Рататуй',
  //       description: 'Французское овощное рагу с баклажанами и кабачками.',
  //       duration: 60,
  //       foodSection: ['Овощные блюда', 'Французская кухня'],
  //       imageUrls: [
  //         'https://example.com/ratatouille1.jpg',
  //         'https://example.com/ratatouille2.jpg',
  //       ],
  //       imgUrl: 'https://example.com/ratatouille_main.jpg',
  //       rating: 0,
  //       sumRatings: 0,
  //       totalRatings: 0,
  //       recipeSteps: [
  //         'Нарезать овощи кружочками.',
  //         'Выложить в форму и запекать 40 минут.',
  //         'Подавать с зеленью.',
  //       ],
  //       ingredients: [
  //         'Баклажаны',
  //         'Кабачки',
  //         'Помидоры',
  //         'Перец',
  //         'Чеснок',
  //         'Оливковое масло',
  //       ],
  //     ),
  //   ];
  //
  //   for (var recipe in recipes) {
  //     await addRecipe(recipe);
  //   }
  // }
}
