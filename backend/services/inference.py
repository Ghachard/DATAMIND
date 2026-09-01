import numpy as np
from scipy import stats as scipy_stats
from typing import List, Dict, Any, Optional


def confidence_interval(values: List[float], level: float = 0.95) -> Dict[str, Any]:
    arr = np.array(values, dtype=float)
    n = len(arr)
    mean_val = float(np.mean(arr))
    std_val = float(np.std(arr, ddof=1))
    sem = std_val / np.sqrt(n)

    z_map = {0.90: 1.645, 0.95: 1.96, 0.99: 2.576}
    z = z_map.get(level, 1.96)

    margin = z * sem
    lower = mean_val - margin
    upper = mean_val + margin

    level_pct = int(level * 100)
    interpretation = (
        f"Interval de confiance à {level_pct}% : [{lower:.4f} ; {upper:.4f}]. "
        f"Nous sommes {level_pct}% confiants que la vraie moyenne de la population "
        f"se situe entre {lower:.4f} et {upper:.4f}. "
        f"Erreur marginale : ±{margin:.4f}"
    )

    return {
        "level": level,
        "mean": round(mean_val, 6),
        "lower": round(lower, 6),
        "upper": round(upper, 6),
        "margin_of_error": round(margin, 6),
        "std_dev": round(std_val, 6),
        "sem": round(sem, 6),
        "n": n,
        "interpretation": interpretation
    }


def one_sample_t_test(values: List[float], reference_value: float, alpha: float = 0.05) -> Dict[str, Any]:
    arr = np.array(values, dtype=float)
    n = len(arr)
    mean_val = float(np.mean(arr))
    std_val = float(np.std(arr, ddof=1))
    sem = std_val / np.sqrt(n)

    t_stat = (mean_val - reference_value) / sem if sem != 0 else 0.0
    df = n - 1
    p_value = float(2 * (1 - scipy_stats.t.cdf(abs(t_stat), df=df)))
    t_critical = float(scipy_stats.t.ppf(1 - alpha / 2, df=df))

    reject_null = p_value < alpha

    if reject_null:
        interpretation = (
            f"Test t de Student (1 échantillon) : t = {t_stat:.4f}, p = {p_value:.6f}. "
            f"On rejette H₀ au seuil {alpha}. La moyenne ({mean_val:.4f}) "
            f"est significativement différente de {reference_value}."
        )
    else:
        interpretation = (
            f"Test t de Student (1 échantillon) : t = {t_stat:.4f}, p = {p_value:.6f}. "
            f"On ne rejette pas H₀ au seuil {alpha}. Pas de différence significative "
            f"avec la valeur de référence {reference_value}."
        )

    return {
        "test_name": "Test t de Student (1 échantillon)",
        "statistic": round(t_stat, 6),
        "p_value": round(p_value, 6),
        "critical_value": round(t_critical, 6),
        "degrees_of_freedom": df,
        "reject_null": reject_null,
        "alpha": alpha,
        "mean": round(mean_val, 6),
        "reference_value": reference_value,
        "interpretation": interpretation
    }


def two_sample_t_test(sample1: List[float], sample2: List[float], alpha: float = 0.05) -> Dict[str, Any]:
    arr1 = np.array(sample1, dtype=float)
    arr2 = np.array(sample2, dtype=float)

    n1, n2 = len(arr1), len(arr2)
    mean1, mean2 = float(np.mean(arr1)), float(np.mean(arr2))
    std1 = float(np.std(arr1, ddof=1))
    std2 = float(np.std(arr2, ddof=1))

    var1, var2 = std1 ** 2, std2 ** 2
    pooled_std = np.sqrt((var1 / n1) + (var2 / n2))
    t_stat = (mean1 - mean2) / pooled_std if pooled_std != 0 else 0.0

    numerator = ((var1 / n1) + (var2 / n2)) ** 2
    denominator = ((var1 / n1) ** 2 / (n1 - 1)) + ((var2 / n2) ** 2 / (n2 - 1))
    df = int(numerator / denominator) if denominator != 0 else n1 + n2 - 2

    p_value = float(2 * (1 - scipy_stats.t.cdf(abs(t_stat), df=df)))
    t_critical = float(scipy_stats.t.ppf(1 - alpha / 2, df=df))

    reject_null = p_value < alpha

    diff = abs(mean1 - mean2)
    if reject_null:
        interpretation = (
            f"Test t de Student (2 échantillons) : t = {t_stat:.4f}, p = {p_value:.6f}. "
            f"On rejette H₀ au seuil {alpha}. Les moyennes ({mean1:.4f} vs {mean2:.4f}) "
            f"sont significativement différentes (diff = {diff:.4f})."
        )
    else:
        interpretation = (
            f"Test t de Student (2 échantillons) : t = {t_stat:.4f}, p = {p_value:.6f}. "
            f"On ne rejette pas H₀ au seuil {alpha}. Pas de différence significative "
            f"entre les moyennes ({mean1:.4f} vs {mean2:.4f})."
        )

    return {
        "test_name": "Test t de Student (2 échantillons)",
        "statistic": round(t_stat, 6),
        "p_value": round(p_value, 6),
        "critical_value": round(t_critical, 6),
        "degrees_of_freedom": df,
        "reject_null": reject_null,
        "alpha": alpha,
        "mean1": round(mean1, 6),
        "mean2": round(mean2, 6),
        "diff": round(diff, 6),
        "interpretation": interpretation
    }


def chi_square_test(observed: List[float], expected: List[float], alpha: float = 0.05) -> Dict[str, Any]:
    obs = np.array(observed, dtype=float)
    exp = np.array(expected, dtype=float)

    if len(obs) != len(exp):
        raise ValueError("Les listes observées et attendues doivent avoir la même taille")

    if np.any(exp == 0):
        raise ValueError("Les effectifs attendus ne doivent pas être nuls")

    chi2_stat = float(np.sum((obs - exp) ** 2 / exp))
    df = len(obs) - 1
    p_value = float(1 - scipy_stats.chi2.cdf(chi2_stat, df=df))
    chi2_critical = float(scipy_stats.chi2.ppf(1 - alpha, df=df))

    reject_null = p_value < alpha

    if reject_null:
        interpretation = (
            f"Test du Chi² : χ² = {chi2_stat:.4f}, p = {p_value:.6f}. "
            f"On rejette H₀ au seuil {alpha}. Les distributions observée et attendue "
            f"sont significativement différentes."
        )
    else:
        interpretation = (
            f"Test du Chi² : χ² = {chi2_stat:.4f}, p = {p_value:.6f}. "
            f"On ne rejette pas H₀ au seuil {alpha}. Pas de différence significative "
            f"entre les distributions observée et attendue."
        )

    return {
        "test_name": "Test du Chi²",
        "statistic": round(chi2_stat, 6),
        "p_value": round(p_value, 6),
        "critical_value": round(chi2_critical, 6),
        "degrees_of_freedom": df,
        "reject_null": reject_null,
        "alpha": alpha,
        "observed": [round(float(x), 6) for x in obs],
        "expected": [round(float(x), 6) for x in exp],
        "interpretation": interpretation
    }
