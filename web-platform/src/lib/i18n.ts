export type Locale = 'en' | 'fr' | 'ar';

export interface TranslationStrings {
  brandName: string;
  brandTagline: string;
  navHome: string;
  navArticles: string;
  navProducts: string;
  navAbout: string;
  navContact: string;
  navAdmin: string;
  heroBadge: string;
  heroTitle: string;
  heroSubtitle: string;
  downloadApp: string;
  exploreKnowledge: string;
  exploreProducts: string;
  featuresTitle: string;
  featuresSubtitle: string;
  feature1Title: string;
  feature1Desc: string;
  feature2Title: string;
  feature2Desc: string;
  feature3Title: string;
  feature3Desc: string;
  feature4Title: string;
  feature4Desc: string;
  latestArticlesTitle: string;
  viewAllArticles: string;
  featuredProductsTitle: string;
  viewAllProducts: string;
  readMore: string;
  viewProduct: string;
  affiliateNotice: string;
  footerRights: string;
  privacyPolicy: string;
  deleteAccount: string;
}

export const translations: Record<Locale, TranslationStrings> = {
  en: {
    brandName: 'Golden Roost',
    brandTagline: 'Precision Poultry Farm Management & Knowledge Platform',
    navHome: 'Home',
    navArticles: 'Veterinary Guides',
    navProducts: 'Farm Equipment',
    navAbout: 'About Us',
    navContact: 'Contact',
    navAdmin: 'Admin Portal',
    heroBadge: 'Smart Poultry Management Platform',
    heroTitle: 'Empowering Poultry Farmers with Precision & Intelligence',
    heroSubtitle:
      'Manage flocks, egg production, feed reserves, incubation cycles, and farm accounting 100% offline on mobile, while staying connected to cutting-edge veterinary knowledge and quality farm products.',
    downloadApp: 'Download Android App',
    exploreKnowledge: 'Read Veterinary Guides',
    exploreProducts: 'Browse Farm Products',
    featuresTitle: 'Built for Modern Broiler, Layer & Breeder Operations',
    featuresSubtitle:
      'Comprehensive management tools designed by poultry experts to optimize Feed Conversion Ratio (FCR), minimize chick mortality, and maximize profitability.',
    feature1Title: 'Offline-First Mobile Architecture',
    feature1Desc:
      'Record daily egg collections, feed consumption, mortality, and sales anywhere in the coop without needing an active internet connection.',
    feature2Title: 'Smart Feed & Ledger Automation',
    feature2Desc:
      'Track stock in kilograms and bags. Automated depletion alerts notify you days before feed runs out, with fully linked financial accounting.',
    feature3Title: 'Digital Candling & Incubation',
    feature3Desc:
      'Track 21-day incubation schedules, fertility candling checks, hatch rates, and seamlessly transfer day-old chicks into new brooding flocks.',
    feature4Title: 'Veterinary Knowledge & Protocols',
    feature4Desc:
      'Access peer-reviewed disease guides, biosecurity protocols, and vaccination calendars validated for commercial and backyard flocks.',
    latestArticlesTitle: 'Latest Veterinary Articles & Guides',
    viewAllArticles: 'View All Articles',
    featuredProductsTitle: 'Recommended Poultry Farm Equipment',
    viewAllProducts: 'View All Equipment',
    readMore: 'Read Full Guide',
    viewProduct: 'Check Price & Details',
    affiliateNotice:
      'Disclosure: Golden Roost is reader-supported. Some links on this site are affiliate links. If you make a purchase through them, we may earn a small commission at no additional cost to you.',
    footerRights: 'All rights reserved.',
    privacyPolicy: 'Privacy Policy',
    deleteAccount: 'Delete Account',
  },
  fr: {
    brandName: 'Golden Roost',
    brandTagline: 'Gestion Avicole de Précision & Plateforme de Connaissances',
    navHome: 'Accueil',
    navArticles: 'Guides Vétérinaires',
    navProducts: 'Matériel Avicole',
    navAbout: 'À Propos',
    navContact: 'Contact',
    navAdmin: 'Portail Admin',
    heroBadge: 'Gestion Intelligente des Élevages Avicoles',
    heroTitle: 'L’Excellence Technologique au Service des Éleveurs de Volailles',
    heroSubtitle:
      'Gérez vos bandes, pontes, aliments, incubations et finances à 100% hors-ligne sur mobile, tout en accédant aux meilleurs guides vétérinaires et équipements certifiés.',
    downloadApp: 'Télécharger l’Application',
    exploreKnowledge: 'Consulter les Guides',
    exploreProducts: 'Voir le Matériel',
    featuresTitle: 'Conçu pour les Élevages de Poulets de Chair et Pondeuses',
    featuresSubtitle:
      'Des outils complets pour optimiser votre indice de consommation (IC), réduire la mortalité et maximiser la rentabilité de votre exploitation.',
    feature1Title: 'Architecture Mobile 100% Hors-Ligne',
    feature1Desc:
      'Enregistrez vos ramassages d’œufs, consommations d’aliments, mortalités et ventes au cœur du bâtiment sans réseau.',
    feature2Title: 'Gestion Automatisée des Aliments',
    feature2Desc:
      'Suivi précis des stocks par sac et kilogramme avec alertes d’épuisement anticipées et liaison comptable directe.',
    feature3Title: 'Incubation & Mirrage Numérique',
    feature3Desc:
      'Suivi des cycles de 21 jours, contrôle de fertilité par mirrage et transfert immédiat des poussins éclos en nouvelle bande.',
    feature4Title: 'Biosécurité & Guides Vétérinaires',
    feature4Desc:
      'Protocoles de vaccination, prévention des pathologies et règles sanitaires validés par des spécialistes avicoles.',
    latestArticlesTitle: 'Derniers Articles et Protocoles Sanitaires',
    viewAllArticles: 'Tous les Articles',
    featuredProductsTitle: 'Équipements et Matériel Recommandés',
    viewAllProducts: 'Tout le Matériel',
    readMore: 'Lire le Guide',
    viewProduct: 'Voir le Produit',
    affiliateNotice:
      'Transparence commerciale : Golden Roost participe à des programmes d’affiliation. Nous pouvons percevoir une commission sans surcoût pour vous.',
    footerRights: 'Tous droits réservés.',
    privacyPolicy: 'Politique de Confidentialité',
    deleteAccount: 'Supprimer mon Compte',
  },
  ar: {
    brandName: 'Golden Roost',
    brandTagline: 'منصة إدارة مزارع الدواجن الذكية والدليل البيطري الشامل',
    navHome: 'الرئيسية',
    navArticles: 'المقالات البيطرية',
    navProducts: 'معدات المزارع',
    navAbout: 'من نحن',
    navContact: 'اتصل بنا',
    navAdmin: 'بوابة الإدارة',
    heroBadge: 'المنصة الذكية لإدارة حقول الدواجن',
    heroTitle: 'الريادة والذكاء في إدارة مشاريع الدواجن الحديثة',
    heroSubtitle:
      'تحكم كامل في القطعان، إنتاج البيض، استهلاك الأعلاف، دورات الفقاسات، والحسابات المالية بدون إنترنت 100%، مع إمكانية الوصول لأحدث المقالات البيطرية والمعدات المعتمدة.',
    downloadApp: 'تحميل تطبيق الأندرويد',
    exploreKnowledge: 'تصفح الدليل البيطري',
    exploreProducts: 'استعراض المعدات',
    featuresTitle: 'صُمم خصيصاً لمشاريع الدجاج اللاحم والبياض والأمهات',
    featuresSubtitle:
      'أدوات متطورة لحساب معامل التحويل الغذائي (FCR)، خفض نسب النفوق، ومضاعفة أرباح المزرعة.',
    feature1Title: 'عمل كامل بدون إنترنت على الهاتف',
    feature1Desc:
      'سجل يوميات الحقل من جمع بيض، استهلاك علف، وفيات ومبيعات داخل العنبر دون الحاجة لأي اتصال بالشبكة.',
    feature2Title: 'إدارة مخزون الأعلاف التلقائية',
    feature2Desc:
      'تتبع دقيق للمخزون بالأكياس والكيلوغرامات مع تنبيهات استباقية قبل نفاد العلف وربط تلقائي بالدفتر المالي.',
    feature3Title: 'إدارة الفقاسات والفحص الضوئي',
    feature3Desc:
      'جدولة دورات التفريخ على مدار 21 يوماً، توثيق نسب الخصوبة والفقس، وتحويل الصيصان إلى قطعان جديدة بضغطة زر.',
    feature4Title: 'أحدث الإرشادات واللقاحات البيطرية',
    feature4Desc:
      'دليل علاجي ووقائي شامل، جداول تحصينات معتمدة، وقواعد أمن حيوي لحماية المزرعة من الأوبئة.',
    latestArticlesTitle: 'أحدث المقالات والإرشادات البيطرية',
    viewAllArticles: 'جميع المقالات',
    featuredProductsTitle: 'أفضل معدات ومستلزمات مزارع الدواجن',
    viewAllProducts: 'جميع المعدات',
    readMore: 'قراءة الدليل',
    viewProduct: 'تفاصيل المنتج',
    affiliateNotice:
      'إفصاح تجاري: يحتوي موقع Golden Roost على روابط تسويق بالعمولة. عند الشراء من خلال هذه الروابط قد نحصل على عمولة بسيطة دون أي تكلفة إضافية عليك.',
    footerRights: 'جميع الحقوق محفوظة.',
    privacyPolicy: 'سياسة الخصوصية',
    deleteAccount: 'حذف الحساب والبيانات',
  },
};
