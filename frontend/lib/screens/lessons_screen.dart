import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import '../widgets/logo_header.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return Column(
      children: [
        const LogoHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leçons', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('9 chapitres pédagogiques', style: TextStyle(color: Color(0xFF999999))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showLessonDetail(context, lesson, locale),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('${index + 1}',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lesson['title_${locale.languageCode}'] ?? lesson['title_fr'],
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(lesson['subtitle_${locale.languageCode}'] ?? lesson['subtitle_fr'],
                                    style: TextStyle(color: Color(0xFF999999), fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLessonDetail(BuildContext context, Map<String, dynamic> lesson, Locale locale) {
    final lang = locale.languageCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFF666666),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(lesson['title_$lang'] ?? lesson['title_fr'],
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              _buildSection('Définition', lesson['definition_$lang'] ?? lesson['definition_fr']),
              _buildSection('Formule', lesson['formula'] ?? '', isFormula: true),
              _buildSection('Interprétation', lesson['interpretation_$lang'] ?? lesson['interpretation_fr']),
              _buildSection('Remarque', lesson['remark_$lang'] ?? lesson['remark_fr']),
              _buildSection('Exemple', lesson['example_$lang'] ?? lesson['example_fr']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isFormula = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFormula ? AppColors.primary.withOpacity(0.1) : Color(0xFF0F1F3D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(content, style: TextStyle(height: 1.6, fontSize: isFormula ? 16 : 14)),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _lessons = [
  {
    'title_fr': 'La moyenne',
    'title_en': 'The Mean',
    'subtitle_fr': 'Arithmétique, pondérée, pour données groupées et en classes',
    'subtitle_en': 'Arithmetic, weighted, for grouped and class data',
    'definition_fr': 'La moyenne arithmétique est la somme de toutes les valeurs divisée par le nombre total d\'observations. C\'est la mesure de tendance centrale la plus utilisée.',
    'definition_en': 'The arithmetic mean is the sum of all values divided by the total number of observations. It is the most commonly used measure of central tendency.',
    'formula': 'x̄ = Σxᵢ / n',
    'interpretation_fr': 'La moyenne représente le point d\'équilibre de la distribution. Si on distribuait également la somme totale entre toutes les observations, chaque observation recevrait la moyenne.',
    'interpretation_en': 'The mean represents the balance point of the distribution. If the total sum were distributed equally among all observations, each would receive the mean.',
    'remark_fr': 'La moyenne est sensible aux valeurs extrêmes (outliers). Une seule valeur très grande ou très petite peut fortement influencer la moyenne.',
    'remark_en': 'The mean is sensitive to extreme values (outliers). A single very large or very small value can strongly influence the mean.',
    'example_fr': 'Données : 12, 15, 18, 22, 25\nx̄ = (12 + 15 + 18 + 22 + 25) / 5 = 92 / 5 = 18.4\nLa moyenne est 18.4.',
    'example_en': 'Data: 12, 15, 18, 22, 25\nx̄ = (12 + 15 + 18 + 22 + 25) / 5 = 92 / 5 = 18.4\nThe mean is 18.4.',
  },
  {
    'title_fr': 'La médiane',
    'title_en': 'The Median',
    'subtitle_fr': 'Interpolation linéaire, médiane pour classes',
    'subtitle_en': 'Linear interpolation, median for classes',
    'definition_fr': 'La médiane est la valeur qui divise la distribution en deux parties égales : 50% des observations sont inférieures et 50% sont supérieures.',
    'definition_en': 'The median is the value that divides the distribution into two equal parts: 50% of observations are below and 50% are above.',
    'formula': 'Me = L + [(N/2 − F) / f] × h (pour classes)',
    'interpretation_fr': 'La médiane est robuste aux valeurs extrêmes. Elle est préférée à la moyenne quand la distribution est asymétrique.',
    'interpretation_en': 'The median is robust to extreme values. It is preferred over the mean when the distribution is skewed.',
    'remark_fr': 'Pour un nombre pair d\'observations, la médiane est la moyenne des deux valeurs centrales.',
    'remark_en': 'For an even number of observations, the median is the average of the two central values.',
    'example_fr': 'Données : 12, 15, 18, 22, 25\nN = 5 (impair), position = (5+1)/2 = 3ème valeur\nMe = 18',
    'example_en': 'Data: 12, 15, 18, 22, 25\nN = 5 (odd), position = (5+1)/2 = 3rd value\nMe = 18',
  },
  {
    'title_fr': 'Variance et écart-type',
    'title_en': 'Variance and Standard Deviation',
    'subtitle_fr': 'Population vs échantillon, interprétation du CV',
    'subtitle_en': 'Population vs sample, CV interpretation',
    'definition_fr': 'La variance mesure la dispersion des valeurs par rapport à la moyenne. L\'écart-type est sa racine carrée, exprimée dans la même unité que les données.',
    'definition_en': 'Variance measures the spread of values around the mean. Standard deviation is its square root, expressed in the same unit as the data.',
    'formula': 'σ² = Σ(xᵢ − x̄)² / n\nσ = √σ²',
    'interpretation_fr': 'Un écart-type faible indique que les données sont homogènes (proches de la moyenne). Un écart-type élevé indique une forte dispersion.',
    'interpretation_en': 'A low standard deviation indicates homogeneous data (close to the mean). A high standard deviation indicates strong dispersion.',
    'remark_fr': 'CV < 15% : faible dispersion (homogène)\n15% < CV < 30% : dispersion modérée\nCV > 30% : forte dispersion (hétérogène)',
    'remark_en': 'CV < 15%: low dispersion (homogeneous)\n15% < CV < 30%: moderate dispersion\nCV > 30%: high dispersion (heterogeneous)',
    'example_fr': 'Données : 12, 15, 18, 22, 25\nx̄ = 18.4\nσ² = [(12-18.4)² + (15-18.4)² + ...] / 5 = 22.64\nσ = √22.64 = 4.76',
    'example_en': 'Data: 12, 15, 18, 22, 25\nx̄ = 18.4\nσ² = [(12-18.4)² + (15-18.4)² + ...] / 5 = 22.64\nσ = √22.64 = 4.76',
  },
  {
    'title_fr': 'Quartiles Q1 / Q2 / Q3',
    'title_en': 'Quartiles Q1 / Q2 / Q3',
    'subtitle_fr': 'Calcul par interpolation, boîte à moustaches',
    'subtitle_en': 'Interpolation calculation, box plot',
    'definition_fr': 'Les quartiles divisent la distribution ordonnée en 4 parties égales. Q1 (25%), Q2 = Médiane (50%), Q3 (75%).',
    'definition_en': 'Quartiles divide the ordered distribution into 4 equal parts. Q1 (25%), Q2 = Median (50%), Q3 (75%).',
    'formula': 'IQR = Q3 − Q1\nBornes outliers : [Q1 − 1.5×IQR ; Q3 + 1.5×IQR]',
    'interpretation_fr': 'L\'IQR (écart interquartile) contient 50% central de la distribution. Les valeurs en dehors de [Q1 − 1.5×IQR ; Q3 + 1.5×IQR] sont considérées comme aberrantes.',
    'interpretation_en': 'The IQR (interquartile range) contains the central 50% of the distribution. Values outside [Q1 − 1.5×IQR ; Q3 + 1.5×IQR] are considered outliers.',
    'remark_fr': 'Les quartiles sont plus robustes que la moyenne et l\'écart-type car ils ne sont pas affectés par les valeurs extrêmes.',
    'remark_en': 'Quartiles are more robust than mean and standard deviation because they are not affected by extreme values.',
    'example_fr': 'Données : 12, 15, 18, 22, 25\nQ1 = 15, Q2 = 18, Q3 = 25\nIQR = 25 − 15 = 10\nOutliers < 15 − 1.5×10 = 0 ou > 25 + 1.5×10 = 40',
    'example_en': 'Data: 12, 15, 18, 22, 25\nQ1 = 15, Q2 = 18, Q3 = 25\nIQR = 25 − 15 = 10\nOutliers < 15 − 1.5×10 = 0 or > 25 + 1.5×10 = 40',
  },
  {
    'title_fr': 'Déciles D1 à D9',
    'title_en': 'Deciles D1 to D9',
    'subtitle_fr': 'Calcul, interprétation, lien avec quartiles',
    'subtitle_en': 'Calculation, interpretation, link with quartiles',
    'definition_fr': 'Les déciles divisent la distribution en 10 parties égales. D1 = 10%, D5 = Médiane = Q2, D9 = 90%.',
    'definition_en': 'Deciles divide the distribution into 10 equal parts. D1 = 10%, D5 = Median = Q2, D9 = 90%.',
    'formula': 'Dₖ = valeur au percentile 10k',
    'interpretation_fr': 'D5 est égal à la médiane (Q2). D1, D2, D3, D4 sont proches de Q1. D6, D7, D8 sont proches de Q3.',
    'interpretation_en': 'D5 equals the median (Q2). D1, D2, D3, D4 are close to Q1. D6, D7, D8 are close to Q3.',
    'remark_fr': 'Les déciles sont utiles pour segmenter la population en groupes de taille égale.',
    'remark_en': 'Deciles are useful for segmenting the population into equal-sized groups.',
    'example_fr': 'Pour N = 100 observations :\nD1 = valeur à la position 10\nD5 = valeur à la position 50 (médiane)\nD9 = valeur à la position 90',
    'example_en': 'For N = 100 observations:\nD1 = value at position 10\nD5 = value at position 50 (median)\nD9 = value at position 90',
  },
  {
    'title_fr': 'Données discrètes vs continues',
    'title_en': 'Discrete vs Continuous Data',
    'subtitle_fr': 'Différences, exemples, choix du graphique',
    'subtitle_en': 'Differences, examples, chart choice',
    'definition_fr': 'Les données discrètes prennent des valeurs entières séparées (comptage). Les données continues prennent toute valeur dans un intervalle (mesure).',
    'definition_en': 'Discrete data take separate integer values (counting). Continuous data take any value within an interval (measurement).',
    'formula': 'Discret : X ∈ {0, 1, 2, ...}\nContinu : X ∈ [a, b]',
    'interpretation_fr': 'Le choix du graphique dépend du type : barres/camembert pour discrètes, histogramme/boxplot pour continues.',
    'interpretation_en': 'Chart choice depends on type: bar/pie for discrete, histogram/boxplot for continuous.',
    'remark_fr': 'Les données discrètes modélisées par des lois de probabilité : Bernoulli, Binomiale, Poisson.',
    'remark_en': 'Discrete data modeled by probability distributions: Bernoulli, Binomial, Poisson.',
    'example_fr': 'Discret : nombre d\'étudiants (0, 1, 2, ...)\nContinu : taille (1.65m, 1.72m, ...)',
    'example_en': 'Discrete: number of students (0, 1, 2, ...)\nContinuous: height (1.65m, 1.72m, ...)',
  },
  {
    'title_fr': 'Données groupées et en classes',
    'title_en': 'Grouped and Class Data',
    'subtitle_fr': 'Centre de classe, effectifs cumulés, ogive',
    'subtitle_en': 'Class midpoint, cumulative frequencies, ogive',
    'definition_fr': 'Les données groupées sont résumées par valeur + effectif. Les données en classes sont regroupées en intervalles.',
    'definition_en': 'Grouped data are summarized by value + frequency. Class data are grouped into intervals.',
    'formula': 'Centre de classe : cᵢ = (a + b) / 2\nEffectif cumulé : Fₖ = Σᵢ₌₁ᵏ nᵢ',
    'interpretation_fr': 'L\'effectif cumulé permet de construire l\'ogive, qui montre la croissance cumulée des effectifs.',
    'interpretation_en': 'Cumulative frequency allows building the ogive, which shows the cumulative growth of frequencies.',
    'remark_fr': 'Pour les données en classes, on utilise l\'interpolation pour estimer la médiane et les quantiles.',
    'remark_en': 'For class data, interpolation is used to estimate the median and quantiles.',
    'example_fr': 'Classes : [10;20[ → 5, [20;30[ → 8, [30;40[ → 12\nCentres : 15, 25, 35\nCumulés : 5, 13, 25',
    'example_en': 'Classes: [10;20[ → 5, [20;30[ → 8, [30;40[ → 12\nMidpoints: 15, 25, 35\nCumulative: 5, 13, 25',
  },
  {
    'title_fr': 'Loi normale',
    'title_en': 'Normal Distribution',
    'subtitle_fr': 'Propriétés, standardisation, table Z, règle 68-95-99.7',
    'subtitle_en': 'Properties, standardization, Z-table, 68-95-99.7 rule',
    'definition_fr': 'La loi normale est la distribution en cloche symétrique, la plus importante en statistiques. Elle est définie par sa moyenne μ et son écart-type σ.',
    'definition_en': 'The normal distribution is the symmetric bell-shaped curve, the most important in statistics. It is defined by its mean μ and standard deviation σ.',
    'formula': 'f(x) = (1/σ√2π) × e^(-(x-μ)²/2σ²)\nZ = (X − μ) / σ',
    'interpretation_fr': 'Règle 68-95-99.7 : 68% dans ±1σ, 95% dans ±2σ, 99.7% dans ±3σ. La transformation Z permet de comparer des distributions différentes.',
    'interpretation_en': '68-95-99.7 rule: 68% within ±1σ, 95% within ±2σ, 99.7% within ±3σ. Z-transformation allows comparing different distributions.',
    'remark_fr': 'Le théorème central limite justifie l\'usage de la normale : la moyenne de n\'importe quel échantillon suffisamment grand suit approximativement une loi normale.',
    'remark_en': 'The central limit theorem justifies using the normal: the mean of any sufficiently large sample approximately follows a normal distribution.',
    'example_fr': 'X ~ N(100, 15²)\nP(85 < X < 115) = P(-1 < Z < 1) ≈ 68%\nP(70 < X < 130) = P(-2 < Z < 2) ≈ 95%',
    'example_en': 'X ~ N(100, 15²)\nP(85 < X < 115) = P(-1 < Z < 1) ≈ 68%\nP(70 < X < 130) = P(-2 < Z < 2) ≈ 95%',
  },
  {
    'title_fr': 'Convergences',
    'title_en': 'Convergence Theorems',
    'subtitle_fr': 'Loi des grands nombres, théorème central limite',
    'subtitle_en': 'Law of large numbers, central limit theorem',
    'definition_fr': 'La loi des grands nombres dit que la moyenne empirique converge vers l\'espérance. Le TCL dit que la moyenne suit une loi normale pour n grand.',
    'definition_en': 'The law of large numbers states that the empirical mean converges to the expectation. The CLT states that the mean follows a normal distribution for large n.',
    'formula': 'LLN : X̄ₙ → E(X) quand n → ∞\nTCL : √n(X̄ₙ − μ)/σ → N(0,1)',
    'interpretation_fr': 'Plus on a de données, plus la moyenne est fiable (LLN). Peu importe la distribution d\'origine, la moyenne sera normale pour grand n (TCL).',
    'interpretation_en': 'The more data, the more reliable the mean (LLN). Regardless of the original distribution, the mean will be normal for large n (CLT).',
    'remark_fr': 'Le TCL est la base de tous les tests statistiques. C\'est pourquoi on peut utiliser des tests même si la distribution n\'est pas normale.',
    'remark_en': 'The CLT is the basis of all statistical tests. This is why tests can be used even if the distribution is not normal.',
    'example_fr': 'LLN : lancer un dé 1000 fois → moyenne ≈ 3.5\nTCL : la moyenne de 100 échantillons suit N(μ, σ²/100)',
    'example_en': 'LLN: rolling a die 1000 times → mean ≈ 3.5\nTCL: the mean of 100 samples follows N(μ, σ²/100)',
  },
];
