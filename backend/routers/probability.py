from fastapi import APIRouter, HTTPException
from models.schemas import ProbabilityInput
from services.probability import calculate_probability

router = APIRouter(prefix="/api/probability", tags=["Probabilités"])


@router.post("/calculate")
def compute_probability(input: ProbabilityInput):
    try:
        result = calculate_probability(
            law=input.law,
            params=input.params,
            x=input.x,
            x_min=input.x_min,
            x_max=input.x_max
        )
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"Paramètre manquant : {e}")


@router.get("/laws")
def list_laws():
    return {
        "laws": [
            {
                "id": "bernoulli",
                "name_fr": "Bernoulli",
                "name_en": "Bernoulli",
                "params": ["p"],
                "type": "discrete",
                "description_fr": "Expérience aléatoire à deux issues (succès/échec)",
                "description_en": "Random experiment with two outcomes (success/failure)"
            },
            {
                "id": "binomial",
                "name_fr": "Binomiale",
                "name_en": "Binomial",
                "params": ["n", "p"],
                "type": "discrete",
                "description_fr": "Nombre de succès dans n expériences de Bernoulli indépendantes",
                "description_en": "Number of successes in n independent Bernoulli trials"
            },
            {
                "id": "poisson",
                "name_fr": "Poisson",
                "name_en": "Poisson",
                "params": ["lambda"],
                "type": "discrete",
                "description_fr": "Nombre d'événements rares dans un intervalle donné",
                "description_en": "Number of rare events in a given interval"
            },
            {
                "id": "normal",
                "name_fr": "Normale",
                "name_en": "Normal",
                "params": ["mu", "sigma"],
                "type": "continuous",
                "description_fr": "Distribution en cloche, la plus utilisée en statistiques",
                "description_en": "Bell-shaped distribution, the most used in statistics"
            },
            {
                "id": "uniform",
                "name_fr": "Uniforme",
                "name_en": "Uniform",
                "params": ["a", "b"],
                "type": "continuous",
                "description_fr": "Probabilité constante sur un intervalle [a, b]",
                "description_en": "Constant probability over an interval [a, b]"
            },
            {
                "id": "chi2",
                "name_fr": "Chi²",
                "name_en": "Chi-squared",
                "params": ["k"],
                "type": "continuous",
                "description_fr": "Distribution du chi-carré, utilisée pour les tests statistiques",
                "description_en": "Chi-squared distribution, used for statistical tests"
            }
        ]
    }
