import numpy as np
from scipy import stats as scipy_stats
from typing import List, Dict, Any, Optional


def calculate_descriptive_simple(values: List[float], data_nature: str = "continuous") -> Dict[str, Any]:
    arr = np.array(values, dtype=float)
    n = len(arr)

    if n == 0:
        raise ValueError("La liste de valeurs est vide")

    mean_val = float(np.mean(arr))
    sorted_arr = np.sort(arr)

    if n % 2 == 0:
        median_val = float(np.median(arr))
    else:
        median_val = float(np.median(arr))

    mode_result = scipy_stats.mode(arr, keepdims=False)
    mode_val = float(mode_result.mode) if n > 1 else float(arr[0])

    variance_val = float(np.var(arr, ddof=0))
    std_dev_val = float(np.std(arr, ddof=0))
    range_val = float(np.max(arr) - np.min(arr))
    cv_val = float((std_dev_val / mean_val) * 100) if mean_val != 0 else 0.0

    q1 = float(np.percentile(arr, 25))
    q2 = float(np.percentile(arr, 50))
    q3 = float(np.percentile(arr, 75))
    iqr_val = float(q3 - q1)

    skewness_val = float(scipy_stats.skew(arr))
    kurtosis_val = float(scipy_stats.kurtosis(arr))

    lower_fence = q1 - 1.5 * iqr_val
    upper_fence = q3 + 1.5 * iqr_val
    outliers = [float(x) for x in arr if x < lower_fence or x > upper_fence]

    z_scores = [(float(x) - mean_val) / std_dev_val if std_dev_val != 0 else 0.0 for x in arr]
    z_outliers = [float(arr[i]) for i in range(n) if abs(z_scores[i]) > 2.5]
    all_outliers = list(set(outliers + z_outliers))

    sem_val = float(std_dev_val / np.sqrt(n)) if n > 0 else 0.0

    is_normal = False
    normality_p_value = 0.0
    if 3 <= n <= 5000:
        try:
            shapiro_stat, shapiro_p = scipy_stats.shapiro(arr)
            is_normal = shapiro_p > 0.05
            normality_p_value = round(float(shapiro_p), 6)
        except Exception:
            pass

    return {
        "n": n,
        "mean": round(mean_val, 6),
        "median": round(median_val, 6),
        "mode": round(mode_val, 6),
        "variance": round(variance_val, 6),
        "std_dev": round(std_dev_val, 6),
        "range": round(range_val, 6),
        "cv": round(cv_val, 4),
        "q1": round(q1, 6),
        "q2": round(q2, 6),
        "q3": round(q3, 6),
        "iqr": round(iqr_val, 6),
        "skewness": round(skewness_val, 6),
        "kurtosis": round(kurtosis_val, 6),
        "min_val": round(float(np.min(arr)), 6),
        "max_val": round(float(np.max(arr)), 6),
        "sum": round(float(np.sum(arr)), 6),
        "sem": round(sem_val, 6),
        "outliers": [round(x, 6) for x in all_outliers],
        "z_scores": [round(z, 4) for z in z_scores],
        "is_normal": is_normal,
        "normality_p_value": normality_p_value,
        "data_type": "simple",
        "data_nature": data_nature
    }


