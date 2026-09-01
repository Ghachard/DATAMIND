from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
from services.inference import (
    confidence_interval, one_sample_t_test, two_sample_t_test, chi_square_test
)

router = APIRouter(prefix="/api/inference", tags=["Inférence"])


class CIInput(BaseModel):
    values: List[float]
    level: float = Field(0.95, description="Niveau de confiance (0.90, 0.95, 0.99)")


class OneSampleTInput(BaseModel):
    values: List[float]
    reference_value: float
    alpha: float = Field(0.05, description="Seuil de signification")


class TwoSampleTInput(BaseModel):
    sample1: List[float]
    sample2: List[float]
    alpha: float = Field(0.05, description="Seuil de signification")


class ChiSquareInput(BaseModel):
    observed: List[float]
    expected: List[float]
    alpha: float = Field(0.05, description="Seuil de signification")


@router.post("/confidence-interval")
def compute_ci(input: CIInput):
    if len(input.values) < 2:
        raise HTTPException(status_code=400, detail="Au moins 2 valeurs requises")
    if input.level not in [0.90, 0.95, 0.99]:
        raise HTTPException(status_code=400, detail="Niveau de confiance doit être 0.90, 0.95 ou 0.99")
    return confidence_interval(input.values, input.level)


@router.post("/t-test/one-sample")
def compute_one_sample_t(input: OneSampleTInput):
    if len(input.values) < 2:
        raise HTTPException(status_code=400, detail="Au moins 2 valeurs requises")
    return one_sample_t_test(input.values, input.reference_value, input.alpha)


@router.post("/t-test/two-sample")
def compute_two_sample_t(input: TwoSampleTInput):
    if len(input.sample1) < 2 or len(input.sample2) < 2:
        raise HTTPException(status_code=400, detail="Au moins 2 valeurs par échantillon requises")
    return two_sample_t_test(input.sample1, input.sample2, input.alpha)


@router.post("/chi-square")
def compute_chi_square(input: ChiSquareInput):
    if len(input.observed) != len(input.expected):
        raise HTTPException(status_code=400, detail="Les listes observées et attendues doivent avoir la même taille")
    if len(input.observed) < 2:
        raise HTTPException(status_code=400, detail="Au moins 2 catégories requises")
    return chi_square_test(input.observed, input.expected, input.alpha)
