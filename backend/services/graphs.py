import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
from scipy import stats as scipy_stats
import base64
from io import BytesIO
from typing import List, Optional


def fig_to_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return img_base64


def setup_style(dark: bool = True):
    if dark:
        plt.rcParams.update({
            'figure.facecolor': '#0A1628',
            'axes.facecolor': '#0F1F3D',
            'axes.edgecolor': '#1A6FD4',
            'axes.labelcolor': '#FFFFFF',
            'text.color': '#FFFFFF',
            'xtick.color': '#CCCCCC',
            'ytick.color': '#CCCCCC',
            'grid.color': '#1A3A5C',
            'grid.alpha': 0.3,
            'font.size': 11,
        })
    else:
        plt.rcParams.update({
            'figure.facecolor': '#FFFFFF',
            'axes.facecolor': '#F8F9FA',
            'axes.edgecolor': '#333333',
            'axes.labelcolor': '#333333',
            'text.color': '#333333',
            'xtick.color': '#555555',
            'ytick.color': '#555555',
            'grid.color': '#E0E0E0',
            'grid.alpha': 0.5,
            'font.size': 11,
        })


def histogram(values: List[float], title: str = "Histogramme", dark: bool = True, data_nature: str = "continuous") -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    arr = np.array(values)
    n_bins = min(20, max(5, int(np.sqrt(len(arr)))))
    
    if data_nature == "discrete":
        unique_vals = np.unique(arr)
        counts = [np.sum(arr == v) for v in unique_vals]
        ax.bar(unique_vals, counts, color='#1A6FD4', edgecolor='#0A1628', alpha=0.85, width=0.8)
    else:
        ax.hist(arr, bins=n_bins, color='#1A6FD4', edgecolor='#0A1628', alpha=0.85)
    
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_xlabel("Valeurs")
    ax.set_ylabel("Fréquence")
    ax.grid(True, axis='y')
    mean_val = np.mean(arr)
    ax.axvline(mean_val, color='#00C8FF', linestyle='--', linewidth=2, label=f'Moyenne = {mean_val:.2f}')
    ax.legend()
    return fig_to_base64(fig)