def calculate_descriptive_grouped(values: List[float], frequencies: List[int], data_nature: str = "continuous") -> Dict[str, Any]:
    arr = np.array(values, dtype=float)
    freq = np.array(frequencies, dtype=int)

    if len(arr) != len(freq):
        raise ValueError("Les listes valeurs et effectifs doivent avoir la même taille")

    n = int(np.sum(freq))

    if n == 0:
        raise ValueError("L'effectif total est nul")

    mean_val = float(np.sum(arr * freq) / n)

    cumulative = np.cumsum(freq)
    median_pos = n / 2
    median_idx = int(np.searchsorted(cumulative, median_pos))
    median_idx = min(median_idx, len(arr) - 1)

    if median_idx > 0 and cumulative[median_idx - 1] < median_pos <= cumulative[median_idx]:
        f_med = freq[median_idx]
        F_before = cumulative[median_idx - 1]
        if f_med > 0 and median_idx < len(arr) - 1:
            fraction = (median_pos - F_before) / f_med
            median_val = float(arr[median_idx] + fraction * (arr[min(median_idx + 1, len(arr) - 1)] - arr[median_idx]))
        else:
            median_val = float(arr[median_idx])
    else:
        median_val = float(arr[median_idx])

    mode_idx = int(np.argmax(freq))
    mode_val = float(arr[mode_idx])

    variance_val = float(np.sum(freq * (arr - mean_val) ** 2) / n)
    std_dev_val = float(np.sqrt(variance_val))
    range_val = float(np.max(arr) - np.min(arr))
    cv_val = float((std_dev_val / mean_val) * 100) if mean_val != 0 else 0.0

    q1_pos = n / 4
    q3_pos = 3 * n / 4

    def interpolate_grouped_quantile(pos):
        idx = int(np.searchsorted(cumulative, pos))
        idx = min(idx, len(arr) - 1)
        if idx > 0 and cumulative[idx - 1] < pos <= cumulative[idx]:
            f_q = freq[idx]
            F_before_q = cumulative[idx - 1]
            if f_q > 0 and idx < len(arr) - 1:
                frac = (pos - F_before_q) / f_q
                return float(arr[idx] + frac * (arr[min(idx + 1, len(arr) - 1)] - arr[idx]))
            return float(arr[idx])
        return float(arr[idx])

    q1 = interpolate_grouped_quantile(q1_pos)
    q3 = interpolate_grouped_quantile(q3_pos)
    q2 = median_val
    iqr_val = float(q3 - q1)

    return {
        "n": n,
        "mean": round(mean_val, 6),
        "median": round(median_val, 6),
        "mode": round(mode_val, 6),
        "variance": round(variance_val, 6),
        "std_dev": round(std_dev_val, 6),
        "range": round(range_val, 6),
        "cv": round(cv_val, 4),
        "q1": round(q1, 6),
        "q2": round(q2, 6),
        "q3": round(q3, 6),
        "iqr": round(iqr_val, 6),
        "min_val": round(float(np.min(arr)), 6),
        "max_val": round(float(np.max(arr)), 6),
        "sum": round(float(np.sum(arr * freq)), 6),
        "effective_total": n,
        "outliers": [],
        "data_nature": data_nature
    }


