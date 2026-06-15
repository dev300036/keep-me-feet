import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../authentication/user_session.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  bool _isLoading = true;
  String? _planDescription;
  String? _dietitianName;
  String? _packageName;
  String? _errorMessage;
  final List<_MealData> _meals = [
    _MealData(
      time: '8:00 AM',
      type: 'Breakfast',
      name: 'Oatmeal with Berries',
      calories: 350,
      protein: 12,
      carbs: 60,
      fat: 8,
      isCompleted: true,
      emoji: '🥣',
    ),
    _MealData(
      time: '1:00 PM',
      type: 'Lunch',
      name: 'Grilled Chicken Salad',
      calories: 450,
      protein: 40,
      carbs: 20,
      fat: 15,
      isCompleted: false,
      emoji: '🥗',
    ),
    _MealData(
      time: '4:00 PM',
      type: 'Snack',
      name: 'Apple & Almonds',
      calories: 150,
      protein: 4,
      carbs: 22,
      fat: 7,
      isCompleted: false,
      emoji: '🍎',
    ),
    _MealData(
      time: '8:00 PM',
      type: 'Dinner',
      name: 'Baked Salmon with Veggies',
      calories: 500,
      protein: 45,
      carbs: 25,
      fat: 18,
      isCompleted: false,
      emoji: '🐟',
    ),
  ];

  int get _totalCalories => _meals.fold(0, (sum, m) => sum + m.calories);
  int get _consumedCalories =>
      _meals.where((m) => m.isCompleted).fold(0, (sum, m) => sum + m.calories);

  @override
  void initState() {
    super.initState();
    _fetchDietPlan();
  }

  Future<void> _fetchDietPlan() async {
    try {
      final userId = await UserSession.getUserId();
      if (userId == 0) {
        setState(() {
          _planDescription = 'Please log in to view your diet plan.';
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
        'http://10.107.148.193/client_project/api/my_dietplan.php?user_id=$userId',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' &&
            data['plans'] != null &&
            data['plans'].isNotEmpty) {
          final plan = data['plans'][0];
          setState(() {
            _planDescription = plan['description'];
            _dietitianName = plan['dietitian_name'];
            _packageName = plan['package_name'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _planDescription =
                'No diet plan assigned yet. Book a dietitian to get started!';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _planDescription = 'No diet plan assigned yet.';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _planDescription =
            'No diet plan assigned yet. Book a dietitian to get started!';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Meal Plan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  _getTodayDate(),
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_consumedCalories / $_totalCalories kcal',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calorie Progress',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '${(_consumedCalories / _totalCalories * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _consumedCalories / _totalCalories,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE8F5E9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutrientBar(
                    label: 'Protein',
                    value: 101,
                    max: 120,
                    color: const Color(0xFF2E7D32),
                    unit: 'g',
                  ),
                  _NutrientBar(
                    label: 'Carbs',
                    value: 127,
                    max: 200,
                    color: Colors.orange,
                    unit: 'g',
                  ),
                  _NutrientBar(
                    label: 'Fat',
                    value: 48,
                    max: 70,
                    color: Colors.blue,
                    unit: 'g',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dynamic Plan Info Card
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade800),
            ),
          )
        else if (_planDescription != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _packageName != null && _packageName!.isNotEmpty
                            ? 'Plan: $_packageName'
                            : 'Your Diet Plan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_dietitianName != null && _dietitianName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Assigned by: $_dietitianName',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade600,
                      ),
                    ),
                  ),
                Text(
                  _planDescription!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

        if (!_isLoading) const SizedBox(height: 16),

        // AI Recommendation card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recommendation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Based on your activity, try increasing protein today.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 14,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Meal list
        const Text(
          'Meals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 12),
        ..._meals.asMap().entries.map((entry) {
          final meal = entry.value;
          return _MealCard(
            meal: meal,
            onToggle: () {
              setState(() {
                _meals[entry.key] = meal.copyWith(
                  isCompleted: !meal.isCompleted,
                );
              });
            },
          );
        }),
      ],
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _MealData {
  final String time;
  final String type;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final bool isCompleted;
  final String emoji;

  const _MealData({
    required this.time,
    required this.type,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.isCompleted,
    required this.emoji,
  });

  _MealData copyWith({bool? isCompleted}) {
    return _MealData(
      time: time,
      type: type,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      emoji: emoji,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class _MealCard extends StatelessWidget {
  final _MealData meal;
  final VoidCallback onToggle;

  const _MealCard({required this.meal, required this.onToggle});

  Color get _typeColor {
    switch (meal.type) {
      case 'Breakfast':
        return const Color(0xFFFF8F00);
      case 'Lunch':
        return const Color(0xFF2E7D32);
      case 'Snack':
        return const Color(0xFF7B1FA2);
      case 'Dinner':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: meal.isCompleted
            ? Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(meal.emoji, style: const TextStyle(fontSize: 20))],
          ),
        ),
        title: Text(
          meal.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: meal.isCompleted ? TextDecoration.lineThrough : null,
            color: meal.isCompleted ? Colors.grey : const Color(0xFF333333),
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                meal.type,
                style: TextStyle(
                  color: _typeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${meal.calories} kcal  •  ${meal.time}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: meal.isCompleted
                  ? const Color(0xFF2E7D32)
                  : Colors.transparent,
              border: Border.all(
                color: meal.isCompleted
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFCCCCCC),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: meal.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final String unit;

  const _NutrientBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value$unit',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / max,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
