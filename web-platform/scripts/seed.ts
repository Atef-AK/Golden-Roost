import * as dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });
dotenv.config();

import { neonConfig, Pool } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-serverless';
import * as schema from '../src/db/schema';
import { eq } from 'drizzle-orm';

neonConfig.fetchConnectionCache = true;

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.log('No DATABASE_URL configured. Skipping database seed.');
  process.exit(0);
}

const pool = new Pool({ connectionString });
const db = drizzle(pool, { schema });

async function seed() {
  console.log('Starting Golden Roost database seed...');

  // 1. Monetization Settings
  await db
    .insert(schema.monetizationSettings)
    .values({
      id: 'global',
      adsenseEnabled: false,
      adsensePublisherId: 'ca-pub-0000000000000000',
      admobEnabled: true,
      admobBannerId: 'ca-app-pub-3940256099942544/6300978111',
      admobInterstitialId: 'ca-app-pub-3940256099942544/1033173712',
    })
    .onConflictDoNothing();

  // 2. Default Articles
  const articlesData = [
    {
      slug: 'newcastle-disease-prevention-vaccination',
      category: 'disease_guide',
      featuredImageUrl:
        'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?auto=format&fit=crop&w=1200&q=80',
      isPublished: true,
      translations: [
        {
          locale: 'en',
          title: 'Newcastle Disease: Symptoms, Prevention & Full Vaccination Guide',
          summary:
            'A comprehensive clinical overview of Newcastle Disease in poultry, transmission vectors, biosecurity protocols, and optimal vaccination schedules from day-old chicks to mature layers.',
          content: `### Understanding Newcastle Disease (ND)
Newcastle Disease is a highly contagious viral avian disease affecting domestic poultry and wild birds. It is caused by virulent strains of avian paramyxovirus type 1 (APMV-1).

### Clinical Signs & Symptoms
- **Respiratory distress:** Gasping, coughing, sneezing, and rales.
- **Nervous signs:** Tremors, twisted neck (torticollis), circling, and paralysis.
- **Digestive signs:** Greenish, watery diarrhea.
- **Production drops:** Sudden and drastic decline in egg yield with misshapen or soft-shelled eggs.

### Standard Vaccination Program
1. **Day 1–7:** ND Hitchner B1 / Clone 30 via eye-drop or coarse spray.
2. **Day 21–28:** ND LaSota via drinking water.
3. **Week 8–10:** ND LaSota booster.
4. **Week 16–18 (Pre-lay):** Inactivated ND + IB emulsion vaccine (intramuscular injection).

### Farm Biosecurity Measures
- Restrict all unauthorized farm visitors.
- Maintain dedicated footbaths with glutaraldehyde or virucidal disinfectants at every coop entrance.
- Isolate new birds in quarantine for a minimum of 21 days before flock integration.`,
        },
        {
          locale: 'fr',
          title: 'Maladie de Newcastle : Symptômes, Prévention et Calendrier de Vaccination',
          summary:
            'Guide vétérinaire complet sur la maladie de Newcastle : vecteurs de transmission, règles de biosécurité et protocole de vaccination optimal.',
          content: `### Présentation de la maladie
La maladie de Newcastle est une infection virale aviaire majeure causée par un paramyxovirus aviaire de type 1.

### Symptômes majeurs
- Râles respiratoires et toux.
- Troubles neurologiques (torticolis, paralysie).
- Diarrhée aqueuse verdâtre et chute brutale de ponte.

### Protocole vaccinal
- J7 : Souche Hitchner B1 par voie oculaire.
- J21 : Souche LaSota dans l'eau de boisson.
- Semaine 16 : Vaccin inactivé huileux par injection intramusculaire.`,
        },
        {
          locale: 'ar',
          title: 'مرض النيوكاسل في الدواجن: الأعراض، الوقاية، وجدول التحصين الشامل',
          summary:
            'دليل بيطري متكامل للتعرف على مرض شبه طاعون الدجاج (النيوكاسل)، طرق الوقاية، وقواعد الأمن الحيوي وجدول اللقاحات المعتمد.',
          content: `### نظرة عامة على مرض النيوكاسل
يعد مرض النيوكاسل من أخطر الأمراض الفيروسية التنفسية والعصبية التي تصيب قطعان الدواجن مسببة خسائر فادحة إن لم تتم الوقاية الكافية.

### الأعراض الشائعة
- صعوبة التنفس، الحشرجة والسعال.
- الأعراض العصبية: التواء الرقبة والشلل.
- إسهال مائي أخضر مع انخفاض حاد في إنتاج البيض.

### جدول التحصين الوقائي
- عمر 7 أيام: لقاح هتشنر B1 (تقطير بالعين).
- عمر 21 يوماً: لقاح لاسوتا (ماء الشرب).
- عمر 16 أسبوعاً: لقاح زيتي معطل (حقن بالعضل).`,
        },
      ],
    },
    {
      slug: 'optimal-poultry-house-ventilation-temperature',
      category: 'housing',
      featuredImageUrl:
        'https://images.unsplash.com/photo-1516467508483-a7212febe31a?auto=format&fit=crop&w=1200&q=80',
      isPublished: true,
      translations: [
        {
          locale: 'en',
          title: 'Broiler & Layer Housing: Ventilation, Litter & Temperature Masterclass',
          summary:
            'Master minimum ventilation, tunnel cooling, relative humidity management, and dry litter strategies to maximize flock FCR and eliminate respiratory stress.',
          content: `### Why Ventilation Dictates Farm Profitability
Poor airflow causes carbon dioxide and ammonia (NH3) accumulation. When ammonia exceeds 20 ppm, bird tracheas are damaged, leaving flocks susceptible to E. coli and CRD.

### Minimum Ventilation Guidelines
Ensure continuous fresh air exchange even in winter without chilling birds. Use static pressure negative fans with automated baffle inlets.

### Litter Quality Control
- Keep moisture below 25%.
- Regularly top dress with dry pine shavings or sanitized straw.
- Provide nipple drinkers with drip cups to prevent water pooling.`,
        },
        {
          locale: 'fr',
          title: 'Ventilation et Maîtrise d’Ambiance en Bâtiment Avicole',
          summary:
            'Optimisez la ventilation minimale, la gestion de la litière et le contrôle thermique pour améliorer l’indice de consommation et réduire l’ammoniac.',
          content: `### L’importance de la qualité d’air
L’ammoniac supérieur à 20 ppm endommage le système respiratoire des volailles et prédispose aux infections bactériennes.

### Recommandations
- Maintenir une humidité de litière inférieure à 25%.
- Réguler la dépression du bâtiment pour assurer un mélange d'air optimal sans courant d'air froid sur les poussins.`,
        },
        {
          locale: 'ar',
          title: 'التهوية والتحكم في حرارة عنابر الدواجن وجودة الفرشة',
          summary:
            'دليل تقني حول التهوية الدنيا، التبريد الصحراوي، إدارة الرطوبة النسبية وحماية القطيع من غاز الأمونيا.',
          content: `### أهمية التهوية لربحية المزرعة
تراكم غاز الأمونيا لأكثر من 20 جزء في المليون يسبب تلفاً شديداً في القصبة الهوائية للطائر، مما يفتح الباب للأمراض التنفسية المزمنة.

### توصيات الإدارة
- الحفاظ على رطوبة الفرشة أقل من 25%.
- توفير تهوية دنيا ثابتة تضمن تجديد الأكسجين دون تعريض الطيور للتيارات الهوائية المباشرة.`,
        },
      ],
    },
    {
      slug: 'egg-candling-incubation-humidity-schedule',
      category: 'incubation',
      featuredImageUrl:
        'https://images.unsplash.com/photo-1598965675045-45c5e72c7d05?auto=format&fit=crop&w=1200&q=80',
      isPublished: true,
      translations: [
        {
          locale: 'en',
          title: 'Artificial Incubation: Temperature, Humidity Cycles & Candling Protocol',
          summary:
            'Detailed 21-day chicken egg incubation protocol: setter parameters, humidity transitions, turning intervals, and day 7/14/18 candling benchmarks.',
          content: `### Critical Parameters (Days 1–18 Setter)
- **Temperature:** 37.5°C – 37.8°C (99.5°F – 100°F)
- **Relative Humidity:** 50% – 55%
- **Egg Turning:** Minimum every 2 hours through a 45-degree angle.

### Candling Milestones
- **Day 7:** Visible spider-like blood vessels radiating from the blastoderm. Remove infertile clears.
- **Day 14:** Dark embryo filling 80% of volume; clear air cell boundary.
- **Day 18 (Transfer to Hatcher):** Cease turning, increase humidity to 65%–70%, lower temperature to 37.0°C.`,
        },
        {
          locale: 'fr',
          title: 'Incubation Artificielle : Température, Hygrométrie et Mirrage',
          summary:
            'Protocole étape par étape pour réussir l’incubation des œufs de poule sur 21 jours, de l’incubateur à l’éclosoir.',
          content: `### Paramètres clés (J1 à J18)
- Température : 37,6°C
- Humidité : 52%
- Retournement automatique toutes les 2 heures.

### Mirrage
- J7 : Réseau vasculaire visible.
- J18 : Transfert vers l'éclosoir, arrêt du retournement et augmentation de l'humidité à 70%.`,
        },
        {
          locale: 'ar',
          title: 'التفريخ الصناعي لبيض الدجاج: درجات الحرارة، الرطوبة، ومراحل الفحص الضوئي',
          summary:
            'دليل تفصيلي لدورة التفقيس (21 يوماً): معايير المفقس، جدول الرطوبة، ومواعيد الفحص الضوئي في اليوم 7 و14 و18.',
          content: `### المعايير المثلى (الأيام 1 إلى 18)
- درجة الحرارة: 37.5 إلى 37.7 درجة مئوية.
- الرطوبة النسبية: 50% إلى 55%.
- التقليب: كل ساعتين بزاوية 45 درجة.

### الفحص الضوئي (الميرجة)
- اليوم 7: ظهور الشبكة العنكبوتية للأوعية الدموية. استبعاد البيض غير المخصب (الرائق).
- اليوم 18: نقل البيض إلى المفقس، إيقاف التقليب، ورفع الرطوبة إلى 70%.`,
        },
      ],
    },
  ];

  for (const art of articlesData) {
    const existing = await db
      .select({ id: schema.articles.id })
      .from(schema.articles)
      .where(eq(schema.articles.slug, art.slug))
      .limit(1);

    let articleId = existing[0]?.id;

    if (!articleId) {
      const [inserted] = await db
        .insert(schema.articles)
        .values({
          slug: art.slug,
          category: art.category,
          featuredImageUrl: art.featuredImageUrl,
          isPublished: art.isPublished,
        })
        .returning({ id: schema.articles.id });
      articleId = inserted.id;
    }

    for (const trans of art.translations) {
      await db
        .insert(schema.articleTranslations)
        .values({
          articleId: articleId,
          locale: trans.locale,
          title: trans.title,
          summary: trans.summary,
          content: trans.content,
        })
        .onConflictDoNothing();
    }
  }

  // 3. Default Products
  const productsData = [
    {
      slug: 'digital-automatic-egg-incubator-56',
      category: 'incubation',
      affiliatePlatform: 'amazon',
      affiliateUrl: 'https://amazon.com/dp/B0EXAMPLE?tag=goldenroost-20',
      priceDisplay: '$89.99',
      imageUrl:
        'https://images.unsplash.com/photo-1598965675045-45c5e72c7d05?auto=format&fit=crop&w=600&q=80',
      rating: '4.85',
      translations: [
        {
          locale: 'en',
          name: 'Professional 56-Egg Digital Incubator with Automatic Turning & Humidity Alarm',
          description:
            'Precision microcomputer-controlled incubator with dual AC/DC 12V backup power, external water channel filling, and built-in LED candling lamp for maximum hatchability.',
        },
        {
          locale: 'fr',
          name: 'Incubateur Automatique Digital 56 Œufs avec Mirreur Intégré',
          description:
            'Contrôle automatique de température et d’humidité, double alimentation secteur/batterie 12V, retournement automatique toutes les 2 heures.',
        },
        {
          locale: 'ar',
          name: 'فقاسة بيض رقمية أوتوماتيكية 56 بيضة مع فاحص ضوئي مدمج',
          description:
            'تحكم دقيق بدرجة الحرارة والرطوبة، تقليب بيض أوتوماتيكي كل ساعتين، إمكانية التشغيل على بطارية 12 فولت عند انقطاع الكهرباء.',
        },
      ],
    },
    {
      slug: 'poultry-nipple-drinker-360-anti-leak',
      category: 'equipment',
      affiliatePlatform: 'amazon',
      affiliateUrl: 'https://amazon.com/dp/B0DRINKER?tag=goldenroost-20',
      priceDisplay: '$24.50',
      imageUrl:
        'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?auto=format&fit=crop&w=600&q=80',
      rating: '4.78',
      translations: [
        {
          locale: 'en',
          name: 'Stainless Steel 360° Poultry Nipple Drinkers with Drip Cups (Pack of 20)',
          description:
            'Commercial grade horizontal nipple drinkers that keep coops completely dry, prevent water fouling, and deliver hygienic clean water on demand.',
        },
        {
          locale: 'fr',
          name: 'Pipettes Abreuvoirs Volailles 360° en Inox avec Coupelle (Lot de 20)',
          description:
            'Abreuvoirs anti-gaspillage évitant le mouillage de la litière et maintenant une eau propre en permanence.',
        },
        {
          locale: 'ar',
          name: 'حلمات شرب الدواجن 360 درجة من الستانلس ستيل مع كؤوس تجميع (طقم 20 قطعة)',
          description:
            'نظام شرب آلي مانع لتسرب المياه يحافظ على جفاف الفرشة ويوفر مياهاً نظيفة نقية بدون تلوث.',
        },
      ],
    },
    {
      slug: 'infrared-ceramic-brooder-lamp-250w',
      category: 'equipment',
      affiliatePlatform: 'amazon',
      affiliateUrl: 'https://amazon.com/dp/B0HEATER?tag=goldenroost-20',
      priceDisplay: '$18.99',
      imageUrl:
        'https://images.unsplash.com/photo-1516467508483-a7212febe31a?auto=format&fit=crop&w=600&q=80',
      rating: '4.90',
      translations: [
        {
          locale: 'en',
          name: 'Infrared Brooder Ceramic Heat Emitter 250W (No Light, 24/7 Brooding)',
          description:
            'Provides gentle, continuous 99% thermal efficiency infrared warmth for day-old chicks without disturbing their natural sleep cycle with blinding light.',
        },
        {
          locale: 'fr',
          name: 'Émetteur de Chaleur Céramique Infrarouge 250W pour Poussins',
          description:
            'Chaleur radiante continue sans émission lumineuse, idéale pour l’élevage des poussins sans perturber leur cycle biologique.',
        },
        {
          locale: 'ar',
          name: 'مصباح تدفئة سيراميك بالأشعة تحت الحمراء 250 واط لحضانات الصوص',
          description:
            'يوفر حرارة منتظمة ولطيفة لكتاكيت اليوم الأول دون إشعاع ضوئي مزعج، مما يحافظ على استقرار نوم ونمو الفراخ.',
        },
      ],
    },
  ];

  for (const prod of productsData) {
    const existing = await db
      .select({ id: schema.products.id })
      .from(schema.products)
      .where(eq(schema.products.slug, prod.slug))
      .limit(1);

    let productId = existing[0]?.id;

    if (!productId) {
      const [inserted] = await db
        .insert(schema.products)
        .values({
          slug: prod.slug,
          category: prod.category,
          affiliatePlatform: prod.affiliatePlatform,
          affiliateUrl: prod.affiliateUrl,
          priceDisplay: prod.priceDisplay,
          imageUrl: prod.imageUrl,
          rating: prod.rating,
          isPublished: true,
        })
        .returning({ id: schema.products.id });
      productId = inserted.id;
    }

    for (const trans of prod.translations) {
      await db
        .insert(schema.productTranslations)
        .values({
          productId: productId,
          locale: trans.locale,
          name: trans.name,
          description: trans.description,
        })
        .onConflictDoNothing();
    }
  }

  console.log('Golden Roost seed completed successfully!');
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed error:', err);
  process.exit(1);
});