def calculate_descriptive_classes(lower_bounds: List[float], upper_bounds: List[float],
                                   frequencies: List[int], data_nature: str = "continuous") -> Dict[str, Any]:
    lower = np.array(lower_bounds, dtype=float)
    upper = np.array(upper_bounds, dtype=float)
    freq = np.array(frequencies, dtype=int)

    if not (len(lower) == len(upper) == len(freq)):
        raise ValueError("Les listes bornes inférieures, supérieures et effectifs doivent avoir la même taille")

    midpoints = (lower + upper) / 2
    n = int(np.sum(freq))

    if n == 0:
        raise ValueError("L'effectif total est nul")

    mean_val = float(np.sum(midpoints * freq) / n)

    cumulative = np.cumsum(freq)
    median_class_idx = np.searchsorted(cumulative, n / 2)
    median_class_idx = min(median_class_idx, len(lower) - 1)

    L = lower[median_class_idx]
    F = cumulative[median_class_idx - 1] if median_class_idx > 0 else 0
    f = freq[median_class_idx]
    h = upper[median_class_idx] - lower[median_class_idx]
    median_val = float(L + ((n / 2 - F) / f) * h) if f > 0 else float(L + h / 2)

    mode_class_idx = int(np.argmax(freq))
    mode_val = float(midpoints[mode_class_idx])

    variance_val = float(np.sum(freq * (midpoints - mean_val) ** 2) / n)
    std_dev_val = float(np.sqrt(variance_val))
    range_val = float(np.max(upper) - np.min(lower))
    cv_val = float((std_dev_val / mean_val) * 100) if mean_val != 0 else 0.0

    q1_pos = n / 4
    q3_pos = 3 * n / 4
    q1_class_idx = min(np.searchsorted(cumulative, q1_pos), len(lower) - 1)
    q3_class_idx = min(np.searchsorted(cumulative, q3_pos), len(lower) - 1)

    def interpolate_quantile(idx, pos):
        L_q = lower[idx]
        F_q = cumulative[idx - 1] if idx > 0 else 0
        f_q = freq[idx]
        h_q = upper[idx] - lower[idx]
        return float(L_q + ((pos - F_q) / f_q) * h_q) if f_q > 0 else float(L_q + h_q / 2)

    q1 = interpolate_quantile(q1_class_idx, q1_pos)
    q3 = interpolate_quantile(q3_class_idx, q3_pos)
    q2 = median_val
    iqr_val = float(q3 - q1)

    return {
        "n": n,
        "mean": round(mean_val, 6),
        "median": round(median_val, 6),
        "mode": round(mode_val, 6),
        "variance": round(variance_val, 6),
        "std_dev": round(std_dev_val, 6),
        "range": round(range_val, 6),
        "cv": round(cv_val, 4),
        "q1": round(q1, 6),
        "q2": round(q2, 6),
        "q3": round(q3, 6),
        "iqr": round(iqr_val, 6),
        "min_val": round(float(np.min(lower)), 6),
        "max_val": round(float(np.max(upper)), 6),
        "sum": round(float(np.sum(midpoints * freq)), 6),
        "effective_total": n,
        "class_midpoints": [round(float(m), 6) for m in midpoints],
        "cumulative_freq": [int(c) for c in cumulative],
        "outliers": [],
        "data_nature": data_nature
    }


def calculate_bivariate(x: List[float], y: List[float], data_nature: str = "continuous") -> Dict[str, Any]:
    arr_x = np.array(x, dtype=float)
    arr_y = np.array(y, dtype=float)

    if len(arr_x) != len(arr_y):
        raise ValueError("Les listes X et Y doivent avoir la même taille")

    n = len(arr_x)
    if n < 2:
        raise ValueError("Au moins 2 paires de données nécessaires")

    mean_x = float(np.mean(arr_x))
    mean_y = float(np.mean(arr_y))
    std_x = float(np.std(arr_x, ddof=0))
    std_y = float(np.std(arr_y, ddof=0))

    covariance = float(np.sum((arr_x - mean_x) * (arr_y - mean_y)) / n)
    pearson_r = float(covariance / (std_x * std_y)) if (std_x * std_y) != 0 else 0.0
    r_squared = float(pearson_r ** 2)

    slope = float(covariance / (std_x ** 2)) if std_x != 0 else 0.0
    intercept = float(mean_y - slope * mean_x)

    if abs(pearson_r) >= 0.8:
        strength = "très forte"
    elif abs(pearson_r) >= 0.6:
        strength = "forte"
    elif abs(pearson_r) >= 0.4:
        strength = "modérée"
    elif abs(pearson_r) >= 0.2:
        strength = "faible"
    else:
        strength = "très faible"

    direction = "positive" if pearson_r > 0 else "négative" if pearson_r < 0 else "nulle"

    interpretation = (
        f"Corrélation {strength} {direction} (r = {pearson_r:.4f}). "
        f"R² = {r_squared:.4f} → {r_squared*100:.1f}% de la variance de Y est expliquée par X. "
        f"Équation de la droite : ŷ = {slope:.4f}x + {intercept:.4f}"
    )

    return {
        "n": n,
        "mean_x": round(mean_x, 6),
        "mean_y": round(mean_y, 6),
        "std_x": round(std_x, 6),
        "std_y": round(std_y, 6),
        "covariance": round(covariance, 6),
        "pearson_r": round(pearson_r, 6),
        "r_squared": round(r_squared, 6),
        "regression_slope": round(slope, 6),
        "regression_intercept": round(intercept, 6),
        "interpretation": interpretation,
        "data_nature": data_nature
    }
