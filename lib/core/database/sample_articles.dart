import '../../models/article.dart';

final sampleArticles = [
  Article(
    id: 'art_brooding_survival',
    slug: 'chick-brooding-mortality-prevention',
    titleEn: 'Day-Old Chick Brooding: Critical Temperature and Early Hydration',
    titleFr:
        'Démarrage des Poussins: Température Critique et Hydratation Précoce',
    titleAr:
        'تحضين الكتاكيت: درجات الحرارة الحرجة والترطيب المبكر للحد من النفوق',
    summaryEn:
        'The first 72 hours determine flock survival. Learn proper brooder temperature gradients, glucose-electrolyte hydration, and draft control to prevent early mortality.',
    summaryFr:
        'Les premières 72 heures déterminent la survie du lot. Maîtrisez le gradient thermique, la réhydratation électrolytique et la ventilation sans courants d\'air.',
    summaryAr:
        'تحدد الساعات الـ 72 الأولى معدل بقاء الفوج. تعرف على تدرج درجات حرارة الحضانة، وسوائل الترطيب الكهرلية، ومنع التيارات الهوائية للحد من نفوق الصيصان.',
    bodyEn: '''### 1. The Brooder Environment
Day-old chicks cannot self-regulate body temperature until approximately 10 to 14 days of age. The target ambient temperature beneath the heat source (infrared brooder or radiant heater) must be 32°C to 34°C during the first 3 days, reducing by approximately 2.5°C to 3°C each week until ambient farm temperature is achieved.

### 2. Behavioral Thermoregulation Indicators
Instead of relying solely on thermometers, observe chick distribution:
- **Even distribution and active chirping**: Ideal temperature.
- **Huddled closely under the heater**: Brooder is too cold; risk of asphyxiation and chilling.
- **Pushed against the guard perimeter, panting with wings spread**: Brooder is too warm; dehydration risk.
- **Clustered in one corner**: Drafts or localized noise disturbance.

### 3. Immediate Hydration & Electrolytes
Water must precede feed by 2 to 4 hours. Provide room-temperature water (18°C–22°C) supplemented with a verified poultry electrolyte and vitamin mix (Vitamins A, D3, E, and B-complex) or a 4% glucose/dextrose solution for the first 24 hours to replenish glycogen reserves depleted during hatching and transport.

### 4. Crop Fill Verification
Inspect 100 randomly sampled chicks at 24 hours post-placement. At least 95% of crops must feel soft and pliable, indicating successful consumption of both water and crumb starter feed.''',
    bodyFr: '''### 1. L'Environnement de Démarrage
Les poussins d'un jour sont incapables de réguler leur température corporelle avant l'âge de 10 à 14 jours. La température sous la source de chaleur (éleveuse radiante ou lampe infrarouge) doit être de 32°C à 34°C pendant les 3 premiers jours, puis diminuer d'environ 2,5°C à 3°C par semaine.

### 2. Observation du Comportement
- **Répartition homogène et activité normale** : Température optimale.
- **Regroupement serré sous la lampe** : Ambiance trop froide, risque d'étouffement.
- **Fuite vers les parois du cercle, halètement** : Ambiance trop chaude, déshydratation rapide.
- **Regroupement d'un seul côté** : Présence de courants d'air.

### 3. Abreuvement et Électrolytes
L'accès à l'eau tempérée (18°C à 22°C) doit précéder la distribution de nourriture de 2 à 4 heures. Ajoutez un complexe d'électrolytes et vitamines (A, D3, E) pendant les premières 24 heures pour reconstituer les réserves énergétiques post-éclosion.''',
    bodyAr: '''### ١. بيئة التحضين المثالية
لا تستطيع الكتاكيت حديثة الفقس تنظيم درجة حرارة أجسامها حتى عمر ١٠ إلى ١٤ يوماً. يجب أن تتراوح درجة الحرارة أسفل مصدر التدفئة بين ٣٢ و ٣٤ درجة مئوية خلال الأيام الثلاثة الأولى، ثم تنخفض تدريجياً بمعدل ٢٫٥ إلى ٣ درجات مئوية أسبوعياً.

### ٢. مراقبة سلوك الكتاكيت
- **توزيع متجانس وحركة نشطة**: الحرارة مثالية.
- **تجمع وتكدس تحت الدفاية**: المكان بارد جداً، وهناك خطر الاختناق والتسمم المعوي.
- **ابتعاد الكتاكيت للأطراف مع فتح الأجنحة واللهث**: المكان شديد الحرارة وخطر الجفاف مرتفع.
- **تجمع في زاوية معينة**: وجود تيار هوائي بارد.

### ٣. الترطيب ومحلول معالجة الجفاف
يجب تقديم الماء الدافئ المعتدل (١٨-٢٢ مئوية) قبل تقديم العلف بساعتين إلى ٤ ساعات. يُنصح بإضافة محلول إلكتروليت وفيتامينات (أ، د٣، هـ) أو محلول سكري مخفف في الساعات الأولى لتعويض طاقة الفقس والنقل.''',
    category: 'brooding',
    tags: ['brooding', 'chicks', 'mortality', 'temperature', 'hydration'],
    author: 'Golden Roost Veterinary & Avian Care Team',
    reviewer: 'Dr. T. Benali, DVM, Avian Pathology Specialist',
    readingTimeMinutes: 5,
    references:
        '1. FAO Animal Production and Health Manual No. 4: Small-scale poultry production.\n2. Bell, D. D., & Weaver, W. D. (2002). Commercial Chicken Meat and Egg Production. Springer Science.\n3. World Poultry Science Association (WPSA) Brooder Temperature Standards.',
    disclaimer:
        'This content is provided for educational purposes only and does not replace individualized diagnosis or treatment by a licensed avian veterinarian.',
    isPublished: true,
    isFeatured: true,
    publishedAt: DateTime(2026, 1, 15),
    updatedAt: DateTime(2026, 1, 15),
  ),
  Article(
    id: 'art_vaccination_biosecurity',
    slug: 'poultry-vaccination-cold-chain-safety',
    titleEn: 'Flock Vaccination Protocols and Cold-Chain Integrity',
    titleFr:
        'Protocoles de Vaccination Avicole et Respect de la Chaîne du Froid',
    titleAr: 'بروتوكولات تحصين الدواجن وضمان سلامة السلسلة الباردة للقاحات',
    summaryEn:
        'Live vaccines are easily inactivated by chlorine, heat, or improper administration. Learn critical steps for Newcastle, Gumboro (IBD), and Bronchitis immunization.',
    summaryFr:
        'Les vaccins vivants sont sensibles au chlore, à la chaleur et aux erreurs de dilution. Guide des bonnes pratiques pour Newcastle, Gumboro et Bronchite infectieuse.',
    summaryAr:
        'تفقد اللقاحات الحية فعاليتها سريعاً بفعل الكلور أو الحرارة أو سوء الإعطاء. دليل عملي لتحصينات النيوكاسل والجمبورو والتهاب الشعب الهوائية المعدي.',
    bodyEn: '''### 1. Cold Chain Maintenance (2°C to 8°C)
Live viral vaccines (such as Newcastle Disease LaSota/Clone 30 and Infectious Bursal Disease) are perishable biological products. They must be stored between +2°C and +8°C at all times. Freezing liquid vaccines or exposing freeze-dried vials to sunlight and ambient room temperatures inactivates the live virus within 30 minutes.

### 2. Drinking Water Administration Precautions
- **Chlorine Neutralization**: Never use municipal tap water containing chlorine; chlorine neutralizes live vaccine viruses immediately. Use distilled water or add skim milk powder at 2.5 grams per liter of water 20 minutes prior to vaccine reconstitution to protect the viral titer.
- **Thirst Period**: Withhold water for 1.5 to 2 hours before administration depending on weather so birds consume the full vaccine volume within 90 to 120 minutes.
- **Dye Tracing**: Use food-grade blue dye to monitor vaccine uptake by inspecting tongues and crops of 50 birds.

### 3. Record Keeping & Withdrawals
Log vaccine serial numbers, expiration dates, dosage, and veterinary batch details in your Golden Roost Health Records module. Strictly adhere to meat and egg withdrawal times printed on approved manufacturer labels.''',
    bodyFr: '''### 1. Respect de la Chaîne du Froid (2°C à 8°C)
Les vaccins vivants (Newcastle LaSota, Gumboro, Bronchite Infectieuse) doivent être impérativement conservés entre 2°C et 8°C. Ne congelez jamais les solvants liquides et évitez l'exposition au soleil.

### 2. Administration par Eau de Boisson
- **Neutralisation du Chlore** : Le chlore détruit les souches vaccinales vivantes. Utilisez de l'eau sans chlore ou ajoutez 2,5 g de lait écrémé en poudre par litre d'eau 20 minutes avant la dilution.
- **Période de Soif** : Privez les volailles d'eau pendant 1h30 à 2h avant la distribution pour garantir une consommation intégrale en moins de deux heures.
- **Colorant Traceur** : Un colorant bleu alimentaire permet de vérifier la prise vaccinale sur la langue et le jabot.''',
    bodyAr: '''### ١. الحفاظ على السلسلة الباردة (٢ إلى ٨ درجات مئوية)
اللقاحات الحية (مثل نيوكاسل لاسونا وكلون، والجمبورو) مواد بيولوجية حساسة للغاية. يجب حفظها بين ٢ و ٨ درجات مئوية. يؤدي تعرض الأمبولات لأشعة الشمس أو حرارة الغرفة إلى موت الفيروس اللقاحي خلال دقائق.

### ٢. شروط إعطاء التحصين في مياه الشرب
- **التخلص من الكلور**: يقتل الكلور اللقاح فوراً. استخدم مياهاً خالية من الكلور أو أضف حليب مجفف خالي الدسم بمعدل ٢٫٥ غرام لكل لتر ماء قبل خلط اللقاح بـ ٢٠ دقيقة لحماية الجزيئات الفيروسية.
- **التعطيش**: تعطش الطيور لمدة ساعة ونصف إلى ساعتين قبل التحصين لضمان شرب اللقاح بالكامل في غضون ٩٠ إلى ١٢٠ دقيقة.
- **الصبغة الزرقاء**: تساعد صبغة الطعام الزرقاء في فحص ألسنة الكتاكيت للتأكد من تناول الجميع للجرعة.''',
    category: 'health',
    tags: ['vaccination', 'newcastle', 'gumboro', 'health', 'biosecurity'],
    author: 'Golden Roost Veterinary & Avian Care Team',
    reviewer: 'Dr. M. Laurent, DVM, Poultry Immunologist',
    readingTimeMinutes: 6,
    references:
        '1. OIE Terrestrial Manual: Newcastle Disease & Infectious Bursal Disease.\n2. Jordan, F. T. W., & Pattison, M. (1996). Poultry Diseases. W.B. Saunders.\n3. Marangon, S., & Busani, L. (2007). The vaccination for avian influenza and ND in poultry. Dev Biol (Basel).',
    disclaimer:
        'This content is provided for educational purposes only and does not replace individualized diagnosis or treatment by a licensed avian veterinarian.',
    isPublished: true,
    isFeatured: true,
    publishedAt: DateTime(2026, 1, 20),
    updatedAt: DateTime(2026, 1, 20),
  ),
  Article(
    id: 'art_eggshell_nutrition',
    slug: 'eggshell-quality-calcium-phosphorus-nutrition',
    titleEn:
        'Optimizing Layer Nutrition: Calcium, Phosphorus, and Shell Strength',
    titleFr:
        'Nutrition des Pondeuses: Calcium, Phosphore et Solidité de la Coquille',
    titleAr: 'تغذية الدجاج البياض: توازن الكالسيوم والفوسفور لصلابة قشرة البيض',
    summaryEn:
        'Cracked eggs reduce farm revenue. Discover coarse limestone particle timing, phytase benefits, and phosphorus ratios to prevent weak shells and cage layer fatigue.',
    summaryFr:
        'Les œufs fêlés diminuent directement vos marges. Maîtrisez l\'apport de calcaire grossier, le ratio calcium/phosphore et le rôle de la vitamine D3.',
    summaryAr:
        'البيض المكسور يقلل الأرباح مباشرة. اكتشف التوقيت المناسب لحجر الجير الخشن، ونسبة الكالسيوم إلى الفوسفور، ودور فيتامين د٣ لتقوية القشرة.',
    bodyEn: '''### 1. The Calcium Cycle of the Laying Hen
A modern commercial layer requires approximately 4.0 to 4.2 grams of calcium daily to deposit a sound, crack-resistant eggshell of 2.0 to 2.2 grams of pure calcium carbonate. Shell calcification occurs predominantly overnight during the dark cycle (a 12 to 14 hour process).

### 2. Particle Size Matters: Fine vs. Coarse Limestone
- **Fine limestone (<1 mm)**: Rapidly absorbed and excreted via the kidneys if provided early in the morning when the shell gland is inactive.
- **Coarse limestone / Oyster shell (2 mm to 4 mm)**: Retained in the gizzard for slow dissolution throughout the night, ensuring continuous blood calcium levels during peak eggshell formation.
- **Recommended Ratio**: 65% coarse particles to 35% fine particles in peak production rations.

### 3. Available Phosphorus and Vitamin D3
Calcium cannot be effectively assimilated without balanced available phosphorus (target 0.40%–0.45% available P) and adequate 25-hydroxycholecalciferol (Vitamin D3) at 3,000 to 4,000 IU/kg of feed to prevent rickets and cage layer fatigue.''',
    bodyFr: '''### 1. Le Cycle du Calcium chez la Pondeuse
Une poule pondeuse a besoin de 4,0 à 4,2 grammes de calcium par jour. La formation de la coquille s'effectue principalement pendant la nuit dans la glande coquillière (utérus).

### 2. Granulométrie du Calcaire
- **Particules fines (<1 mm)** : Solubilisées trop vite, souvent éliminées avant la calcification nocturne.
- **Particules grossières ou coquilles d'huîtres (2 à 4 mm)** : Retenues dans le gésier pour une libération lente et continue de calcium pendant la nuit.
- **Ratio conseillé** : 65 % de calcaire grossier et 35 % de poudre fine.

### 3. Rôle du Phosphore et de la Vitamine D3
Le ratio Calcium/Phosphore disponible doit rester rigoureusement contrôlé avec une supplémentation adéquate en vitamine D3 pour éviter la fatigue de cage et les coquilles minces.''',
    bodyAr: '''### ١. دورة الكالسيوم لدى الدجاجة البياضة
تحتاج الدجاجة البياضة إلى ما يقارب ٤٫٠ إلى ٤٫٢ غرام من الكالسيوم يومياً لتكوين قشرة بيض متينة وسميكة. وتحدث عملية ترسيب القشرة في الغدة الرحمية بشكل أساسي أثناء الليل (تستغرق ١٢ إلى ١٤ ساعة).

### ٢. أهمية حجم حبيبات كربونات الكالسيوم (حجر الجير)
- **الحجر الجيري الناعم (أقل من ١ مم)**: يمتص ويفرز بسرعة قبل بدء تكوين القشرة ليلاً.
- **الحجر الجيري الخشن أو قشور المحار (٢ إلى ٤ مم)**: يستقر في القانصة ويتحلل ببطء على مدار ساعات الليل، مما يوفر إمداداً مستمراً من الكالسيوم في الدم أثناء تكوين القشرة.
- **النسبة المثالية**: ٦٥٪ حبيبات خشنة و ٣٥٪ ناعمة في علف مرحلة الإنتاج القصوى.

### ٣. الفوسفور المتاح وفيتامين د٣
لا يمكن الاستفادة من الكالسيوم بدون نسبة فوسفور متوازنة (٠٫٤٠٪ - ٠٫٤٥٪ فوسفور متاح) وتدعيم العلف بفيتامين د٣ لحماية عظام الدجاجة من هشاشة العظام وضعف القشرة.''',
    category: 'nutrition',
    tags: ['nutrition', 'eggs', 'calcium', 'layers', 'eggshell'],
    author: 'Golden Roost Nutrition Laboratory',
    reviewer: 'Prof. K. H. Ahmed, PhD in Poultry Nutrition',
    readingTimeMinutes: 5,
    references:
        '1. Leeson, S., & Summers, J. D. (2009). Commercial Poultry Nutrition. University Books.\n2. NRC (1994). Nutrient Requirements of Poultry. 9th rev. ed. National Academy Press.\n3. Roland, D. A. (1986). Egg shell quality: problems and solutions. Poultry Science, 65(1), 18-24.',
    disclaimer:
        'This content is provided for educational purposes only and does not replace individualized diagnosis or treatment by a licensed avian veterinarian.',
    isPublished: true,
    isFeatured: false,
    publishedAt: DateTime(2026, 2, 1),
    updatedAt: DateTime(2026, 2, 1),
  ),
  Article(
    id: 'art_biosecurity_farm_defense',
    slug: 'poultry-farm-biosecurity-sanitation',
    titleEn:
        'Biosecurity in Practice: Perimeter Defense, Footbaths, and Rodent Control',
    titleFr:
        'Biosécurité Pratique: Défense Périmétrique, Pédiluves et Dératisation',
    titleAr:
        'الأمن الحيوي الميداني: حماية المحيط الخارجي، مغاطس الأقدام، ومكافحة القوارض',
    summaryEn:
        'Prevention is far cheaper than treating an outbreak. Establish strict Danish entry benches, effective disinfectant contact times, and wild bird exclusion netting.',
    summaryFr:
        'Mieux vaut prévenir que dépeupler. Mettez en place le sas sanitaire danois, le renouvellement des pédiluves et le grillage anti-oiseaux sauvages.',
    summaryAr:
        'الوقاية أرخص بكثير من التعامل مع وباء فيروسي. تعرّف على تصميم المغطس وتغيير المطهرات، والشبك المانع للطيور البرية والقوارض.',
    bodyEn: '''### 1. The Three Zones of Farm Biosecurity
- **Clean Zone**: Interior of the poultry houses. Dedicated coveralls and boots only.
- **Buffer Zone**: Farmyard, feed silos, and parking area. Limited vehicle access with tire disinfection.
- **Exclusion Zone**: Farm perimeter fencing preventing stray animals, unauthorized vehicles, and visitors.

### 2. Danish Entry System (The Physical Barrier)
A physical bench or step-over barrier separating the "dirty" entry area from the "clean" bird area is essential:
1. Remove street footwear on the dirty side.
2. Step over the barrier without touching the floor with socks.
3. Put on house-dedicated boots and sanitized coveralls.
4. Wash hands with antibacterial soap or alcohol sanitizer.

### 3. Footbaths and Contact Times
Footbaths fail when organic matter accumulates. Mud and organic debris neutralize glutaraldehyde and quaternary ammonium compounds. Clean boots mechanically with a brush before dipping, and refresh disinfectant solutions every 48 to 72 hours.''',
    bodyFr: '''### 1. Les Trois Zones de Biosécurité
- **Zone Propre** : Intérieur des poulaillers. Tenue et bottes dédiées exclusives.
- **Zone Tampon** : Cour de la ferme, silos d'aliment. Accès restreint des véhicules avec désinfection des roues.
- **Zone d'Exclusion** : Clôture périphérique empêchant l'accès des animaux errants et des visiteurs.

### 2. Le Sas Sanitaire Danois
Un banc de séparation physique évite l'introduction des germes extérieurs :
1. Déchausser les chaussures extérieures du côté sale.
2. Enjamber le banc sans poser le pied en chaussette au sol.
3. Enfiler les bottes spécifiques du bâtiment et la combinaison propre.
4. Se désinfecter soigneusement les mains.

### 3. Pédiluves et Temps de Contact
Un pédiluve souillé de litière devient inefficace. Brossez d'abord les semelles avant immersion et changez la solution désinfectante tous les 2 à 3 jours.''',
    bodyAr: '''### ١. المناطق الثلاث للأمن الحيوي في المزرعة
- **المنطقة النظيفة**: داخل حظائر الطيور. ملابس وأحذية مخصصة فقط لكل عنبر.
- **المنطقة العازلة**: فناء المزرعة وصوامع العلف. دخول محدد للسيارات مع تطهير العجلات.
- **المنطقة الخارجية**: السياج المحيط بالمزرعة لمنع الحيوانات الضالة والزوار غير المصرح لهم.

### ٢. الحاجز الفاصل (النظام الدنماركي للدخول)
حاجز خشبي أو خرساني يمنع دخول الميكروبات:
١. خلع الحذاء الخارجي في الجانب الخارجي.
٢. العبور فوق المقعد دون ملامسة الأرضية بالجوارب.
٣. ارتداء الحذاء الخاص بالعنبر واللباس المعقم.
٤. غسل وتعقيم الأيدي بمطهر كحولي.

### ٣. مغاطس الأقدام وفعالية المطهرات
تفقد المطهرات فعاليتها إذا امتلأت المغاطس بالأتربة والسبلة. نظف الحذاء بفرشاة أولاً لإزالة الأوساخ العضوية، وقم بتجديد محلول التطهير كل ٤٨ إلى ٧٢ ساعة.''',
    category: 'biosecurity',
    tags: ['biosecurity', 'hygiene', 'disinfection', 'disease', 'prevention'],
    author: 'Golden Roost Veterinary & Avian Care Team',
    reviewer: 'Dr. T. Benali, DVM, Avian Pathology Specialist',
    readingTimeMinutes: 4,
    references:
        '1. Biosecurity for Avian Influenza and Newcastle Disease. FAO Animal Health Manual 12.\n2. Defra UK Code of Practice for the Prevention and Control of Salmonella in Poultry.\n3. World Organisation for Animal Health (WOAH) Terrestrial Animal Health Code.',
    disclaimer:
        'This content is provided for educational purposes only and does not replace individualized diagnosis or treatment by a licensed avian veterinarian.',
    isPublished: true,
    isFeatured: false,
    publishedAt: DateTime(2026, 2, 10),
    updatedAt: DateTime(2026, 2, 10),
  ),
  Article(
    id: 'art_quail_management',
    slug: 'coturnix-quail-farming-essentials',
    titleEn:
        'Coturnix Quail Management: Density, Light Cycles, and Egg Collection',
    titleFr:
        'Élevage de la Caille du Japon: Densité, Éclairage et Collecte d\'Œufs',
    titleAr:
        'تربية السمان الياباني: الكثافة المثالية، برامج الإضاءة، وجمع البيض',
    summaryEn:
        'Japanese quail mature rapidly in 6 weeks. Discover ideal cage stocking density, 16-hour photoperiods for peak lay, and proper egg handling to avoid shell micro-cracks.',
    summaryFr:
        'La caille commence à pondre dès 6 semaines. Maîtrisez la densité en cage, les 16 heures de lumière nécessaires à la ponte et la collecte délicate des œufs.',
    summaryAr:
        'يتميز السمان بالإنتاج المبكر عند عمر ٦ أسابيع. دليلك لكثافة الأقفاص، وبرنامج الإضاءة ١٦ ساعة للإنتاج الكثيف، والتعامل السليم مع بيض السمان الرقيق.',
    bodyEn: '''### 1. High Growth and Rapid Maturity
Coturnix quail (Japanese Quail) grow exponentially, reaching sexual maturity between 6 and 7 weeks of age. Females can produce 280 to 300 nutrient-dense eggs annually under proper management.

### 2. Cage Density and Floor Requirements
- **Cage Density**: Provide 150 to 200 cm² floor area per adult bird in multi-tier battery cages.
- **Headroom**: Cages should have a height of 18 to 22 cm. Avoid tall ceilings without netting; frightened quail jump vertically with force, causing head trauma.
- **Rollaway Slopes**: Slanted cage floors (6° to 8° angle) ensure eggs roll away immediately upon lay, preventing dirtying and accidental trampling.

### 3. Photoperiod for Continuous Laying
Quail are extremely photoperiod-sensitive. Maintaining 14 to 16 hours of continuous light (natural daylight combined with warm LED lighting at 15–20 lux) is non-negotiable. Any drop below 14 hours of daily light induces molting and cessation of laying within 7 to 10 days.''',
    bodyFr: '''### 1. Croissance Rapide et Maturité
La caille japonaise (Coturnix japonica) atteint sa maturité sexuelle dès 6 à 7 semaines d'âge. Une femelle peut pondre 280 à 300 œufs par an.

### 2. Densité et Conception des Cages
- **Surface** : Comptez 150 à 200 cm² par oiseau adulte en batterie.
- **Hauteur de Cage** : Entre 18 et 22 cm. Une cage trop haute favorise les envols violents causant des traumatismes crâniens mortels.
- **Pente du Plancher** : Une pente de 6° à 8° permet à l'œuf de rouler hors d'atteinte immédiatement après la ponte.

### 3. Programme Lumineux
La caille exige 14 à 16 heures de lumière constante par jour. Une réduction de la photopériode entraîne une chute brutale de la ponte et le déclenchement de la mue.''',
    bodyAr: '''### ١. سرعة النمو والإنتاج المبكر
يتميز السمان الياباني بنموه السريع، حيث يصل إلى النضج الجنسي وبدء وضع البيض في عمر ٦ إلى ٧ أسابيع، وتنتج الأنثى ما يقارب ٢٨٠ إلى ٣٠٠ بيضة سنوياً عند توفير الرعاية المناسبة.

### ٢. كثافة الأقفاص والمواصفات الفنية
- **المساحة**: خصص من ١٥٠ إلى ٢٠٠ سم² لكل طائر بالغ في الأقفاص المتعددة الطوابق.
- **ارتفاع القفص**: يجب ألا يتجاوز ارتفاع القفص ١٨ إلى ٢٢ سم لتجنب ارتداد السمان لأعلى عند الفزع وكسر الرقبة.
- **ميل الأرضية**: انحدار بنسبة ٦ إلى ٨ درجات يضمن تدحرج البيض فور وضعه بعيداً عن أقدام الطيور.

### ٣. برنامج الإضاءة
السمان حساس جداً لطول فترة الإضاءة. يحتاج قطيع السمان البياض إلى ١٤ إلى ١٦ ساعة إضاءة يومياً (بين ضوء النهار الطبيعي والإضاءة الاصطناعية الهادئة). أي انخفاض عن ١٤ ساعة يؤدي لتوقف وضع البيض وبدء القلش.''',
    category: 'quail',
    tags: ['quail', 'coturnix', 'eggs', 'lighting', 'density'],
    author: 'Golden Roost Field Agronomists',
    reviewer: 'Dr. T. Benali, DVM, Avian Pathology Specialist',
    readingTimeMinutes: 4,
    references:
        '1. Shanaway, M. M. (1994). Quail Production Systems: A review. FAO Animal Production and Health Papers.\n2. Lucotte, G. (1990). The Japanese Quail: Production and genetics.\n3. World Poultry Science Journal: Environmental conditions for Coturnix quail.',
    disclaimer:
        'This content is provided for educational purposes only and does not replace individualized diagnosis or treatment by a licensed avian veterinarian.',
    isPublished: true,
    isFeatured: false,
    publishedAt: DateTime(2026, 2, 18),
    updatedAt: DateTime(2026, 2, 18),
  ),
];
