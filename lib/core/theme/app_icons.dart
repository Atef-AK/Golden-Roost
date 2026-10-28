import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppIcons {
  // Animals / Flocks
  static const IconData birds = Icons.flutter_dash_rounded;
  static const IconData chicks = Icons.child_care_rounded;
  static const IconData chicken = Icons.flutter_dash_rounded;
  static const IconData quail = Icons.flutter_dash_rounded;
  static const IconData duck = Icons.water_outlined;
  static const IconData turkey = Icons.pets_rounded;
  static const IconData layers = Icons.egg_rounded;
  static const IconData broilers = Icons.set_meal_outlined;

  // Farm Infrastructure
  static const IconData coop = Icons.cottage_outlined;
  static const IconData pen = Icons.roofing_rounded;
  static const IconData incubator = Icons.wb_incandescent_outlined;
  static const IconData brooder = Icons.wb_sunny_outlined;

  // Resources
  static const IconData eggs = Icons.egg_outlined;
  static const IconData eggTray = Icons.grid_view_rounded;
  static const IconData feed = Icons.grain_rounded;
  static const IconData water = Icons.water_drop_rounded;
  static const IconData electricity = Icons.bolt_rounded;

  // Actions & Management
  static const IconData expense = Icons.receipt_long_outlined;
  static const IconData income = Icons.trending_up_rounded;
  static const IconData sale = Icons.point_of_sale_rounded;
  static const IconData health = Icons.medical_services_outlined;
  static const IconData vaccine = Icons.vaccines_outlined;
  static const IconData mortality = Icons.heart_broken_outlined;
  static const IconData cleaning = Icons.cleaning_services_outlined;
  static const IconData weight = Icons.scale_outlined;
  static const IconData notes = Icons.edit_note_rounded;

  /// Returns an appropriate icon and color for poultry species or flock purpose.
  static (IconData, Color) getSpeciesVisual(String species) {
    switch (species.toLowerCase()) {
      case 'chicks':
      case 'poussin':
      case 'poussins':
        return (chicks, Colors.amber);
      case 'quail':
      case 'caille':
        return (quail, const Color(0xFFD97706));
      case 'duck':
      case 'canard':
        return (duck, const Color(0xFF0284C7));
      case 'turkey':
      case 'dinde':
        return (turkey, const Color(0xFF9A3412));
      case 'layers':
      case 'pondeuses':
        return (eggs, AppColors.warning);
      case 'meat':
      case 'broilers':
      case 'poulet de chair':
        return (broilers, AppColors.primaryTeal);
      default:
        return (chicken, AppColors.primaryTeal);
    }
  }

  /// Returns an appropriate icon and color for finance categories.
  static (IconData, Color) getFinanceCategoryVisual(String category) {
    switch (category.toLowerCase()) {
      case 'feed':
        return (feed, AppColors.semanticSuccess);
      case 'chicks':
        return (chicks, Colors.amber);
      case 'adult_birds':
        return (birds, AppColors.primaryTeal);
      case 'vaccines':
        return (vaccine, const Color(0xFF6366F1));
      case 'medicines':
        return (health, const Color(0xFFEF4444));
      case 'bedding':
        return (Icons.grass_rounded, const Color(0xFF84CC16));
      case 'electricity':
        return (electricity, const Color(0xFFEAB308));
      case 'water':
        return (water, const Color(0xFF06B6D4));
      case 'equipment':
        return (
          Icons.precision_manufacturing_outlined,
          const Color(0xFF64748B),
        );
      case 'coop':
      case 'housing':
        return (coop, const Color(0xFF8B5CF6));
      case 'incubators':
        return (incubator, Colors.orange);
      case 'heating':
        return (Icons.whatshot_rounded, Colors.deepOrange);
      case 'maintenance':
        return (Icons.build_rounded, const Color(0xFF475569));
      case 'transport':
        return (Icons.local_shipping_outlined, const Color(0xFF0284C7));
      case 'packaging':
        return (Icons.inventory_2_outlined, const Color(0xFFA855F7));
      case 'sales_eggs':
        return (eggs, AppColors.warning);
      case 'sales_birds':
        return (birds, AppColors.primaryTeal);
      case 'sales_meat':
        return (broilers, const Color(0xFF10B981));
      case 'sales_chicks':
        return (chicks, Colors.amber);
      case 'sales_manure':
        return (Icons.eco_outlined, const Color(0xFF65A30D));
      default:
        return (Icons.attach_money_rounded, AppColors.primaryTeal);
    }
  }

  /// Returns an appropriate icon and color for tasks.
  static (IconData, Color) getTaskCategoryVisual(String category) {
    switch (category.toLowerCase()) {
      case 'feeding':
        return (feed, AppColors.semanticSuccess);
      case 'watering':
        return (water, const Color(0xFF0284C7));
      case 'vaccine':
      case 'vaccination':
        return (vaccine, const Color(0xFFEF4444));
      case 'cleaning':
        return (cleaning, const Color(0xFF8B5CF6));
      case 'weighing':
        return (weight, const Color(0xFF0EA5E9));
      case 'incubation':
        return (incubator, Colors.amber);
      case 'coop':
      case 'housing':
        return (coop, const Color(0xFF64748B));
      case 'maintenance':
        return (Icons.build_rounded, const Color(0xFF475569));
      default:
        return (Icons.check_circle_outline_rounded, AppColors.primaryTeal);
    }
  }
}
