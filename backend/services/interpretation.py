from typing import Dict, Any


def interpret_mean(mean: float, context: str = "") -> str:
    return (
        f"La moyenne arithmétique est {mean:.4f}. "
        f"C'est la valeur centrale obtenue en sommant toutes les valeurs et en divisant par le nombre d'observations. "
        f"Elle représente le point d'équilibre de la distribution."
    )


def interpret_median(median: float) -> str:
    return (
        f"La médiane est {median:.4f}. "
        f"C'est la valeur qui divise la distribution en deux parties égales : "
        f"50% des observations sont inférieures et 50% sont supérieures. "
        f"Contrairement à la moyenne, elle est robuste aux valeurs extrêmes."
    )


def interpret_mode(mode: float) -> str:
    return (
        f"Le mode est {mode:.4f}. "
        f"C'est la valeur qui apparaît le plus fréquemment dans la distribution. "
        f"Elle représente le pic de la distribution."
    )


def interpret_variance(variance: float, std_dev: float) -> str:
    cv_interpretation = ""
    return (
        f"La variance est {variance:.4f} et l'écart-type est {std_dev:.4f}. "
        f"L'écart-type mesure la dispersion moyenne des valeurs par rapport à la moyenne. "
        f"Plus l'écart-type est grand, plus les données sont dispersées."
    )


def interpret_cv(cv: float) -> str:
    if cv < 15:
        level = "faible"
        quality = "les données sont homogènes"
    elif cv < 30:
        level = "modéré"
        quality = "les données sont modérément dispersées"
    else:
        level = "élevé"
        quality = "les données sont hétérogènes"
    return (
        f"Le coefficient de variation est {cv:.2f}%. "
        f"C'est un niveau {level} de dispersion. "
        f"Cela signifie que {quality}."
    )


def interpret_quartiles(q1: float, q2: float, q3: float, iqr: float) -> str:
    return (
        f"Les quartiles sont Q1={q1:.4f}, Q2={q2:.4f}, Q3={q3:.4f}. "
        f"L'écart interquartile IQR = Q3 - Q1 = {iqr:.4f}. "
        f"Il contient 50% central de la distribution. "
        f"Les valeurs en dehors de [Q1 - 1.5×IQR ; Q3 + 1.5×IQR] sont considérées comme aberrantes."
    )


def interpret_skewness(skewness: float) -> str:
    if abs(skewness) < 0.5:
        shape = "approximativement symétrique"
    elif skewness > 0:
        shape = "asymétrique à droite (queue vers la droite)"
    else:
        shape = "asymétrique à gauche (queue vers la gauche)"
    return (
        f"L'asymétrie (skewness) est {skewness:.4f}. "
        f"La distribution est {shape}."
    )


def interpret_kurtosis(kurtosis: float) -> str:
    if abs(kurtosis) < 0.5:
        shape = "mésocurtique (proche de la normale)"
    elif kurtosis > 0:
        shape = "leptocurtique (pic plus pointu, queues lourdes)"
    else:
        shape = "platycurtic (pic aplati, queues légères)"
    return (
        f"L'aplatissement (kurtosis) est {kurtosis:.4f}. "
        f"La distribution est {shape}."
    )


def interpret_outliers(outliers: list) -> str:
    if not outliers:
        return "Aucune valeur aberrante détectée."
    vals = ", ".join([f"{x:.4f}" for x in outliers[:5]])
    more = f" et {len(outliers) - 5} autres" if len(outliers) > 5 else ""
    return (
        f"{len(outliers)} valeur(s) aberrante(s) détectée(s) : {vals}{more}. "
        f"Ces valeurs sont significativement éloignées du reste de la distribution."
    )


def interpret_normality(is_normal: bool, p_value: float) -> str:
    if is_normal:
        return (
            f"Le test de Shapiro-Wilk donne une p-valeur de {p_value:.4f} (> 0.05). "
            f"On ne rejette pas l'hypothèse de normalité. "
            f"Les données suivent approximativement une loi normale. "
            f"Vous pouvez utiliser la courbe normale pour visualiser la distribution."
        )
    else:
        return (
            f"Le test de Shapiro-Wilk donne une p-valeur de {p_value:.4f} (≤ 0.05). "
            f"On rejette l'hypothèse de normalité. "
            f"Les données ne suivent pas une loi normale. "
            f"La courbe normale n'est pas appropriée pour cette distribution."
        )


