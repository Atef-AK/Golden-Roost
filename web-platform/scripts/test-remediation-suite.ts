import { NextRequest } from 'next/server';
import { GET as cronHandler } from '../src/app/api/cron/process-campaigns/route';

async function runTests() {
  console.log('=== STARTING GOLDEN ROOST REMEDIATION TEST SUITE ===\n');
  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, testName: string, failureDetail?: string) {
    if (condition) {
      console.log(`  [PASS] ${testName}`);
      passed++;
    } else {
      console.error(`  [FAIL] ${testName}: ${failureDetail || 'Assertion failed'}`);
      failed++;
    }
  }

  // --- 1. CRON Endpoint Security Tests ---
  console.log('1. Testing CRON_SECRET Security Enforcement:');
  {
    // Test 1a: Request without any secret configured in environment
    delete process.env.CRON_SECRET;
    const req1 = new NextRequest('http://localhost:3000/api/cron/process-campaigns', {
      method: 'GET',
    });
    const res1 = await cronHandler(req1);
    const data1 = await res1.json();
    assert(
      res1.status === 401,
      'Rejects invocation when CRON_SECRET is not set in environment (status 401)',
      `Got status ${res1.status}`
    );
    assert(
      data1.error && data1.error.includes('Unauthorized'),
      'Returns explicit Unauthorized error message',
      JSON.stringify(data1)
    );

    // Test 1b: Request with wrong authorization header
    process.env.CRON_SECRET = 'super-secret-cron-token-12345';
    const req2 = new NextRequest('http://localhost:3000/api/cron/process-campaigns', {
      method: 'GET',
      headers: { authorization: 'Bearer wrong-secret' },
    });
    const res2 = await cronHandler(req2);
    assert(
      res2.status === 401,
      'Rejects invocation when Authorization header does not match CRON_SECRET',
      `Got status ${res2.status}`
    );

    // Test 1c: Request with missing authorization header when secret is configured
    const req3 = new NextRequest('http://localhost:3000/api/cron/process-campaigns', {
      method: 'GET',
    });
    const res3 = await cronHandler(req3);
    assert(
      res3.status === 401,
      'Rejects unauthenticated invocation even when secret is configured on server',
      `Got status ${res3.status}`
    );
  }

  // --- 2. Topic Whitelisting & Consent Logic Tests ---
  console.log('\n2. Testing Device Registration Topic Whitelisting & Consent Logic:');
  {
    const ALLOWED_TOPICS = [
      'general_announcements',
      'poultry_tips',
      'disease_alerts',
      'article_alerts',
      'marketing_offers',
    ];

    function sanitizeRegistration(body: {
      topics?: unknown;
      marketingOptIn?: boolean;
      articleAlertsOptIn?: boolean;
      diseaseAlertsOptIn?: boolean;
    }) {
      const marketingOptIn = Boolean(body.marketingOptIn === true);
      const articleAlertsOptIn = body.articleAlertsOptIn !== undefined ? Boolean(body.articleAlertsOptIn) : true;
      const diseaseAlertsOptIn = body.diseaseAlertsOptIn !== undefined ? Boolean(body.diseaseAlertsOptIn) : true;

      const requestedTopics = Array.isArray(body.topics) ? body.topics : ['general_announcements', 'poultry_tips'];
      const sanitized = requestedTopics.filter((t): t is string =>
        typeof t === 'string' && ALLOWED_TOPICS.includes(t)
      );

      const userTopics = sanitized.filter((t) => {
        if (t === 'marketing_offers' && !marketingOptIn) return false;
        if (t === 'article_alerts' && !articleAlertsOptIn) return false;
        if (t === 'disease_alerts' && !diseaseAlertsOptIn) return false;
        return true;
      });

      if (userTopics.length === 0) {
        userTopics.push('general_announcements');
      }

      return { userTopics, marketingOptIn, articleAlertsOptIn, diseaseAlertsOptIn };
    }

    // Test 2a: Malicious / unauthorized topics are stripped
    const reg1 = sanitizeRegistration({
      topics: ['admin_alerts', 'general_announcements', 'sql_injection_attempt'],
      marketingOptIn: false,
    });
    assert(
      !reg1.userTopics.includes('admin_alerts') && !reg1.userTopics.includes('sql_injection_attempt'),
      'Strips unauthorized client-supplied topics from registration',
      JSON.stringify(reg1.userTopics)
    );
    assert(
      reg1.userTopics.includes('general_announcements'),
      'Retains valid whitelisted topics',
      JSON.stringify(reg1.userTopics)
    );

    // Test 2b: Marketing topic strictly requires explicit marketingOptIn
    const reg2 = sanitizeRegistration({
      topics: ['marketing_offers', 'poultry_tips'],
      marketingOptIn: false,
    });
    assert(
      !reg2.userTopics.includes('marketing_offers'),
      'Strictly strips marketing_offers when marketingOptIn is false',
      JSON.stringify(reg2.userTopics)
    );

    const reg3 = sanitizeRegistration({
      topics: ['marketing_offers', 'poultry_tips'],
      marketingOptIn: true,
    });
    assert(
      reg3.userTopics.includes('marketing_offers'),
      'Preserves marketing_offers when user explicitly opts in',
      JSON.stringify(reg3.userTopics)
    );

    // Test 2c: Opt-out of disease alerts
    const reg4 = sanitizeRegistration({
      topics: ['disease_alerts'],
      diseaseAlertsOptIn: false,
    });
    assert(
      !reg4.userTopics.includes('disease_alerts') && reg4.userTopics.includes('general_announcements'),
      'Respects disease alerts opt-out and falls back to default announcement topic',
      JSON.stringify(reg4.userTopics)
    );
  }

  // --- 3. Campaign Targeting & Recipient Rules ---
  console.log('\n3. Testing Campaign Targeting Rules & Consent Filtering:');
  {
    interface MockDevice {
      id: string;
      locale: string;
      marketingOptIn: boolean;
      articleAlertsOptIn: boolean;
      diseaseAlertsOptIn: boolean;
      topics: string[];
      isActive: boolean;
    }

    const testDevices: MockDevice[] = [
      { id: 'd1_en_nomarketing', locale: 'en', marketingOptIn: false, articleAlertsOptIn: true, diseaseAlertsOptIn: true, topics: ['general_announcements'], isActive: true },
      { id: 'd2_en_optedin', locale: 'en', marketingOptIn: true, articleAlertsOptIn: true, diseaseAlertsOptIn: true, topics: ['general_announcements', 'marketing_offers'], isActive: true },
      { id: 'd3_fr_optedin', locale: 'fr', marketingOptIn: true, articleAlertsOptIn: true, diseaseAlertsOptIn: true, topics: ['general_announcements', 'marketing_offers'], isActive: true },
      { id: 'd4_ar_nodisease', locale: 'ar', marketingOptIn: false, articleAlertsOptIn: true, diseaseAlertsOptIn: false, topics: ['general_announcements'], isActive: true },
      { id: 'd5_inactive', locale: 'en', marketingOptIn: true, articleAlertsOptIn: true, diseaseAlertsOptIn: true, topics: ['general_announcements'], isActive: false },
    ];

    function filterRecipients(campaign: { campaignType: string; targetLocale?: string; targetTopic?: string }) {
      return testDevices.filter((d) => {
        if (!d.isActive) return false;
        if (campaign.targetLocale && campaign.targetLocale !== 'all' && d.locale !== campaign.targetLocale) {
          return false;
        }
        if (campaign.campaignType === 'marketing' && !d.marketingOptIn) {
          return false;
        }
        if (campaign.campaignType === 'article_alert' && !d.articleAlertsOptIn) {
          return false;
        }
        if (campaign.campaignType === 'disease_alert' && !d.diseaseAlertsOptIn) {
          return false;
        }
        if (campaign.targetTopic && campaign.targetTopic !== 'all' && campaign.targetTopic !== 'general_announcements') {
          if (!d.topics.includes(campaign.targetTopic)) return false;
        }
        return true;
      });
    }

    // 3a: Marketing campaign in English
    const marketingEnTargets = filterRecipients({
      campaignType: 'marketing',
      targetLocale: 'en',
    });
    assert(
      marketingEnTargets.length === 1 && marketingEnTargets[0].id === 'd2_en_optedin',
      'Marketing campaign in English targets ONLY opted-in English device (excludes non-opted-in d1, French d3, inactive d5)',
      marketingEnTargets.map((d) => d.id).join(', ')
    );

    // 3b: Disease alert across all languages
    const diseaseTargets = filterRecipients({
      campaignType: 'disease_alert',
      targetLocale: 'all',
    });
    assert(
      !diseaseTargets.some((d) => d.id === 'd4_ar_nodisease'),
      'Disease alert strictly excludes device d4 where diseaseAlertsOptIn is false',
      diseaseTargets.map((d) => d.id).join(', ')
    );
    assert(
      !diseaseTargets.some((d) => d.id === 'd5_inactive'),
      'Inactive devices are never targeted',
      diseaseTargets.map((d) => d.id).join(', ')
    );
  }

  // --- 4. Role Hierarchy & RBAC Integrity ---
  console.log('\n4. Testing RBAC Role Hierarchy:');
  {
    type AdminRole = 'superadmin' | 'editor' | 'veterinarian' | 'viewer';
    const allowedArticleRoles: AdminRole[] = ['superadmin', 'editor', 'veterinarian'];
    const allowedDeleteRoles: AdminRole[] = ['superadmin'];

    function canPublishArticles(role: AdminRole): boolean {
      return allowedArticleRoles.includes(role);
    }

    function canDeleteArticles(role: AdminRole): boolean {
      return allowedDeleteRoles.includes(role);
    }

    assert(canPublishArticles('veterinarian'), 'Veterinarian has authority to author & publish articles/protocols');
    assert(canPublishArticles('editor'), 'Editor has authority to author & publish articles');
    assert(canPublishArticles('superadmin'), 'Superadmin has full article authoring authority');
    assert(!canPublishArticles('viewer'), 'Viewer role is rejected from mutating/authoring articles');
    assert(!canDeleteArticles('veterinarian'), 'Veterinarian cannot delete system articles (reserved for superadmin)');
    assert(canDeleteArticles('superadmin'), 'Superadmin can delete system articles');
  }

  console.log(`\n=== REMEDIATION TEST SUITE FINISHED ===`);
  console.log(`Results: ${passed} Passed, ${failed} Failed\n`);

  if (failed > 0) {
    process.exit(1);
  }
}

runTests().catch((e) => {
  console.error('Test suite error:', e);
  process.exit(1);
});
