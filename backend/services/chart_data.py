from typing import List, Dict, Any, Optional
import numpy as np
from scipy import stats as scipy_stats


def histogram_data(values: List[float], data_nature: str = "continuous") -> Dict[str, Any]:
    arr = np.array(values)
    if data_nature == "discrete":
        unique_vals = sorted(np.unique(arr).tolist())
        counts = [int(np.sum(arr == v)) for v in unique_vals]
        return {
            "chart_type": "bar",
            "labels": [str(v) for v in unique_vals],
            "values": counts,
            "title": "Histogramme",
            "x_label": "Valeurs",
            "y_label": "Fréquence",
            "mean": round(float(np.mean(arr)), 4),
        }
    else:
        n_bins = min(20, max(5, int(np.sqrt(len(arr)))))
        mn, mx = float(np.min(arr)), float(np.max(arr))
        bin_width = (mx - mn) / n_bins
        bins_edges = [round(mn + i * bin_width, 4) for i in range(n_bins + 1)]
        counts = [0] * n_bins
        for v in arr:
            idx = min(int((v - mn) / bin_width), n_bins - 1)
            counts[idx] += 1
        labels = [f"{bins_edges[i]:.1f}-{bins_edges[i+1]:.1f}" for i in range(n_bins)]
        return {
            "chart_type": "bar",
            "labels": labels,
            "values": counts,
            "title": "Histogramme",
            "x_label": "Classes",
            "y_label": "Fréquence",
            "mean": round(float(np.mean(arr)), 4),
            "bins_edges": bins_edges,
        }


def bar_data(values: List[float], frequencies: Optional[List[int]] = None) -> Dict[str, Any]:
    if frequencies:
        labels = [str(v) for v in values]
        vals = frequencies
    else:
        unique_vals = sorted(set(values))
        labels = [str(v) for v in unique_vals]
        vals = [int(values.count(v)) for v in unique_vals]
    return {
        "chart_type": "bar",
        "labels": labels,
        "values": vals,
        "title": "Barres",
        "x_label": "Catégories",
        "y_label": "Effectif",
    }


def pie_data(values: List[float], frequencies: Optional[List[int]] = None) -> Dict[str, Any]:
    if frequencies:
        labels = [str(v) for v in values]
        vals = frequencies
    else:
        unique_vals = sorted(set(values))
        labels = [str(v) for v in unique_vals]
        vals = [int(values.count(v)) for v in unique_vals]
    total = sum(vals)
    return {
        "chart_type": "pie",
        "labels": labels,
        "values": vals,
        "percentages": [round(v / total * 100, 1) for v in vals],
        "title": "Camembert",
    }


def scatter_data(x: List[float], y: List[float]) -> Dict[str, Any]:
    arr_x, arr_y = np.array(x), np.array(y)
    mx, my = float(np.mean(arr_x)), float(np.mean(arr_y))
    sx, sy = float(np.std(arr_x)), float(np.std(arr_y))
    cov = float(np.sum((arr_x - mx) * (arr_y - my)) / len(arr_x))
    r = cov / (sx * sy) if sx * sy != 0 else 0
    slope = cov / (sx ** 2) if sx != 0 else 0
    intercept = my - slope * mx
    x_min, x_max = float(np.min(arr_x)), float(np.max(arr_x))
    return {
        "chart_type": "scatter",
        "points": [{"x": float(x[i]), "y": float(y[i])} for i in range(len(x))],
        "regression": {
            "x_min": x_min,
            "x_max": x_max,
            "y_start": round(slope * x_min + intercept, 4),
            "y_end": round(slope * x_max + intercept, 4),
            "equation": f"ŷ = {slope:.2f}x + {intercept:.2f}",
            "r": round(r, 4),
            "r_squared": round(r ** 2, 4),
        },
        "title": "Nuage de points",
        "x_label": "X",
        "y_label": "Y",
    }


def boxplot_data(values: List[float]) -> Dict[str, Any]:
    arr = np.array(values)
    q1 = float(np.percentile(arr, 25))
    q2 = float(np.percentile(arr, 50))
    q3 = float(np.percentile(arr, 75))
    iqr = q3 - q1
    lower_fence = q1 - 1.5 * iqr
    upper_fence = q3 + 1.5 * iqr
    mn = float(np.min(arr))
    mx = float(np.max(arr))
    whisker_low = max(mn, lower_fence)
    whisker_high = min(mx, upper_fence)
    outliers = sorted([float(v) for v in arr if v < lower_fence or v > upper_fence])
    return {
        "chart_type": "boxplot",
        "min": round(whisker_low, 4),
        "q1": round(q1, 4),
        "median": round(q2, 4),
        "q3": round(q3, 4),
        "max": round(whisker_high, 4),
        "iqr": round(iqr, 4),
        "outliers": [round(o, 4) for o in outliers],
        "mean": round(float(np.mean(arr)), 4),
        "title": "Boîte à moustaches",
    }


