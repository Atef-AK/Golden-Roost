import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../models/article.dart';
import '../../models/notification_campaign.dart';
import '../../models/poultry_product.dart';
import '../../providers/article_provider.dart';
import '../../providers/product_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAuthenticated = false;
  final _pinController = TextEditingController();

  // In production, administrator access is gated by Firebase Authentication Custom Claims ('admin': true).
  // For offline farm development, a local secure PIN protects the administration console.
  static const String _offlineAdminPin = '1234';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    if (_pinController.text == _offlineAdminPin) {
      setState(() => _isAuthenticated = true);
      DatabaseHelper.instance.insertAuditLog(
        action: 'admin_login_success',
        entityType: 'admin_session',
        entityId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        performedBy: 'offline_administrator',
        details: 'Admin dashboard unlocked via authorized PIN credentials',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Admin Credentials'),
          backgroundColor: AppColors.semanticError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return _buildLoginGate(context);
    }

    final articles = ref.watch(articlesProvider);
    final products = ref.watch(poultryProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Roost CMS & Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Lock Admin Console',
            onPressed: () => setState(() => _isAuthenticated = false),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Articles (${articles.length})'),
            Tab(text: 'Products (${products.length})'),
            const Tab(text: 'Push Campaigns'),
            const Tab(text: 'Security Audit'),
          ],
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 1100,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildArticlesTab(context, articles, isDark),
            _buildProductsTab(context, products, isDark),
            _buildCampaignsTab(context, isDark),
            _buildAuditLogsTab(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginGate(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protected Admin Console')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryTeal.withAlpha(50),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 54,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Administrator Access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Remotely manage veterinary education, affiliate products, and push campaigns without rebuilding the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Admin PIN (Default: 1234)',
                    prefixIcon: Icon(Icons.key),
                  ),
                  onSubmitted: (_) => _verifyPin(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _verifyPin,
                    child: const Text('Authenticate Console'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesTab(
    BuildContext context,
    List<Article> articles,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (ctx, index) {
        final a = articles[index];
        return PremiumCard(
          padding: const EdgeInsets.all(12),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              a.titleEn,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              '${a.category.toUpperCase()} • ${a.author} • ${a.isPublished ? "PUBLISHED" : "DRAFT"}',
              style: TextStyle(
                fontSize: 11,
                color: a.isPublished
                    ? AppColors.semanticSuccess
                    : AppColors.semanticWarning,
              ),
            ),
            trailing: Switch(
              value: a.isPublished,
              activeThumbColor: AppColors.primaryTeal,
              onChanged: (val) async {
                final updated = a.copyWith(isPublished: val);
                await ref.read(articlesProvider.notifier).updateArticle(updated);
                await DatabaseHelper.instance.insertAuditLog(
                  action: val ? 'publish_article' : 'unpublish_article',
                  entityType: 'article',
                  entityId: a.id,
                  performedBy: 'admin',
                  details: 'Article status changed to ${val ? "published" : "draft"}',
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsTab(
    BuildContext context,
    List<PoultryProduct> products,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (ctx, index) {
        final p = products[index];
        return PremiumCard(
          padding: const EdgeInsets.all(12),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              p.nameEn,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              '${p.merchantName} • ${p.category} • \$${p.price.toStringAsFixed(2)} • ${p.isActive ? "ACTIVE" : "INACTIVE"}',
              style: TextStyle(
                fontSize: 11,
                color: p.isActive
                    ? AppColors.semanticSuccess
                    : AppColors.semanticWarning,
              ),
            ),
            trailing: Switch(
              value: p.isActive,
              activeThumbColor: AppColors.primaryTeal,
              onChanged: (val) async {
                final updated = p.copyWith(isActive: val);
                await ref
                    .read(poultryProductsProvider.notifier)
                    .updateProduct(updated);
                await DatabaseHelper.instance.insertAuditLog(
                  action: val ? 'activate_product' : 'deactivate_product',
                  entityType: 'product',
                  entityId: p.id,
                  performedBy: 'admin',
                  details: 'Product active status toggled to $val',
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampaignsTab(BuildContext context, bool isDark) {
    return FutureBuilder<List<NotificationCampaign>>(
      future: DatabaseHelper.instance.getNotificationCampaigns(),
      builder: (ctx, snapshot) {
        final campaigns = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.campaign),
              label: const Text('Create New FCM Broadcast Campaign'),
              onPressed: () => _showCreateCampaignDialog(context),
            ),
            const SizedBox(height: 16),
            if (campaigns.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No broadcast campaigns created yet.'),
                ),
              )
            else
              ...campaigns.map(
                (c) => PremiumCard(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      c.titleEn,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${c.campaignType.toUpperCase()} • Target: ${c.audienceFilter} • Status: ${c.status}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Chip(
                      label: Text(c.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                      backgroundColor: c.status == 'sent'
                          ? AppColors.semanticSuccess.withAlpha(30)
                          : AppColors.semanticWarning.withAlpha(30),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAuditLogsTab(BuildContext context, bool isDark) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getAuditLogs(limit: 50),
      builder: (ctx, snapshot) {
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Center(child: Text('No security audit events recorded.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (ctx, i) => const Divider(height: 1),
          itemBuilder: (ctx, index) {
            final log = logs[index];
            return ListTile(
              dense: true,
              leading: const Icon(
                Icons.shield_outlined,
                size: 20,
                color: AppColors.primaryTeal,
              ),
              title: Text(
                '${log['action']} • ${log['entity_type']}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              subtitle: Text(
                '${log['details'] ?? ""}\nBy: ${log['performed_by']} at ${log['timestamp']}',
                style: const TextStyle(fontSize: 10),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateCampaignDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String campaignType = 'article';
    String audience = 'all';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Push Campaign'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Campaign Title (EN)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bodyCtrl,
                decoration: const InputDecoration(labelText: 'Body Text (EN)'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: campaignType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'article', child: Text('New Article Alert')),
                  DropdownMenuItem(value: 'product', child: Text('Product Feature')),
                  DropdownMenuItem(value: 'announcement', child: Text('App Announcement')),
                ],
                onChanged: (val) => campaignType = val!,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: audience,
                decoration: const InputDecoration(labelText: 'Audience Filter'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                  DropdownMenuItem(value: 'opted_in_marketing', child: Text('Opted-In Marketing Only')),
                  DropdownMenuItem(value: 'arabic', child: Text('Arabic Language Users')),
                  DropdownMenuItem(value: 'french', child: Text('French Language Users')),
                  DropdownMenuItem(value: 'english', child: Text('English Language Users')),
                ],
                onChanged: (val) => audience = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryTeal),
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;

              final campaign = NotificationCampaign(
                id: 'camp_${DateTime.now().millisecondsSinceEpoch}',
                titleEn: titleCtrl.text.trim(),
                titleFr: titleCtrl.text.trim(),
                titleAr: titleCtrl.text.trim(),
                bodyEn: bodyCtrl.text.trim(),
                bodyFr: bodyCtrl.text.trim(),
                bodyAr: bodyCtrl.text.trim(),
                campaignType: campaignType,
                destinationType: campaignType == 'article' ? 'article' : 'product',
                audienceFilter: audience,
                status: 'scheduled',
                createdAt: DateTime.now(),
              );

              await DatabaseHelper.instance.insertNotificationCampaign(campaign);
              await DatabaseHelper.instance.insertAuditLog(
                action: 'create_campaign',
                entityType: 'notification_campaign',
                entityId: campaign.id,
                performedBy: 'admin',
                details: 'Created $campaignType broadcast for audience: $audience',
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Campaign queued successfully')),
                );
              }
            },
            child: const Text('Queue Broadcast'),
          ),
        ],
      ),
    );
  }
}
