import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database_helper.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await DatabaseHelper.instance.setOnboardingCompleted();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  void _showLanguageSelector(BuildContext context, String currentLang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                trailing: currentLang == 'en'
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.forestEmerald,
                      )
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage('en');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                title: const Text('Français'),
                trailing: currentLang == 'fr'
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.forestEmerald,
                      )
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage('fr');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇹🇳', style: TextStyle(fontSize: 24)),
                title: const Text('العربية (Arabic - RTL)'),
                trailing: currentLang == 'ar'
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.forestEmerald,
                      )
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage('ar');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                title: const Text('Español (Spanish)'),
                trailing: currentLang == 'es'
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.forestEmerald,
                      )
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage('es');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      _OnboardingPageData(
        titleKey: 'onboarding_title_1',
        descKey: 'onboarding_desc_1',
        imageAsset:
            'assets/illustrations/onboarding/onboarding_farm_manage.jpg',
      ),
      _OnboardingPageData(
        titleKey: 'onboarding_title_2',
        descKey: 'onboarding_desc_2',
        imageAsset:
            'assets/illustrations/onboarding/onboarding_production_feed.jpg',
      ),
      _OnboardingPageData(
        titleKey: 'onboarding_title_3',
        descKey: 'onboarding_desc_3',
        imageAsset:
            'assets/illustrations/onboarding/onboarding_incubation_learn.jpg',
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.pageBackgroundDark : Colors.white,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 600,
          child: Column(
            children: [
              // Top Bar with Skip & Language selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Language Chip
                    ActionChip(
                      avatar: const Icon(Icons.language_rounded, size: 16),
                      label: Text(
                        settings.language.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () =>
                          _showLanguageSelector(context, settings.language),
                    ),
                    // Skip Button
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        context.tr('onboarding_skip'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF8BA093)
                              : AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (ctx, i) {
                    final page = pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration container
                          Container(
                            height: 260,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    isDark ? 60 : 20,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                page.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (c, err, stack) => Container(
                                  color: AppColors.forestEmerald.withAlpha(30),
                                  child: const Center(
                                    child: Icon(
                                      Icons.agriculture_rounded,
                                      size: 64,
                                      color: AppColors.forestEmerald,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Title
                          Text(
                            context.tr(page.titleKey),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: isDark ? Colors.white : AppColors.mainInk,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Description
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: Text(
                              context.tr(page.descKey),
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.45,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Navigation Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Page Indicators
                    Row(
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 6),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.forestEmerald
                                : (isDark
                                      ? const Color(0xFF2B3A31)
                                      : const Color(0xFFD6DDD4)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next / Get Started Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (_currentPage < pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == pages.length - 1
                                ? context.tr('onboarding_get_started')
                                : context.tr('onboarding_next'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
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

class _OnboardingPageData {
  final String titleKey;
  final String descKey;
  final String imageAsset;

  _OnboardingPageData({
    required this.titleKey,
    required this.descKey,
    required this.imageAsset,
  });
}