def normal_curve_data(values: List[float]) -> Dict[str, Any]:
    arr = np.array(values)
    mu = float(np.mean(arr))
    sigma = float(np.std(arr))
    if sigma == 0:
        return {"chart_type": "line", "points": [], "title": "Courbe normale"}
    x_min = mu - 4 * sigma
    x_max = mu + 4 * sigma
    n_points = 200
    xs = np.linspace(x_min, x_max, n_points).tolist()
    ys = scipy_stats.norm.pdf(xs, mu, sigma).tolist()
    return {
        "chart_type": "line",
        "points": [{"x": round(x, 4), "y": round(y, 6)} for x, y in zip(xs, ys)],
        "mu": round(mu, 4),
        "sigma": round(sigma, 4),
        "zones": [
            {"from": round(mu - sigma, 4), "to": round(mu + sigma, 4), "label": "68%", "color": "#00E676"},
            {"from": round(mu - 2 * sigma, 4), "to": round(mu + 2 * sigma, 4), "label": "95%", "color": "#FFB300"},
        ],
        "title": f"Courbe normale (μ={mu:.2f}, σ={sigma:.2f})",
        "x_label": "Valeurs",
        "y_label": "Densité",
    }


def ogive_data(lower_bounds: List[float], upper_bounds: List[float], frequencies: List[int]) -> Dict[str, Any]:
    cumulative = []
    total = 0
    for f in frequencies:
        total += f
        cumulative.append(total)
    all_x = [lower_bounds[0]] + upper_bounds
    all_y = [0] + cumulative
    return {
        "chart_type": "line",
        "points": [{"x": round(x, 4), "y": y} for x, y in zip(all_x, all_y)],
        "title": "Ogive (effectifs cumulés)",
        "x_label": "Valeurs",
        "y_label": "Effectifs cumulés",
        "cumulative": cumulative,
    }


def polygon_data(values: List[float], frequencies: List[int]) -> Dict[str, Any]:
    points = [{"x": round(v, 4), "y": f} for v, f in zip(values, frequencies)]
    return {
        "chart_type": "line",
        "points": points,
        "title": "Polygone des effectifs",
        "x_label": "Valeurs",
        "y_label": "Effectifs",
    }


def histogram_classes_data(lower_bounds: List[float], upper_bounds: List[float], frequencies: List[int]) -> Dict[str, Any]:
    labels = [f"{lower_bounds[i]:.0f}-{upper_bounds[i]:.0f}" for i in range(len(lower_bounds))]
    return {
        "chart_type": "bar",
        "labels": labels,
        "values": frequencies,
        "title": "Histogramme jointif",
        "x_label": "Classes",
        "y_label": "Effectifs",
        "lower_bounds": lower_bounds,
        "upper_bounds": upper_bounds,
    }


def violin_data(values: List[float]) -> Dict[str, Any]:
    arr = np.array(values)
    mu = float(np.mean(arr))
    sigma = float(np.std(arr))
    q1 = float(np.percentile(arr, 25))
    q2 = float(np.percentile(arr, 50))
    q3 = float(np.percentile(arr, 75))
    return {
        "chart_type": "violin",
        "mu": round(mu, 4),
        "sigma": round(sigma, 4),
        "q1": round(q1, 4),
        "median": round(q2, 4),
        "q3": round(q3, 4),
        "min": round(float(np.min(arr)), 4),
        "max": round(float(np.max(arr)), 4),
        "title": "Violon",
    }


def get_chart_data(chart_type: str, values=None, frequencies=None,
                   lower_bounds=None, upper_bounds=None, x=None, y=None,
                   data_nature="continuous", **kwargs) -> Dict[str, Any]:
    dispatch = {
        "histogram": lambda: histogram_data(values, data_nature),
        "bar": lambda: bar_data(values, frequencies),
        "pie": lambda: pie_data(values, frequencies),
        "scatter": lambda: scatter_data(x, y),
        "boxplot": lambda: boxplot_data(values),
        "normal_curve": lambda: normal_curve_data(values),
        "ogive": lambda: ogive_data(lower_bounds, upper_bounds, frequencies),
        "polygone": lambda: polygon_data(values, frequencies),
        "histogram_classes": lambda: histogram_classes_data(lower_bounds, upper_bounds, frequencies),
        "violin": lambda: violin_data(values),
    }
    if chart_type not in dispatch:
        raise ValueError(f"Type inconnu: {chart_type}")
    return dispatch[chart_type]()
