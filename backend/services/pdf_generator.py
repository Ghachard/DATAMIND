from fpdf import FPDF
from typing import Dict, Any, List, Optional
from datetime import datetime
import os


class DataMindPDF(FPDF):
    def header(self):
        self.set_font('Helvetica', 'B', 10)
        self.set_text_color(26, 111, 212)
        self.cell(0, 6, 'ISPM - Institut Superieur Polytechnique de Madagascar', align='C', new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(26, 111, 212)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(4)

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(150, 150, 150)
        self.cell(0, 10, f'DataMind v2.0 - Rapport genere le {datetime.now().strftime("%d/%m/%Y a %H:%M")}', align='C')


def generate_pdf_report(data_type: str, variable_name: str, stats: Dict[str, Any],
                        charts_base64: List[str] = None, interpretation: str = "",
                        title: str = "Rapport statistique DataMind") -> bytes:
    pdf = DataMindPDF()
    pdf.set_auto_page_break(auto=True, margin=20)
    pdf.add_page()

    pdf.set_font('Helvetica', 'B', 18)
    pdf.set_text_color(30, 30, 30)
    pdf.cell(0, 12, title, align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)

    pdf.set_font('Helvetica', '', 11)
    pdf.set_text_color(100, 100, 100)
    data_nature = stats.get('data_nature', 'continuous')
    nature_label = 'Discret' if data_nature == 'discrete' else 'Continu'
    pdf.cell(0, 8, f'Variable: {variable_name}  |  Type: {data_type}  |  Nature: {nature_label}', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.ln(8)

    pdf.set_font('Helvetica', 'B', 14)
    pdf.set_text_color(26, 111, 212)
    pdf.cell(0, 10, 'Statistiques descriptives', new_x="LMARGIN", new_y="NEXT")
    pdf.set_draw_color(26, 111, 212)
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(4)

    stat_labels = {
        "n": "Effectif (n)",
        "mean": "Moyenne",
        "median": "Mediane",
        "mode": "Mode",
        "variance": "Variance",
        "std_dev": "Ecart-type",
        "range": "Etendue",
        "cv": "CV (%)",
        "q1": "Q1",
        "q2": "Q2 (Mediane)",
        "q3": "Q3",
        "iqr": "IQR",
        "min_val": "Minimum",
        "max_val": "Maximum",
        "sum": "Somme",
        "skewness": "Asymetrie",
        "kurtosis": "Aplatissement",
        "sem": "Erreur std",
        "pearson_r": "r de Pearson",
        "r_squared": "R2",
        "covariance": "Covariance",
        "regression_slope": "Pente (a)",
        "regression_intercept": "ordonnee (b)",
    }

    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(30, 30, 30)

    col_width = 95
    row_height = 7
    items = [(k, v) for k, v in stats.items()
             if k in stat_labels and k not in ('outliers', 'z_scores', 'class_midpoints', 'cumulative_freq', 'is_normal', 'normality_p_value', 'data_type')]

    for i in range(0, len(items), 2):
        key1, val1 = items[i]
        pdf.set_font('Helvetica', '', 10)
        pdf.set_fill_color(240, 245, 255)
        pdf.cell(col_width, row_height, f'  {stat_labels[key1]}', border=1, fill=(i % 2 == 0))
        pdf.set_font('Helvetica', 'B', 10)
        pdf.cell(col_width, row_height, f'  {val1}', border=1, fill=(i % 2 == 0), new_x="LMARGIN", new_y="NEXT")

        if i + 1 < len(items):
            key2, val2 = items[i + 1]
            pdf.set_font('Helvetica', '', 10)
            pdf.cell(col_width, row_height, f'  {stat_labels[key2]}', border=1, fill=(i % 2 == 0))
            pdf.set_font('Helvetica', 'B', 10)
            pdf.cell(col_width, row_height, f'  {val2}', border=1, fill=(i % 2 == 0), new_x="LMARGIN", new_y="NEXT")

    if 'outliers' in stats and stats['outliers']:
        pdf.ln(4)
        pdf.set_font('Helvetica', 'B', 11)
        pdf.set_text_color(255, 82, 82)
        pdf.cell(0, 8, f'Valeurs aberrantes detectees: {stats["outliers"]}', new_x="LMARGIN", new_y="NEXT")

    if 'is_normal' in stats:
        pdf.ln(4)
        pdf.set_font('Helvetica', 'B', 11)
        if stats['is_normal']:
            pdf.set_text_color(0, 230, 118)
            pdf.cell(0, 8, f'Test de normalite (Shapiro-Wilk): Distribution normale (p = {stats.get("normality_p_value", 0.0):.4f})', new_x="LMARGIN", new_y="NEXT")
        else:
            pdf.set_text_color(255, 82, 82)
            pdf.cell(0, 8, f'Test de normalite (Shapiro-Wilk): Distribution non-normale (p = {stats.get("normality_p_value", 0.0):.4f})', new_x="LMARGIN", new_y="NEXT")

    if interpretation:
        pdf.ln(8)
        pdf.set_font('Helvetica', 'B', 14)
        pdf.set_text_color(26, 111, 212)
        pdf.cell(0, 10, 'Interpretation', new_x="LMARGIN", new_y="NEXT")
        pdf.set_draw_color(26, 111, 212)
        pdf.line(10, pdf.get_y(), 200, pdf.get_y())
        pdf.ln(4)

        pdf.set_font('Helvetica', '', 10)
        pdf.set_text_color(30, 30, 30)
        pdf.set_fill_color(240, 247, 255)
        pdf.multi_cell(0, 6, interpretation, border=0, fill=True)

    if charts_base64:
        import base64
        import tempfile
        pdf.ln(8)
        pdf.set_font('Helvetica', 'B', 14)
        pdf.set_text_color(26, 111, 212)
        pdf.cell(0, 10, 'Graphiques', new_x="LMARGIN", new_y="NEXT")
        pdf.set_draw_color(26, 111, 212)
        pdf.line(10, pdf.get_y(), 200, pdf.get_y())
        pdf.ln(4)

        for i, img_b64 in enumerate(charts_base64):
            try:
                img_data = base64.b64decode(img_b64)
                with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as tmp:
                    tmp.write(img_data)
                    tmp_path = tmp.name

                if pdf.get_y() > 180:
                    pdf.add_page()

                pdf.image(tmp_path, x=10, w=190)
                pdf.ln(4)
                os.unlink(tmp_path)
            except Exception:
                pass

    pdf.ln(10)
    pdf.set_font('Helvetica', 'I', 8)
    pdf.set_text_color(150, 150, 150)
    pdf.cell(0, 6, 'Rapport genere par DataMind - Application statistique pedagogique', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 6, f'ISPM (c) {datetime.now().year}', align='C')

    return bytes(pdf.output())
