import numpy as np
from scipy import stats as scipy_stats
from math import comb, exp, factorial
from typing import Dict, Any, Optional


def bernoulli(p: float, x: Optional[float] = None,
              x_min: Optional[float] = None, x_max: Optional[float] = None) -> Dict[str, Any]:
    if not 0 <= p <= 1:
        raise ValueError("La probabilité p doit être entre 0 et 1")

    result = {"law": "Bernoulli", "params": {"p": p}, "mean": p, "variance": p * (1 - p),
              "std_dev": float(np.sqrt(p * (1 - p)))}

    if x is not None:
        x_int = int(x)
        if x_int == 1:
            result["p_equal"] = p
        elif x_int == 0:
            result["p_equal"] = 1 - p
        else:
            result["p_equal"] = 0.0

    if x is not None:
        x_int = int(x)
        result["p_less_equal"] = 1 - p if x_int >= 1 else (1 - p if x_int == 0 else 0.0)

    if x_min is not None and x_max is not None:
        result["p_interval"] = p if 1 >= x_min and 1 <= x_max else (1 - p if 0 >= x_min and 0 <= x_max else 0.0)

    if "p_equal" in result:
        result["interpretation"] = f"P(X = {x}) = {result['p_equal']:.6f}"
    elif "p_less_equal" in result:
        result["interpretation"] = f"P(X ≤ {x}) = {result['p_less_equal']:.6f}"
    elif "p_interval" in result:
        result["interpretation"] = f"P({x_min} ≤ X ≤ {x_max}) = {result['p_interval']:.6f}"
    else:
        result["interpretation"] = f"Bernoulli(p={p}): Espérance={p}, Variance={p*(1-p):.4f}"

    return result


def binomial(n: int, p: float, x: Optional[float] = None,
             x_min: Optional[float] = None, x_max: Optional[float] = None) -> Dict[str, Any]:
    if n <= 0:
        raise ValueError("Le nombre d'essais n doit être positif")
    if not 0 <= p <= 1:
        raise ValueError("La probabilité p doit être entre 0 et 1")

    result = {"law": "Binomiale", "params": {"n": n, "p": p},
              "mean": n * p, "variance": n * p * (1 - p),
              "std_dev": float(np.sqrt(n * p * (1 - p)))}

    if x is not None:
        k = int(x)
        if 0 <= k <= n:
            result["p_equal"] = float(comb(n, k) * (p ** k) * ((1 - p) ** (n - k)))
        else:
            result["p_equal"] = 0.0

    if x is not None:
        k = int(x)
        result["p_less_equal"] = float(sum(
            comb(n, i) * (p ** i) * ((1 - p) ** (n - i)) for i in range(min(k + 1, n + 1))
        ))

    if x_min is not None and x_max is not None:
        a = int(x_min)
        b = int(x_max)
        result["p_interval"] = float(sum(
            comb(n, i) * (p ** i) * ((1 - p) ** (n - i)) for i in range(max(a, 0), min(b, n) + 1)
        ))

    if "p_equal" in result:
        result["interpretation"] = f"P(X = {x}) = {result['p_equal']:.6f}"
    elif "p_less_equal" in result:
        result["interpretation"] = f"P(X ≤ {x}) = {result['p_less_equal']:.6f}"
    elif "p_interval" in result:
        result["interpretation"] = f"P({x_min} ≤ X ≤ {x_max}) = {result['p_interval']:.6f}"
    else:
        result["interpretation"] = f"Binomiale(n={n}, p={p}): Espérance={n*p}, Variance={n*p*(1-p):.4f}"

    return result


def poisson(lam: float, x: Optional[float] = None,
            x_min: Optional[float] = None, x_max: Optional[float] = None) -> Dict[str, Any]:
    if lam <= 0:
        raise ValueError("Le paramètre λ doit être positif")

    result = {"law": "Poisson", "params": {"lambda": lam},
              "mean": lam, "variance": lam, "std_dev": float(np.sqrt(lam))}

    if x is not None:
        k = int(x)
        if k >= 0:
            result["p_equal"] = float((lam ** k) * exp(-lam) / factorial(k))
        else:
            result["p_equal"] = 0.0

    if x is not None:
        k = int(x)
        result["p_less_equal"] = float(sum(
            (lam ** i) * exp(-lam) / factorial(i) for i in range(max(k + 1, 0))
        ))

    if x_min is not None and x_max is not None:
        a = max(int(x_min), 0)
        b = int(x_max)
        result["p_interval"] = float(sum(
            (lam ** i) * exp(-lam) / factorial(i) for i in range(a, b + 1)
        ))

    if "p_equal" in result:
        result["interpretation"] = f"P(X = {x}) = {result['p_equal']:.6f}"
    elif "p_less_equal" in result:
        result["interpretation"] = f"P(X ≤ {x}) = {result['p_less_equal']:.6f}"
    elif "p_interval" in result:
        result["interpretation"] = f"P({x_min} ≤ X ≤ {x_max}) = {result['p_interval']:.6f}"
    else:
        result["interpretation"] = f"Poisson(λ={lam}): Espérance={lam}, Variance={lam}"

    return result


