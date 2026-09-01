from fastapi import APIRouter, HTTPException
from fastapi.responses import Response
from models.schemas import PDFExportInput
from services.descriptive import (
    calculate_descriptive_simple, calculate_descriptive_grouped,
    calculate_descriptive_classes, calculate_bivariate
)
from services.interpretation import generate_full_interpretation
from services.graphs import generate_chart
from services.pdf_generator import generate_pdf_report

router = APIRouter(prefix="/api/export", tags=["Export PDF"])


@router.post("/pdf")
def export_pdf(input: PDFExportInput):
    try:
        stats = None
        interpretation = ""
        charts_b64 = []

        if input.data_type == "simple" and input.values:
            stats = calculate_descriptive_simple(input.values, data_nature=input.data_nature)
            interpretation = generate_full_interpretation(stats, "simple")
            if input.include_charts:
                charts_b64.append(generate_chart("histogram", values=input.values,
                                                  variable_name=input.variable_name, dark=False))
                charts_b64.append(generate_chart("boxplot", values=input.values,
                                                  variable_name=input.variable_name, dark=False))

        elif input.data_type == "grouped" and input.values and input.frequencies:
            stats = calculate_descriptive_grouped(input.values, input.frequencies, data_nature=input.data_nature)
            interpretation = generate_full_interpretation(stats, "grouped")
            if input.include_charts:
                charts_b64.append(generate_chart("bar", values=input.values,
                                                  variable_name=input.variable_name, dark=False))
                charts_b64.append(generate_chart("polygone", values=input.values,
                                                  frequencies=input.frequencies,
                                                  variable_name=input.variable_name, dark=False))

        elif input.data_type == "class_interval" and input.lower_bounds and input.upper_bounds and input.frequencies:
            stats = calculate_descriptive_classes(input.lower_bounds, input.upper_bounds, input.frequencies, data_nature=input.data_nature)
            interpretation = generate_full_interpretation(stats, "classes")
            if input.include_charts:
                charts_b64.append(generate_chart("histogram_classes", lower_bounds=input.lower_bounds,
                                                  upper_bounds=input.upper_bounds,
                                                  frequencies=input.frequencies,
                                                  variable_name=input.variable_name, dark=False))
                charts_b64.append(generate_chart("ogive", lower_bounds=input.lower_bounds,
                                                  upper_bounds=input.upper_bounds,
                                                  frequencies=input.frequencies,
                                                  variable_name=input.variable_name, dark=False))

        elif input.data_type == "bivariate" and input.x and input.y:
            stats = calculate_bivariate(input.x, input.y, data_nature=input.data_nature)
            interpretation = generate_full_interpretation(stats, "bivariate")
            if input.include_charts:
                charts_b64.append(generate_chart("scatter", x=input.x, y=input.y,
                                                  variable_name=input.variable_name, dark=False))

        else:
            raise HTTPException(status_code=400, detail="Données insuffisantes pour le type sélectionné")

        if not input.include_interpretation:
            interpretation = ""

        pdf_bytes = generate_pdf_report(
            data_type=input.data_type,
            variable_name=input.variable_name or "Variable",
            stats=stats,
            charts_base64=charts_b64 if input.include_charts else [],
            interpretation=interpretation,
            title=input.title or "Rapport statistique DataMind"
        )

        from datetime import datetime
        filename = f"DataMind_{input.variable_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"

        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={"Content-Disposition": f'attachment; filename="{filename}"'}
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur génération PDF : {str(e)}")
