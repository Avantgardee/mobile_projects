import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_dto.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/review_service.dart';

class ReviewModal extends StatefulWidget {
  final String recipeId;
  final ReviewService reviewService;
  final AuthService authService;

  const ReviewModal({
    super.key,
    required this.recipeId,
    required this.reviewService,
    required this.authService,
  });

  @override
  _ReviewModalState createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _addReview() async {
    final userId = widget.authService.currentUser?.uid;
    if (userId == null) return;

    final text = _reviewController.text.trim();
    if (text.isEmpty) return;

    await widget.reviewService.addReview(userId, widget.recipeId, text);
    _reviewController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.reviewService.getReviews(widget.recipeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Отзывов пока нет'));
                  }

                  final reviews = snapshot.data!.docs;
                  final userId = widget.authService.currentUser?.uid;

                  String _getMonthName(int month) {
                    const months = [
                      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
                      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
                    ];
                    return months[month - 1];
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final isCurrentUser = review['userId'] == userId;
                      final timestamp = (review['timestamp'] as Timestamp?)?.toDate();
                      final formattedTime = timestamp != null
                          ? '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}, '
                          '${timestamp.day} ${_getMonthName(timestamp.month)}'
                          : 'Неизвестно';

                      return FutureBuilder<UserDto?>(
                        future: ProfileService().getUserById(review['userId']),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }

                          final user = userSnapshot.data;
                          final userName =
                              '${user?.firstName ?? 'Неизвестно'} ${user?.lastName ?? ''}';

                          return Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.blueAccent
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    review['text'],
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrentUser
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: 'Оставьте отзыв...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addReview,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
