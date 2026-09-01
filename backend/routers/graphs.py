from fastapi import APIRouter, HTTPException
from models.schemas import ChartInput
from services.graphs import generate_chart
from services.chart_data import get_chart_data

router = APIRouter(prefix="/api/graphs", tags=["Graphiques"])


@router.post("/generate")
def generate_graph(input: ChartInput):
    try:
        result = generate_chart(
            chart_type=input.chart_type,
            values=input.values,
            frequencies=input.frequencies,
            lower_bounds=input.lower_bounds,
            upper_bounds=input.upper_bounds,
            x=input.x,
            y=input.y,
            title=input.title,
            variable_name=input.variable_name,
            dark=True,
            data_nature=input.data_nature.value
        )
        return {
            "image_base64": result,
            "chart_type": input.chart_type,
            "title": input.title or f"Graphique {input.chart_type}"
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/data")
def get_chart_data_endpoint(input: ChartInput):
    try:
        result = get_chart_data(
            chart_type=input.chart_type,
            values=input.values,
            frequencies=input.frequencies,
            lower_bounds=input.lower_bounds,
            upper_bounds=input.upper_bounds,
            x=input.x,
            y=input.y,
            data_nature=input.data_nature.value,
        )
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/types")
def list_chart_types():
    return {
        "types": [
            {"id": "histogram", "name_fr": "Histogramme", "name_en": "Histogram", "data_types": ["simple", "grouped"], "data_natures": ["continuous"]},
            {"id": "boxplot", "name_fr": "Boîte à moustaches", "name_en": "Box plot", "data_types": ["simple"], "data_natures": ["continuous"]},
            {"id": "bar", "name_fr": "Barres", "name_en": "Bar chart", "data_types": ["simple", "grouped"], "data_natures": ["discrete", "continuous"]},
            {"id": "pie", "name_fr": "Camembert", "name_en": "Pie chart", "data_types": ["simple", "grouped"], "data_natures": ["discrete", "continuous"]},
            {"id": "scatter", "name_fr": "Nuage de points", "name_en": "Scatter plot", "data_types": ["bivariate"], "data_natures": ["discrete", "continuous"]},
            {"id": "histogram_classes", "name_fr": "Histogramme jointif", "name_en": "Class histogram", "data_types": ["class_interval"], "data_natures": ["continuous"]},
            {"id": "ogive", "name_fr": "Ogive", "name_en": "Ogive", "data_types": ["class_interval"], "data_natures": ["continuous"]},
            {"id": "polygone", "name_fr": "Polygone des effectifs", "name_en": "Frequency polygon", "data_types": ["grouped"], "data_natures": ["discrete"]},
            {"id": "normal_curve", "name_fr": "Courbe normale", "name_en": "Normal curve", "data_types": ["simple"], "data_natures": ["continuous"]},
            {"id": "violin", "name_fr": "Violon", "name_en": "Violin plot", "data_types": ["simple"], "data_natures": ["continuous"]},
            {"id": "qq_plot", "name_fr": "QQ-Plot", "name_en": "QQ-Plot", "data_types": ["simple"], "data_natures": ["continuous"]},
        ]
    }
