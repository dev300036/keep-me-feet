import 'package:flutter/material.dart';
import 'recipe_data.dart';

// ══════════════════════════════════════════════════════
// Recipe Detail Page
// ══════════════════════════════════════════════════════
class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats row
                  _statsRow(),
                  const SizedBox(height: 16),
                  // Nutrition card
                  _nutritionCard(),
                  const SizedBox(height: 20),
                  // Description
                  _sectionTitle('About'),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF555555),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Ingredients
                  _sectionTitle('Ingredients'),
                  const SizedBox(height: 10),
                  ...recipe.ingredients.map((ing) => _ingredientRow(ing)),
                  const SizedBox(height: 20),
                  // Steps
                  _sectionTitle('Instructions'),
                  const SizedBox(height: 10),
                  ...recipe.steps.asMap().entries.map(
                    (e) => _stepRow(e.key + 1, e.value),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          recipe.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1B5E20), recipe.color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(recipe.emoji, style: const TextStyle(fontSize: 80)),
          ),
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        _StatChip(
          icon: Icons.schedule,
          label: 'Prep',
          value: '${recipe.prepMins}m',
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.local_fire_department,
          label: 'Cook',
          value: '${recipe.cookMins}m',
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.people_outline,
          label: 'Serves',
          value: '${recipe.servings}',
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.bolt,
          label: 'Cals',
          value: recipe.calories.split(' ')[0],
        ),
      ],
    );
  }

  Widget _nutritionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NutrientInfo(
            label: 'Protein',
            value: '${recipe.protein}g',
            emoji: '💪',
          ),
          _divider(),
          _NutrientInfo(label: 'Carbs', value: '${recipe.carbs}g', emoji: '🌾'),
          _divider(),
          _NutrientInfo(label: 'Fat', value: '${recipe.fat}g', emoji: '🟡'),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 40, width: 1, color: Colors.white24);

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1B5E20),
    ),
  );

  Widget _ingredientRow(String ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(int num, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF444444),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF1B5E20),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientInfo extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  const _NutrientInfo({
    required this.label,
    required this.value,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
