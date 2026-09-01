from fastapi import APIRouter, HTTPException
from models.schemas import (
    SimpleDataInput, GroupedDataInput, ClassIntervalDataInput, BivariateDataInput
)
from services.descriptive import (
    calculate_descriptive_simple, calculate_descriptive_grouped,
    calculate_descriptive_classes, calculate_bivariate
)
from services.interpretation import generate_full_interpretation
from db.database import get_db, save_analysis, get_recent_analyses, delete_old_analyses
from uuid import uuid4

router = APIRouter(prefix="/api/stats", tags=["Statistiques"])


@router.post("/descriptive/simple")
def descriptive_simple(data: SimpleDataInput):
    if len(data.values) < 2:
        raise HTTPException(status_code=400, detail="Au moins 2 valeurs requises")

    result = calculate_descriptive_simple(data.values, data.data_nature.value)
    interpretation = generate_full_interpretation(result, "simple")

    db = next(get_db())
    analysis_id = str(uuid4())
    save_analysis(db, analysis_id, "simple", data.variable_name, data.values, result)
    delete_old_analyses(db, keep=5)
    db.close()

    return {
        "analysis_id": analysis_id,
        "data_type": "simple",
        "variable_name": data.variable_name,
        "stats": result,
        "interpretation": interpretation
    }


@router.post("/descriptive/grouped")
def descriptive_grouped(data: GroupedDataInput):
    if len(data.values) < 1:
        raise HTTPException(status_code=400, detail="Au moins 1 valeur requise")
    if len(data.values) != len(data.frequencies):
        raise HTTPException(status_code=400, detail="Les listes valeurs et effectifs doivent avoir la même taille")

    result = calculate_descriptive_grouped(data.values, data.frequencies, data.data_nature.value)
    interpretation = generate_full_interpretation(result, "grouped")

    db = next(get_db())
    analysis_id = str(uuid4())
    save_analysis(db, analysis_id, "grouped", data.variable_name, data.values, result,
                  frequencies=data.frequencies)
    delete_old_analyses(db, keep=5)
    db.close()

    return {
        "analysis_id": analysis_id,
        "data_type": "grouped",
        "variable_name": data.variable_name,
        "stats": result,
        "interpretation": interpretation
    }


@router.post("/descriptive/classes")
def descriptive_classes(data: ClassIntervalDataInput):
    if len(data.lower_bounds) < 2:
        raise HTTPException(status_code=400, detail="Au moins 2 classes requises")
    if not (len(data.lower_bounds) == len(data.upper_bounds) == len(data.frequencies)):
        raise HTTPException(status_code=400, detail="Les listes bornes et effectifs doivent avoir la même taille")

    result = calculate_descriptive_classes(data.lower_bounds, data.upper_bounds, data.frequencies, data.data_nature.value)
    interpretation = generate_full_interpretation(result, "classes")

    db = next(get_db())
    analysis_id = str(uuid4())
    save_analysis(db, analysis_id, "classes", data.variable_name, [], result,
                  frequencies=data.frequencies, lower_bounds=data.lower_bounds,
                  upper_bounds=data.upper_bounds)
    delete_old_analyses(db, keep=5)
    db.close()

    return {
        "analysis_id": analysis_id,
        "data_type": "class_interval",
        "variable_name": data.variable_name,
        "stats": result,
        "interpretation": interpretation
    }


@router.post("/descriptive/bivariate")
def descriptive_bivariate(data: BivariateDataInput):
    if len(data.x) < 2:
        raise HTTPException(status_code=400, detail="Au moins 2 paires de données requises")
    if len(data.x) != len(data.y):
        raise HTTPException(status_code=400, detail="Les listes X et Y doivent avoir la même taille")

    result = calculate_bivariate(data.x, data.y, data.data_nature.value)
    interpretation = generate_full_interpretation(result, "bivariate")

    db = next(get_db())
    analysis_id = str(uuid4())
    save_analysis(db, analysis_id, "bivariate", f"{data.x_name} / {data.y_name}",
                  data.x, result, y=data.y)
    delete_old_analyses(db, keep=5)
    db.close()

    return {
        "analysis_id": analysis_id,
        "data_type": "bivariate",
        "variable_name": f"{data.x_name} / {data.y_name}",
        "stats": result,
        "interpretation": interpretation
    }


@router.get("/history")
def get_history():
    db = next(get_db())
    items = get_recent_analyses(db, limit=5)
    db.close()
    return {
        "history": [
            {
                "id": item.id,
                "data_type": item.data_type,
                "variable_name": item.variable_name,
                "created_at": item.created_at.isoformat(),
                "result_summary": item.result_summary
            }
            for item in items
        ]
    }
