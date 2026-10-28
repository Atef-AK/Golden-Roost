class FarmCalculations {
  /// Calculate current live bird count given initial count, total added, and total reduced
  static int calculateLiveBirds({
    required int startCount,
    required int additions,
    required int reductions,
  }) {
    final result = startCount + additions - reductions;
    return result < 0 ? 0 : result;
  }

  /// Calculate egg laying percentage based on eligible mature female layers
  static double calculateLayingRate({
    required int eggsCollected,
    required int femaleBirds,
  }) {
    if (femaleBirds <= 0 || eggsCollected <= 0) return 0.0;
    return (eggsCollected / femaleBirds) * 100.0;
  }

  /// Calculates available saleable egg inventory ensuring reserved incubation eggs
  /// and previously sold eggs cannot be double sold.
  static int calculateAvailableSaleableEggs({
    required int totalUsableEggs,
    required int reservedForIncubation,
    required int totalSold,
  }) {
    final available = totalUsableEggs - reservedForIncubation - totalSold;
    return available < 0 ? 0 : available;
  }

  /// Cost per egg: production cost / usable eggs produced
  static double calculateCostPerEgg({
    required double totalProductionCost,
    required int totalUsableEggs,
  }) {
    if (totalUsableEggs <= 0 || totalProductionCost <= 0) return 0.0;
    return totalProductionCost / totalUsableEggs;
  }

  /// Cost per dozen eggs
  static double calculateCostPerDozenEggs({
    required double totalProductionCost,
    required int totalUsableEggs,
  }) {
    return calculateCostPerEgg(
          totalProductionCost: totalProductionCost,
          totalUsableEggs: totalUsableEggs,
        ) *
        12.0;
  }

  /// Calculate daily feed consumed per bird in grams: (feedKg * 1000) / birdCount
  static double calculateFeedPerBirdGrams({
    required double feedKg,
    required int birdCount,
  }) {
    if (birdCount <= 0 || feedKg <= 0) return 0.0;
    return (feedKg * 1000.0) / birdCount;
  }

  /// Returns estimated daily feed intake per bird in grams based on species, purpose, and age (in weeks/days).
  /// Based on standard poultry nutrition tables (NRC / Ross 308 / Hy-Line / Cobb 500).
  static double getDailyIntakeGramsPerBird({
    required String species,
    required String purpose,
    required int ageWeeks,
    int? ageDays,
  }) {
    final effectiveWeeks = ageWeeks > 0
        ? ageWeeks
        : ((ageDays ?? 0) / 7).floor();
    final sp = species.toLowerCase().trim();
    final pur = purpose.toLowerCase().trim();

    if (sp.contains('quail') || sp.contains('caille')) {
      // Coturnix Quail intake curve
      if (effectiveWeeks <= 1) return 8.0;
      if (effectiveWeeks <= 2) return 14.0;
      if (effectiveWeeks <= 4) return 22.0;
      return 28.0; // Adult quail
    }

    if (sp.contains('duck') || sp.contains('canard')) {
      // Duck intake curve
      if (effectiveWeeks <= 1) return 35.0;
      if (effectiveWeeks <= 3) return 85.0;
      if (effectiveWeeks <= 7) return 140.0;
      return 185.0; // Adult duck
    }

    if (sp.contains('turkey') || sp.contains('dinde')) {
      // Turkey intake curve
      if (effectiveWeeks <= 2) return 40.0;
      if (effectiveWeeks <= 5) return 110.0;
      if (effectiveWeeks <= 10) return 210.0;
      return 290.0; // Adult turkey
    }

    if (sp.contains('goose') || sp.contains('oie')) {
      if (effectiveWeeks <= 3) return 80.0;
      if (effectiveWeeks <= 8) return 170.0;
      return 240.0;
    }

    // Chicken (Default & primary species)
    final isMeat =
        pur.contains('meat') ||
        pur.contains('broiler') ||
        pur.contains('chair');
    final isLayer =
        pur.contains('egg') ||
        pur.contains('layer') ||
        pur.contains('pondeuse');

    if (isMeat) {
      // Broiler fast-growth feeding curve (grams/day)
      if (effectiveWeeks <= 0) return 18.0; // Week 1 (0-7 days): ~18g/day
      if (effectiveWeeks == 1) return 38.0; // Week 2: ~38g/day
      if (effectiveWeeks == 2) return 72.0; // Week 3: ~72g/day
      if (effectiveWeeks == 3) return 108.0; // Week 4: ~108g/day
      if (effectiveWeeks == 4) return 145.0; // Week 5: ~145g/day
      if (effectiveWeeks == 5) return 175.0; // Week 6: ~175g/day
      return 190.0; // Week 7+: ~190g/day
    }

    if (isLayer) {
      // Commercial Layer / Pullet curve (grams/day)
      if (effectiveWeeks <= 1) return 15.0;
      if (effectiveWeeks <= 3) return 25.0;
      if (effectiveWeeks <= 6) return 42.0;
      if (effectiveWeeks <= 10) return 60.0;
      if (effectiveWeeks <= 15) return 78.0;
      if (effectiveWeeks <= 19) return 92.0;
      return 118.0; // Peak production laying hen: 115-120g/day
    }

    // Dual-purpose / Breeding / Backyard Chicken
    if (effectiveWeeks <= 2) return 22.0;
    if (effectiveWeeks <= 6) return 50.0;
    if (effectiveWeeks <= 12) return 82.0;
    if (effectiveWeeks <= 18) return 105.0;
    return 125.0; // Adult dual-purpose: ~125g/day
  }

  /// Calculate daily feed demand in kilograms for a single flock based on live count and age-specific intake.
  static double calculateFlockDailyDemandKg({
    required int birdCount,
    required String species,
    required String purpose,
    required int ageWeeks,
    int? ageDays,
  }) {
    if (birdCount <= 0) return 0.0;
    final gramsPerBird = getDailyIntakeGramsPerBird(
      species: species,
      purpose: purpose,
      ageWeeks: ageWeeks,
      ageDays: ageDays,
    );
    return (birdCount * gramsPerBird) / 1000.0;
  }

  /// Calculate days remaining before feed depletion based on total feed stock and age-driven daily demand.
  /// Returns 0 if no birds or no feed stock.
  static int calculateDaysBeforeRefill({
    required double totalStockKg,
    required double totalDailyDemandKg,
  }) {
    if (totalDailyDemandKg <= 0 || totalStockKg <= 0) return 0;
    return (totalStockKg / totalDailyDemandKg).floor();
  }

  /// Calculate estimated calendar date when feed stock will be fully depleted and requires refill.
  /// Returns null if daily demand is zero or stock is zero.
  static DateTime? calculateEstimatedRefillDate({
    required double totalStockKg,
    required double totalDailyDemandKg,
    DateTime? fromDate,
  }) {
    final days = calculateDaysBeforeRefill(
      totalStockKg: totalStockKg,
      totalDailyDemandKg: totalDailyDemandKg,
    );
    if (days <= 0) return null;
    final start = fromDate ?? DateTime.now();
    return start.add(Duration(days: days));
  }

  /// Calculate estimated days of feed remaining (legacy compatibility)
  static int calculateDaysFeedRemaining({
    required double currentStockKg,
    required double avgDailyConsumptionKg,
  }) {
    return calculateDaysBeforeRefill(
      totalStockKg: currentStockKg,
      totalDailyDemandKg: avgDailyConsumptionKg,
    );
  }

  /// Incubation fertility percentage: (fertile / total set) * 100
  static double calculateFertilityRate({
    required int fertileCount,
    required int eggsSet,
  }) {
    if (eggsSet <= 0 || fertileCount <= 0) return 0.0;
    return (fertileCount / eggsSet) * 100.0;
  }

  /// Incubation hatch rate from eggs set: (hatched / total set) * 100
  static double calculateHatchRateFromSet({
    required int hatchedCount,
    required int eggsSet,
  }) {
    if (eggsSet <= 0 || hatchedCount <= 0) return 0.0;
    return (hatchedCount / eggsSet) * 100.0;
  }

  /// Incubation hatch rate from fertile eggs: (hatched / fertile) * 100
  static double calculateHatchRateFromFertile({
    required int hatchedCount,
    required int fertileCount,
  }) {
    if (fertileCount <= 0 || hatchedCount <= 0) return 0.0;
    return (hatchedCount / fertileCount) * 100.0;
  }

  /// Cost per hatched chick: totalBatchCost / hatchedCount
  static double calculateChickCost({
    required double totalBatchCost,
    required int hatchedCount,
  }) {
    if (hatchedCount <= 0 || totalBatchCost <= 0) return 0.0;
    return totalBatchCost / hatchedCount;
  }

  /// Net Operating Result = Operating Income - Operating Expenses
  static double calculateNetOperatingResult({
    required double operatingIncome,
    required double operatingExpenses,
  }) {
    return operatingIncome - operatingExpenses;
  }

  /// Feed Conversion Ratio: Total Feed consumed (kg) / Total Body Weight Gained (kg)
  /// Returns null if weight gain is not positive or unavailable
  static double? calculateFcr({
    required double totalFeedKg,
    required double totalWeightGainKg,
  }) {
    if (totalWeightGainKg <= 0 || totalFeedKg <= 0) return null;
    return totalFeedKg / totalWeightGainKg;
  }

  /// Electricity calculation from equipment: (Wattage * Daily Hours * Days) / 1000 * Tariff
  static double calculateElectricityCost({
    required double wattage,
    required double dailyHours,
    required int days,
    required double tariffPerKwh,
  }) {
    final kwh = (wattage * dailyHours * days) / 1000.0;
    return kwh * tariffPerKwh;
  }
}