def normal(mu: float, sigma: float, x: Optional[float] = None,
           x_min: Optional[float] = None, x_max: Optional[float] = None) -> Dict[str, Any]:
    if sigma <= 0:
        raise ValueError("L'écart-type σ doit être positif")

    result = {"law": "Normale", "params": {"mu": mu, "sigma": sigma},
              "mean": mu, "variance": sigma ** 2, "std_dev": sigma}

    if x is not None:
        z = (x - mu) / sigma
        result["p_equal"] = float(scipy_stats.norm.pdf(x, loc=mu, scale=sigma))

    if x is not None:
        result["p_less_equal"] = float(scipy_stats.norm.cdf(x, loc=mu, scale=sigma))

    if x_min is not None and x_max is not None:
        result["p_interval"] = float(
            scipy_stats.norm.cdf(x_max, loc=mu, scale=sigma) -
            scipy_stats.norm.cdf(x_min, loc=mu, scale=sigma)
        )

    if "p_equal" in result:
        z = (x - mu) / sigma
        result["interpretation"] = f"P(X = {x}) = {result['p_equal']:.6f} (densité), z = {z:.4f}"
    elif "p_less_equal" in result:
        z = (x - mu) / sigma
        result["interpretation"] = f"P(X ≤ {x}) = {result['p_less_equal']:.6f}, z = {z:.4f}"
    elif "p_interval" in result:
        result["interpretation"] = f"P({x_min} ≤ X ≤ {x_max}) = {result['p_interval']:.6f}"
    else:
        result["interpretation"] = f"Normale(μ={mu}, σ={sigma}): 68-95-99.7% dans ±1-2-3σ"

    return result


def uniform(a: float, b: float, x: Optional[float] = None,
            x_min: Optional[float] = None, x_max: Optional[float] = None) -> Dict[str, Any]:
    if a >= b:
        raise ValueError("Le paramètre a doit être strictement inférieur à b")

    result = {"law": "Uniforme", "params": {"a": a, "b": b},
              "mean": (a + b) / 2, "variance": ((b - a) ** 2) / 12,
              "std_dev": float((b - a) / np.sqrt(12))}

    if x is not None:
        if a <= x <= b:
            result["p_equal"] = 1 / (b - a)
        else:
            result["p_equal"] = 0.0

    if x is not None:
        if x < a:
            result["p_less_equal"] = 0.0
        elif x >= b:
            result["p_less_equal"] = 1.0
        else:
            result["p_less_equal"] = (x - a) / (b - a)

    if x_min is not None and x_max is not None:
        overlap_start = max(x_min, a)
        overlap_end = min(x_max, b)
        if overlap_start < overlap_end:
            result["p_interval"] = (overlap_end - overlap_start) / (b - a)
        else:
            result["p_interval"] = 0.0

    if "p_equal" in result:
        result["interpretation"] = f"P(X = {x}) = {result['p_equal']:.6f} (densité)"
    elif "p_less_equal" in result:
        result["interpretation"] = f"P(X ≤ {x}) = {result['p_less_equal']:.6f}"
    elif "p_interval" in result:
        result["interpretation"] = f"P({x_min} ≤ X ≤ {x_max}) = {result['p_interval']:.6f}"
    else:
        result["interpretation"] = f"Uniforme(a={a}, b={b}): Espérance={(a+b)/2}, Variance={(b-a)**2/12:.4f}"

    return result


def chi2_distribution(k: int, x: Optional[float] = None,
                      x_min: Optional[float] = None, x_max: Optional[float] = None) -> Dict[str, Any]:
    if k <= 0:
        raise ValueError("Le nombre de degrés de liberté k doit être positif")

    result = {"law": "Chi²", "params": {"k": k},
              "mean": float(k), "variance": float(2 * k), "std_dev": float(np.sqrt(2 * k))}

    if x is not None:
        if x >= 0:
            result["p_equal"] = float(scipy_stats.chi2.pdf(x, df=k))
        else:
            result["p_equal"] = 0.0

    if x is not None:
        if x >= 0:
            result["p_less_equal"] = float(scipy_stats.chi2.cdf(x, df=k))
        else:
            result["p_less_equal"] = 0.0

    if x_min is not None and x_max is not None:
        x_min_pos = max(x_min, 0)
        result["p_interval"] = float(
            scipy_stats.chi2.cdf(x_max, df=k) - scipy_stats.chi2.cdf(x_min_pos, df=k)
        )

    if "p_equal" in result:
        result["interpretation"] = f"P(X = {x}) = {result['p_equal']:.6f} (densité)"
    elif "p_less_equal" in result:
        result["interpretation"] = f"P(X ≤ {x}) = {result['p_less_equal']:.6f}"
    elif "p_interval" in result:
        result["interpretation"] = f"P({x_min} ≤ X ≤ {x_max}) = {result['p_interval']:.6f}"
    else:
        result["interpretation"] = f"Chi²(k={k}): Espérance={k}, Variance={2*k}"

    return result


def calculate_probability(law: str, params: dict, x=None, x_min=None, x_max=None) -> Dict[str, Any]:
    law_map = {
        "bernoulli": lambda: bernoulli(params["p"], x, x_min, x_max),
        "binomial": lambda: binomial(params["n"], params["p"], x, x_min, x_max),
        "poisson": lambda: poisson(params["lambda"], x, x_min, x_max),
        "normal": lambda: normal(params["mu"], params["sigma"], x, x_min, x_max),
        "uniform": lambda: uniform(params["a"], params["b"], x, x_min, x_max),
        "chi2": lambda: chi2_distribution(params["k"], x, x_min, x_max),
    }

    if law not in law_map:
        raise ValueError(f"Loi inconnue : {law}. Lois disponibles : {list(law_map.keys())}")

    return law_map[law]()
