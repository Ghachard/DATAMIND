from docx import Document
from docx.shared import Pt, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

doc = Document()
style = doc.styles['Normal']
style.font.name = 'Calibri'
style.font.size = Pt(10)

def fmt(cell, text, bold=False, size=12, align=WD_ALIGN_PARAGRAPH.CENTER):
    cell.text = ''
    p = cell.paragraphs[0]
    p.alignment = align
    r = p.add_run(text)
    r.bold = bold
    r.font.size = Pt(size)

t = doc.add_heading('MLT — DataMind', level=1)
t.alignment = WD_ALIGN_PARAGRAPH.CENTER

doc.add_paragraph('')
doc.add_paragraph('E = Événement externe | T = Traitement | I = Événement interne').alignment = WD_ALIGN_PARAGRAPH.CENTER
doc.add_paragraph('')

rows = [
    ('CHAÎNE 1 : SAISIE ET CALCUL', '', '', '', ''),
    ('', 'E1 : L\'utilisateur saisit des données', '→', 'T1 : Validation des données', 'I1 : Données validées'),
    ('', 'E2 : L\'utilisateur clique sur "Calculer"', '→', 'T2 : Calcul des statistiques', 'I2 : Statistiques calculées'),
    ('', 'I2 : Statistiques calculées', '→', 'T3 : Sauvegarde dans SQLite', 'I3 : Résultat sauvé'),
    ('', 'I3 : Résultat sauvé', '→', 'T4 : Affichage des résultats', 'I4 : Résultats affichés'),
    ('', '', '', '', ''),
    ('CHAÎNE 2 : GRAPHIQUES', '', '', '', ''),
    ('', 'E3 : Va à l\'écran Graphiques', '→', 'T5 : Filtrage par nature', 'I5 : Graphiques compatibles affichés'),
    ('', 'E4 : Sélectionne un graphique', '→', 'T6 : Génération du graphique', 'I6 : Graphique interactif affiché'),
    ('', '', '', '', ''),
    ('CHAÎNE 3 : PROBABILITÉS', '', '', '', ''),
    ('', 'E5 : Choisit une loi', '→', 'T7 : Pré-remplissage des paramètres', 'I7 : Paramètres remplis avec les stats'),
    ('', 'E6 : Clique sur "Calculer"', '→', 'T8 : Calcul de la loi', 'I8 : Résultat loi + graphique'),
    ('', '', '', '', ''),
    ('CHAÎNE 4 : HISTORIQUE', '', '', '', ''),
    ('', 'E7 : Ouvre l\'écran Analyse', '→', 'T9 : Chargement des 5 dernières analyses', 'I9 : Historique affiché'),
    ('', '', '', '', ''),
    ('CHAÎNE 5 : EXPORT PDF', '', '', '', ''),
    ('', 'E8 : Clique sur "Exporter"', '→', 'T10 : Génération du rapport PDF', 'I10 : PDF généré'),
    ('', 'I10 : PDF généré', '→', 'T11 : Envoi du fichier', 'E9 : PDF téléchargé'),
]

table = doc.add_table(rows=len(rows), cols=5)
table.alignment = WD_TABLE_ALIGNMENT.CENTER

for i, h in enumerate(['', 'Événement', '', 'Traitement', 'Résultat']):
    cell = table.rows[0].cells[i]
    fmt(cell, h, bold=True, size=14)

for ri, row_data in enumerate(rows, 1):
    if ri >= len(rows):
        break
    num, evt, arrow, trait, res = row_data
    row = table.rows[ri]

    if evt == '' and trait == '' and res == '' and num != '':
        a = row.cells[0]
        b = row.cells[4]
        a.merge(b)
        fmt(row.cells[0], num, bold=True, size=13, align=WD_ALIGN_PARAGRAPH.LEFT)
        continue

    if evt == '' and trait == '' and res == '':
        continue

    fmt(row.cells[0], '', size=9)
    fmt(row.cells[1], evt, size=9, align=WD_ALIGN_PARAGRAPH.LEFT)
    fmt(row.cells[2], '→', size=11)
    fmt(row.cells[3], trait, size=9, align=WD_ALIGN_PARAGRAPH.LEFT)
    fmt(row.cells[4], res, size=9, align=WD_ALIGN_PARAGRAPH.LEFT)

doc.add_paragraph('')

doc.add_heading('Synthèse', level=2)

ts = doc.add_table(rows=6, cols=4)
ts.style = 'Light Grid Accent 1'
ts.alignment = WD_TABLE_ALIGNMENT.CENTER

for i, h in enumerate(['Chaîne', 'Événements', 'Traitements', 'Résultat']):
    cell = ts.rows[0].cells[i]
    cell.text = ''
    p = cell.paragraphs[0]
    r = p.add_run(h)
    r.bold = True
    r.font.size = Pt(13)

data = [
    ['Saisie et calcul', 'E1, E2', 'T1, T2, T3, T4', 'Résultats affichés'],
    ['Graphiques', 'E3, E4', 'T5, T6', 'Graphique interactif'],
    ['Probabilités', 'E5, E6', 'T7, T8', 'Loi calculée'],
    ['Historique', 'E7', 'T9', '5 dernières analyses'],
    ['Export PDF', 'E8, I10', 'T10, T11', 'PDF téléchargé'],
]
for ri, rd in enumerate(data, 1):
    for ci, v in enumerate(rd):
        cell = ts.rows[ri].cells[ci]
        cell.text = ''
        p = cell.paragraphs[0]
        r = p.add_run(v)
        r.font.size = Pt(12)

doc.save(r'C:\Users\lenovo\Desktop\Projet DataMind\MLT_v3.docx')
print('Fichier MLT_DataMind.docx généré')
