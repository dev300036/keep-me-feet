import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// Static Recipe Data
// ══════════════════════════════════════════════════════
class Recipe {
  final String emoji;
  final String name;
  final String category;
  final String calories;
  final int protein;
  final int carbs;
  final int fat;
  final int prepMins;
  final int cookMins;
  final int servings;
  final String description;
  final Color color;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    required this.emoji,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepMins,
    required this.cookMins,
    required this.servings,
    required this.description,
    required this.color,
    required this.ingredients,
    required this.steps,
  });
}

const List<Recipe> kAllRecipes = [
  Recipe(
    emoji: '🥗',
    name: 'Fruit Salad',
    category: 'Salad',
    calories: '250 kcal',
    protein: 8,
    carbs: 35,
    fat: 7,
    prepMins: 10,
    cookMins: 0,
    servings: 2,
    description:
        'A refreshing mix of seasonal fruits and veggies packed with vitamins and antioxidants. Perfect as a light meal or snack.',
    color: Color(0xFFE8F5E9),
    ingredients: [
      '1 cup cherry tomatoes, halved',
      '1 cucumber, diced',
      '1 avocado, cubed',
      '2 hard-boiled eggs, quartered',
      '1 tbsp olive oil',
      'Salt, pepper & lemon juice to taste',
      'Fresh parsley or mint',
    ],
    steps: [
      'Wash and prepare all vegetables.',
      'Combine tomatoes, cucumber, and avocado in a large bowl.',
      'Add quartered hard-boiled eggs.',
      'Drizzle with olive oil and lemon juice.',
      'Season with salt and pepper.',
      'Garnish with fresh parsley and serve chilled.',
    ],
  ),
  Recipe(
    emoji: '🥑',
    name: 'Avocado Bowl',
    category: 'Bowl',
    calories: '320 kcal',
    protein: 14,
    carbs: 22,
    fat: 22,
    prepMins: 8,
    cookMins: 5,
    servings: 1,
    description:
        'A creamy, nutrient-packed avocado bowl with spinach and egg — perfect for a powerful breakfast or post-workout meal.',
    color: Color(0xFFF1F8E9),
    ingredients: [
      '1 ripe avocado',
      '2 eggs',
      '1 cup baby spinach',
      '1 tomato, diced',
      '1 tbsp olive oil',
      'Red chili flakes, salt & pepper',
      'Sesame seeds for garnish',
    ],
    steps: [
      'Halve the avocado and remove the stone.',
      'Scoop out a little extra flesh to create space for the egg.',
      'Crack an egg into each avocado half.',
      'Bake at 200°C for 12–15 min until egg is set.',
      'Sauté spinach and tomato in olive oil.',
      'Serve avocado on spinach bed, sprinkle sesame seeds.',
    ],
  ),
  Recipe(
    emoji: '🍗',
    name: 'Grilled Chicken',
    category: 'High Protein',
    calories: '450 kcal',
    protein: 45,
    carbs: 5,
    fat: 15,
    prepMins: 15,
    cookMins: 20,
    servings: 2,
    description:
        'Juicy herb-marinated grilled chicken breast — the ultimate high-protein, low-carb meal for fitness enthusiasts.',
    color: Color(0xFFFFF8E1),
    ingredients: [
      '2 chicken breasts',
      '2 tbsp olive oil',
      '3 garlic cloves, minced',
      '1 lemon, juiced and zested',
      '1 tsp oregano, 1 tsp thyme',
      'Salt, pepper & paprika',
      'Fresh parsley to serve',
    ],
    steps: [
      'Mix olive oil, garlic, lemon juice, and spices in a bowl.',
      'Marinate chicken for at least 30 minutes (or overnight).',
      'Preheat grill to medium-high heat.',
      'Grill chicken for 6–7 minutes per side.',
      'Let rest for 5 minutes before slicing.',
      'Serve with fresh parsley and lemon wedges.',
    ],
  ),
  Recipe(
    emoji: '🥦',
    name: 'Veggie Stir-fry',
    category: 'Vegan',
    calories: '180 kcal',
    protein: 6,
    carbs: 28,
    fat: 5,
    prepMins: 10,
    cookMins: 10,
    servings: 2,
    description:
        'A quick, colorful stir-fry loaded with fiber-rich vegetables. Ready in 20 minutes and full of vitamins.',
    color: Color(0xFFE0F2F1),
    ingredients: [
      '1 cup broccoli florets',
      '1 carrot, julienned',
      '1 red bell pepper, sliced',
      '1 tbsp sesame oil',
      '2 tbsp soy sauce (low sodium)',
      '1 tsp ginger, grated',
      '2 garlic cloves, minced',
      'Sesame seeds to garnish',
    ],
    steps: [
      'Heat sesame oil in a wok over high heat.',
      'Add garlic and ginger, stir-fry for 30 seconds.',
      'Add carrots first, cook 2 minutes.',
      'Add broccoli and bell pepper, stir-fry 4–5 minutes.',
      'Pour soy sauce and toss to coat.',
      'Serve hot, garnished with sesame seeds.',
    ],
  ),
  Recipe(
    emoji: '🐟',
    name: 'Baked Salmon',
    category: 'High Protein',
    calories: '420 kcal',
    protein: 40,
    carbs: 8,
    fat: 24,
    prepMins: 10,
    cookMins: 18,
    servings: 2,
    description:
        'Omega-3 rich baked salmon with lemon-herb crust. A heart-healthy power meal for any day of the week.',
    color: Color(0xFFFCE4EC),
    ingredients: [
      '2 salmon fillets (150g each)',
      '2 tbsp olive oil',
      '1 lemon, sliced',
      '2 garlic cloves, minced',
      '1 tsp dill or parsley',
      'Salt and pepper',
      'Cherry tomatoes for roasting',
    ],
    steps: [
      'Preheat oven to 200°C.',
      'Place salmon on a lined baking tray.',
      'Mix olive oil, garlic, and herbs; brush over fish.',
      'Top with lemon slices and cherry tomatoes.',
      'Bake for 16–18 minutes until flaky.',
      'Squeeze fresh lemon before serving.',
    ],
  ),
  Recipe(
    emoji: '🥣',
    name: 'Oatmeal & Berries',
    category: 'Breakfast',
    calories: '310 kcal',
    protein: 10,
    carbs: 55,
    fat: 6,
    prepMins: 2,
    cookMins: 8,
    servings: 1,
    description:
        'A wholesome oatmeal bowl topped with fresh berries and honey — the perfect energizing breakfast to start your day.',
    color: Color(0xFFF3E5F5),
    ingredients: [
      '½ cup rolled oats',
      '1 cup milk or almond milk',
      '½ cup mixed berries (blueberry, strawberry)',
      '1 tbsp honey or maple syrup',
      '1 tsp chia seeds',
      'Pinch of cinnamon',
    ],
    steps: [
      'Combine oats and milk in a saucepan.',
      'Cook over medium heat, stirring, for 5–7 minutes.',
      'Transfer to a bowl, top with berries.',
      'Drizzle with honey and sprinkle chia seeds.',
      'Add a pinch of cinnamon and serve warm.',
    ],
  ),
  Recipe(
    emoji: '🌮',
    name: 'Chickpea Tacos',
    category: 'Vegan',
    calories: '290 kcal',
    protein: 12,
    carbs: 42,
    fat: 8,
    prepMins: 10,
    cookMins: 10,
    servings: 2,
    description:
        'Plant-based tacos loaded with spiced chickpeas, fresh slaw, and creamy avocado. Delicious and satisfying.',
    color: Color(0xFFE8EAF6),
    ingredients: [
      '1 can chickpeas, drained',
      '4 small corn tortillas',
      '1 tsp cumin, 1 tsp smoked paprika',
      '1 cup red cabbage, shredded',
      '½ avocado, sliced',
      '2 tbsp Greek yogurt or tahini',
      'Fresh lime juice and cilantro',
    ],
    steps: [
      'Drain and rinse chickpeas, pat dry.',
      'Toss with cumin, paprika, salt, and olive oil.',
      'Pan-fry for 5–7 minutes until crispy.',
      'Warm tortillas in a dry pan.',
      'Assemble tacos with cabbage, chickpeas, avocado.',
      'Drizzle with yogurt/tahini and fresh lime.',
    ],
  ),
  Recipe(
    emoji: '🍲',
    name: 'Lentil Soup',
    category: 'Soup',
    calories: '230 kcal',
    protein: 16,
    carbs: 36,
    fat: 4,
    prepMins: 10,
    cookMins: 25,
    servings: 4,
    description:
        'Hearty red lentil soup with turmeric and cumin — a comforting, protein-rich meal that soothes and nourishes.',
    color: Color(0xFFFFF3E0),
    ingredients: [
      '1 cup red lentils, rinsed',
      '1 onion, diced',
      '3 garlic cloves',
      '1 tsp turmeric, 1 tsp cumin',
      '4 cups vegetable broth',
      '1 tomato, diced',
      'Olive oil, salt & lemon to finish',
    ],
    steps: [
      'Sauté onion and garlic in olive oil until soft.',
      'Add spices and toast for 1 minute.',
      'Add lentils, tomato, and broth.',
      'Bring to boil, then simmer 20–25 minutes.',
      'Blend half the soup for creamier texture.',
      'Squeeze lemon on top and serve with bread.',
    ],
  ),
];