def boxplot(values: List[float], title: str = "Boîte à moustaches", dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    bp = ax.boxplot(values, patch_artist=True, vert=True,
                    boxprops=dict(facecolor='#1A6FD4', color='#00C8FF'),
                    whiskerprops=dict(color='#00C8FF'),
                    capprops=dict(color='#00C8FF'),
                    medianprops=dict(color='#00E676', linewidth=2),
                    flierprops=dict(marker='o', markerfacecolor='#FF5252', markersize=8))
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_ylabel("Valeurs")
    ax.grid(True, axis='y')
    return fig_to_base64(fig)


def bar_chart(values: List[float], labels: Optional[List[str]] = None,
              title: str = "Diagramme en barres", dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    if labels is None:
        labels = [str(i + 1) for i in range(len(values))]
    colors = ['#1A6FD4', '#00C8FF', '#00E676', '#AA00FF', '#FFB300', '#FF5252']
    bar_colors = [colors[i % len(colors)] for i in range(len(values))]
    ax.bar(labels, values, color=bar_colors, edgecolor='#0A1628', alpha=0.85)
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_ylabel("Effectif")
    ax.grid(True, axis='y')
    for i, v in enumerate(values):
        ax.text(i, v + max(values) * 0.01, str(v), ha='center', va='bottom', fontweight='bold')
    return fig_to_base64(fig)


def pie_chart(values: List[float], labels: Optional[List[str]] = None,
              title: str = "Diagramme en camembert", dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    if labels is None:
        labels = [f"Cat. {i + 1}" for i in range(len(values))]
    colors = ['#1A6FD4', '#00C8FF', '#00E676', '#AA00FF', '#FFB300', '#FF5252']
    wedges, texts, autotexts = ax.pie(values, labels=labels, autopct='%1.1f%%',
                                       colors=colors[:len(values)], startangle=90,
                                       textprops={'color': 'white'})
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    return fig_to_base64(fig)


def scatter_plot(x: List[float], y: List[float], title: str = "Nuage de points",
                 show_regression: bool = True, dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.scatter(x, y, c='#00C8FF', s=50, alpha=0.7, edgecolors='#1A6FD4')
    if show_regression and len(x) > 1:
        arr_x, arr_y = np.array(x), np.array(y)
        slope, intercept = np.polyfit(arr_x, arr_y, 1)
        x_line = np.linspace(min(x), max(x), 100)
        y_line = slope * x_line + intercept
        ax.plot(x_line, y_line, color='#FF5252', linewidth=2, linestyle='--',
                label=f'ŷ = {slope:.2f}x + {intercept:.2f}')
        ax.legend()
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.grid(True)
    return fig_to_base64(fig)


def histogram_classes(lower_bounds: List[float], upper_bounds: List[float],
                      frequencies: List[int], title: str = "Histogramme jointif",
                      dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    for i in range(len(lower_bounds)):
        ax.bar(lower_bounds[i], frequencies[i], width=upper_bounds[i] - lower_bounds[i],
               align='edge', color='#1A6FD4', edgecolor='#0A1628', alpha=0.85)
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_xlabel("Classes")
    ax.set_ylabel("Effectifs")
    ax.grid(True, axis='y')
    return fig_to_base64(fig)


def ogive(lower_bounds: List[float], upper_bounds: List[float],
          frequencies: List[int], title: str = "Ogive (effectifs cumulés)",
          dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    upper = np.array(upper_bounds)
    cumulative = np.cumsum(frequencies)
    all_points = np.concatenate(([lower_bounds[0]], upper))
    all_cum = np.concatenate(([0], cumulative))
    ax.plot(all_points, all_cum, color='#00C8FF', marker='o', linewidth=2, markersize=6)
    ax.fill_between(all_points, all_cum, alpha=0.2, color='#00C8FF')
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_xlabel("Valeurs")
    ax.set_ylabel("Effectifs cumulés")
    ax.grid(True)
    return fig_to_base64(fig)


def frequency_polygon(values: List[float], frequencies: List[int],
                      title: str = "Polygone des effectifs", dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(values, frequencies, color='#00C8FF', marker='o', linewidth=2, markersize=8)
    ax.fill_between(values, frequencies, alpha=0.2, color='#00C8FF')
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_xlabel("Valeurs")
    ax.set_ylabel("Effectifs")
    ax.grid(True)
    return fig_to_base64(fig)


def normal_curve(mu: float, sigma: float, title: str = "Courbe normale",
                 shade_region: bool = True, dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    x = np.linspace(mu - 4 * sigma, mu + 4 * sigma, 500)
    y = scipy_stats.norm.pdf(x, mu, sigma)
    ax.plot(x, y, color='#00C8FF', linewidth=2)
    if shade_region:
        x_68 = np.linspace(mu - sigma, mu + sigma, 200)
        ax.fill_between(x_68, scipy_stats.norm.pdf(x_68, mu, sigma), alpha=0.3, color='#00E676', label='68%')
        x_95 = np.linspace(mu - 2 * sigma, mu + 2 * sigma, 200)
        ax.fill_between(x_95, scipy_stats.norm.pdf(x_95, mu, sigma), alpha=0.15, color='#FFB300', label='95%')
        ax.legend()
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_xlabel("Valeurs")
    ax.set_ylabel("Densité")
    ax.grid(True)
    ax.axvline(mu, color='#FF5252', linestyle='--', linewidth=1.5, alpha=0.7)
    return fig_to_base64(fig)


def violin_plot(values: List[float], title: str = "Violon", dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.violinplot(values, showmeans=True, showmedians=True)
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.set_ylabel("Valeurs")
    ax.grid(True, axis='y')
    return fig_to_base64(fig)


def qq_plot(values: List[float], title: str = "QQ-Plot", dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))
    arr = np.array(values)
    scipy_stats.probplot(arr, dist="norm", plot=ax)
    ax.get_lines()[0].set_markerfacecolor('#00C8FF')
    ax.get_lines()[0].set_markeredgecolor('#1A6FD4')
    ax.get_lines()[1].set_color('#FF5252')
    ax.set_title(title, fontsize=14, fontweight='bold', pad=15)
    ax.grid(True)
    return fig_to_base64(fig)


def law_distribution(law: str, params: dict, x_range: Optional[List[float]] = None,
                     shade_x: Optional[List[float]] = None, dark: bool = True) -> str:
    setup_style(dark)
    fig, ax = plt.subplots(figsize=(8, 5))

    if law == "normal":
        mu, sigma = params["mu"], params["sigma"]
        x = np.linspace(mu - 4 * sigma, mu + 4 * sigma, 500)
        y = scipy_stats.norm.pdf(x, mu, sigma)
        label = f'N({mu}, {sigma}²)'
    elif law == "uniform":
        a, b = params["a"], params["b"]
        x = np.linspace(a - 1, b + 1, 500)
        y = np.where((x >= a) & (x <= b), 1 / (b - a), 0)
        label = f'U({a}, {b})'
    elif law == "chi2":
        k = params["k"]
        x = np.linspace(0.01, k + 4 * np.sqrt(2 * k), 500)
        y = scipy_stats.chi2.pdf(x, df=k)
        label = f'χ²({k})'
    elif law == "binomial":
        n, p = params["n"], params["p"]
        x = np.arange(0, n + 1)
        y = scipy_stats.binom.pmf(x, n, p)
        ax.bar(x, y, color='#1A6FD4', edgecolor='#0A1628', alpha=0.85)
        ax.set_title(f'Loi binomiale B({n}, {p})', fontsize=14, fontweight='bold', pad=15)
        ax.set_xlabel("k")
        ax.set_ylabel("P(X = k)")
        ax.grid(True, axis='y')
        if shade_x:
            shade_vals = [int(s) for s in shade_x if 0 <= int(s) <= n]
            ax.bar(shade_vals, [scipy_stats.binom.pmf(s, n, p) for s in shade_vals],
                   color='#FF5252', edgecolor='#0A1628', alpha=0.85, label='Zone sélectionnée')
            ax.legend()
        return fig_to_base64(fig)
    elif law == "poisson":
        lam = params["lambda"]
        x_max = max(int(lam + 4 * np.sqrt(lam)), 20)
        x = np.arange(0, x_max + 1)
        y = scipy_stats.poisson.pmf(x, lam)
        ax.bar(x, y, color='#1A6FD4', edgecolor='#0A1628', alpha=0.85)
        ax.set_title(f'Loi de Poisson P({lam})', fontsize=14, fontweight='bold', pad=15)
        ax.set_xlabel("k")
        ax.set_ylabel("P(X = k)")
        ax.grid(True, axis='y')
        if shade_x:
            shade_vals = [int(s) for s in shade_x if 0 <= int(s) <= x_max]
            ax.bar(shade_vals, [scipy_stats.poisson.pmf(s, lam) for s in shade_vals],
                   color='#FF5252', edgecolor='#0A1628', alpha=0.85, label='Zone sélectionnée')
            ax.legend()
        return fig_to_base64(fig)
    elif law == "bernoulli":
        p = params["p"]
        ax.bar([0, 1], [1 - p, p], color=['#1A6FD4', '#00E676'], edgecolor='#0A1628', alpha=0.85)
        ax.set_xticks([0, 1])
        ax.set_xticklabels(['Échec (0)', 'Succès (1)'])
        ax.set_title(f'Loi de Bernoulli (p = {p})', fontsize=14, fontweight='bold', pad=15)
        ax.set_ylabel("Probabilité")
        ax.grid(True, axis='y')
        return fig_to_base64(fig)
    else:
        raise ValueError(f"Loi inconnue: {law}")

    ax.plot(x, y, color='#00C8FF', linewidth=2, label=label)
    ax.fill_between(x, y, alpha=0.2, color='#00C8FF')

    if shade_x and len(shade_x) == 2:
        x_shade = np.linspace(shade_x[0], shade_x[1], 200)
        if law == "normal":
            y_shade = scipy_stats.norm.pdf(x_shade, mu, sigma)
        elif law == "uniform":
            y_shade = np.where((x_shade >= a) & (x_shade <= b), 1 / (b - a), 0)
        elif law == "chi2":
            y_shade = scipy_stats.chi2.pdf(x_shade, df=k)
        ax.fill_between(x_shade, y_shade, alpha=0.4, color='#FF5252', label='Zone sélectionnée')
        ax.legend()

    ax.set_title(f'Loi {law}', fontsize=14, fontweight='bold', pad=15)
    ax.set_xlabel("Valeurs")
    ax.set_ylabel("Densité / Probabilité")
    ax.grid(True)
    return fig_to_base64(fig)


def generate_chart(chart_type: str, values=None, frequencies=None,
                   lower_bounds=None, upper_bounds=None, x=None, y=None,
                   title=None, variable_name="Variable", dark=True, 
                   data_nature="continuous", **kwargs) -> str:
    chart_map = {
        "histogram": lambda: histogram(values, title or f"Histogramme de {variable_name}", dark, data_nature),
        "boxplot": lambda: boxplot(values, title or f"Boîte à moustaches de {variable_name}", dark),
        "bar": lambda: bar_chart(values, title=f"Barres de {variable_name}", dark=dark),
        "pie": lambda: pie_chart(values, title=f"Camembert de {variable_name}", dark=dark),
        "scatter": lambda: scatter_plot(x, y, title or "Nuage de points", dark=dark),
        "histogram_classes": lambda: histogram_classes(lower_bounds, upper_bounds, frequencies,
                                                        title or "Histogramme jointif", dark),
        "ogive": lambda: ogive(lower_bounds, upper_bounds, frequencies,
                                title or "Ogive", dark),
        "polygone": lambda: frequency_polygon(values, frequencies,
                                               title or "Polygone des effectifs", dark),
        "normal_curve": lambda: normal_curve(
            kwargs.get("mu", np.mean(values) if values else 0),
            kwargs.get("sigma", np.std(values) if values else 1),
            title or "Courbe normale", dark=dark),
        "violin": lambda: violin_plot(values, title or "Violon", dark),
        "qq_plot": lambda: qq_plot(values, title or "QQ-Plot", dark),
    }

    if chart_type not in chart_map:
        raise ValueError(f"Type de graphique inconnu: {chart_type}")

    return chart_map[chart_type]()