def interpret_correlation(r: float) -> str:
    r_abs = abs(r)
    if r_abs >= 0.8:
        strength = "très forte"
    elif r_abs >= 0.6:
        strength = "forte"
    elif r_abs >= 0.4:
        strength = "modérée"
    elif r_abs >= 0.2:
        strength = "faible"
    else:
        strength = "très faible"

    direction = "positive" if r > 0 else "négative" if r < 0 else "nulle"

    if r_abs >= 0.8:
        quality = "La régression linéaire est très fiable."
    elif r_abs >= 0.6:
        quality = "La régression linéaire est fiable."
    elif r_abs >= 0.4:
        quality = "La régression linéaire est modérément fiable."
    else:
        quality = "La régression linéaire n'est pas fiable."

    return (
        f"La corrélation est {strength} et {direction} (r = {r:.4f}). "
        f"{quality}"
    )


def interpret_regression(slope: float, intercept: float, r_squared: float) -> str:
    return (
        f"La droite de régression est ŷ = {slope:.4f}x + {intercept:.4f}. "
        f"R² = {r_squared:.4f} signifie que {r_squared*100:.1f}% de la variance de Y "
        f"est expliquée par X. "
        f"Pour chaque unité supplémentaire de X, Y varie en moyenne de {slope:.4f}."
    )


def interpret_test_result(result: Dict[str, Any]) -> str:
    return result.get("interpretation", "Interprétation non disponible")


def interpret_confidence_interval(result: Dict[str, Any]) -> str:
    return result.get("interpretation", "Interprétation non disponible")


def interpret_data_nature(data_nature: str) -> str:
    if data_nature == "discrete":
        return (
            "Les données sont de nature discrète (valeurs entières, dénombrables). "
            "Pour ce type de données, le mode est une mesure de tendance centrale particulièrement pertinente. "
            "Les histogrammes doivent avoir des barres séparées. "
            "Les lois de probabilité appropriées sont : Bernoulli, Binomiale, Poisson, Chi². "
            "La courbe normale n'est applicable qu'en approximation pour de grands échantillons."
        )
    else:
        return (
            "Les données sont de nature continue (toute valeur dans un intervalle). "
            "Pour ce type de données, la médiane est souvent préférée au mode comme mesure de tendance centrale. "
            "Les histogrammes doivent avoir des barres jointes. "
            "Les lois de probabilité appropriées sont : Normale, Uniforme. "
            "La courbe normale est directement applicable."
        )


def generate_full_interpretation(stats: Dict[str, Any], data_type: str = "simple") -> str:
    sections = []

    if "data_nature" in stats:
        sections.append(interpret_data_nature(stats["data_nature"]))
    if "mean" in stats:
        sections.append(interpret_mean(stats["mean"]))
    if "median" in stats:
        sections.append(interpret_median(stats["median"]))
    if "mode" in stats:
        sections.append(interpret_mode(stats["mode"]))
    if "variance" in stats and "std_dev" in stats:
        sections.append(interpret_variance(stats["variance"], stats["std_dev"]))
    if "cv" in stats:
        sections.append(interpret_cv(stats["cv"]))
    if "q1" in stats:
        sections.append(interpret_quartiles(stats["q1"], stats["q2"], stats["q3"], stats["iqr"]))
    if "skewness" in stats:
        sections.append(interpret_skewness(stats["skewness"]))
    if "kurtosis" in stats:
        sections.append(interpret_kurtosis(stats["kurtosis"]))
    if "outliers" in stats:
        sections.append(interpret_outliers(stats["outliers"]))
    if "is_normal" in stats:
        sections.append(interpret_normality(stats["is_normal"], stats.get("normality_p_value", 0.0)))
    if "pearson_r" in stats:
        sections.append(interpret_correlation(stats["pearson_r"]))
    if "regression_slope" in stats:
        sections.append(interpret_regression(
            stats["regression_slope"], stats["regression_intercept"], stats["r_squared"]
        ))

    return "\n\n".join(sections)
