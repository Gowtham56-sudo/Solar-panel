import os
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether, PageBreak, HRFlowable
)
from reportlab.graphics.shapes import Drawing, Rect, String, Line, Group, Polygon

def create_readme_pdf(pdf_path):
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=A4,
        leftMargin=36,
        rightMargin=36,
        topMargin=36,
        bottomMargin=36
    )

    styles = getSampleStyleSheet()

    # Custom styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor('#0F2C59'),
        alignment=1, # Center
        spaceAfter=4
    )

    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor('#C87D00'),
        alignment=1,
        spaceAfter=12
    )

    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=colors.HexColor('#0F2C59'),
        spaceBefore=10,
        spaceAfter=6
    )

    h2_style = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=14,
        textColor=colors.HexColor('#1E5128'),
        spaceBefore=8,
        spaceAfter=4
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor('#222222'),
        spaceAfter=5
    )

    bold_body_style = ParagraphStyle(
        'BoldBody_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor('#0F2C59'),
        spaceAfter=5
    )

    code_style = ParagraphStyle(
        'Code_Custom',
        parent=styles['Normal'],
        fontName='Courier-Bold',
        fontSize=9,
        leading=12,
        textColor=colors.HexColor('#990000'),
        backColor=colors.HexColor('#F5F5F5')
    )

    elements = []

    # Title & Subtitle Banner
    elements.append(Paragraph("EXCEL ENGINEERING COLLEGE (AUTONOMOUS) - ECE DEPT", subtitle_style))
    elements.append(Paragraph("SOLAR PANEL DEFECT DETECTION & DIAGNOSTIC SYSTEM", title_style))
    elements.append(Paragraph("MATLAB Thermal-Visual Image Fusion Pipeline | Complete Project Manual (Tanglish)", subtitle_style))
    elements.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor('#0F2C59'), spaceAfter=10))

    # Introduction / Overview in Tanglish
    intro_text = (
        "<b>Project Summary:</b> Intha project deep learning theva padama, MATLAB Image Processing "
        "Toolbox functions (<code>imfuse</code>, <code>Canny edge</code>, <code>regionprops</code>) use panni, "
        "Visual (RGB) and Thermal (IR) sensor images-ah fuse panni solar panel faults (Hotspot, Dirt, Shadow, Crack) "
        "kandupidichu automated diagnostic report and I-V curve power loss-ah calculate pannuthu."
    )
    elements.append(Paragraph(intro_text, body_style))
    elements.append(Spacer(1, 8))

    # Architecture / Flow Diagram Section
    elements.append(Paragraph("1. System Flow & Architecture Diagram (Archify Workflow)", h1_style))
    arch_intro = (
        "Project-oda full workflow-kaga <code>solar_panel_pipeline.archify</code> file create pannirukom. "
        "VS Code-la <b>Archify Diagram Viewer</b> extension moolama itha interactive live flow diagram-ah view pannikalam. "
        "Keezha irukura flow diagram intha pipeline-oda step-by-step process-ah kaatuthu:"
    )
    elements.append(Paragraph(arch_intro, body_style))
    elements.append(Spacer(1, 6))

    # Drawing vector flowchart
    d = Drawing(520, 155)
    # Background
    d.add(Rect(0, 0, 520, 155, fillColor=colors.HexColor('#F8FAFC'), strokeColor=colors.HexColor('#CBD5E1'), strokeWidth=1, rx=5, ry=5))

    # Box 1: Inputs
    d.add(Rect(10, 85, 110, 55, fillColor=colors.HexColor('#E0F2FE'), strokeColor=colors.HexColor('#0284C7'), strokeWidth=1.5, rx=4, ry=4))
    d.add(String(20, 123, "1. INPUTS", fontName="Helvetica-Bold", fontSize=8.5, fillColor=colors.HexColor('#0369A1')))
    d.add(String(16, 110, "- RGB Image (_VL.png)", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))
    d.add(String(16, 99, "- IR Heatmap (.png)", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))
    d.add(String(16, 88, "- CSV 80x60 Temp Mat", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))

    # Arrow 1 -> 2
    d.add(Line(120, 112, 138, 112, strokeColor=colors.HexColor('#64748B'), strokeWidth=1.5))
    d.add(Polygon([138, 115, 144, 112, 138, 109], fillColor=colors.HexColor('#64748B'), strokeColor=None))

    # Box 2: Preprocessing & Branches
    d.add(Rect(144, 85, 115, 55, fillColor=colors.HexColor('#FEF3C7'), strokeColor=colors.HexColor('#D97706'), strokeWidth=1.5, rx=4, ry=4))
    d.add(String(150, 123, "2. DUAL BRANCHES", fontName="Helvetica-Bold", fontSize=8.5, fillColor=colors.HexColor('#B45309')))
    d.add(String(150, 110, "Visual: CLAHE+Canny", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))
    d.add(String(150, 99, "Thermal: T_max, Delta T", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))
    d.add(String(150, 88, "Align: Resize 480x640", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))

    # Arrow 2 -> 3
    d.add(Line(259, 112, 277, 112, strokeColor=colors.HexColor('#64748B'), strokeWidth=1.5))
    d.add(Polygon([277, 115, 283, 112, 277, 109], fillColor=colors.HexColor('#64748B'), strokeColor=None))

    # Box 3: imfuse Fusion
    d.add(Rect(283, 85, 110, 55, fillColor=colors.HexColor('#DCFCE7'), strokeColor=colors.HexColor('#16A34A'), strokeWidth=1.5, rx=4, ry=4))
    d.add(String(290, 123, "3. FUSION (imfuse)", fontName="Helvetica-Bold", fontSize=8.5, fillColor=colors.HexColor('#15803D')))
    d.add(String(290, 110, "Slide 13 Algorithm:", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))
    d.add(String(290, 99, "If = imfuse(IT, Ig, 'blend')", fontName="Courier-Bold", fontSize=6.5, fillColor=colors.HexColor('#166534')))
    d.add(String(290, 88, "Extract regionprops", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))

    # Arrow 3 -> 4
    d.add(Line(393, 112, 408, 112, strokeColor=colors.HexColor('#64748B'), strokeWidth=1.5))
    d.add(Polygon([408, 115, 414, 112, 408, 109], fillColor=colors.HexColor('#64748B'), strokeColor=None))

    # Box 4: Decision Tree & Severity
    d.add(Rect(414, 85, 96, 55, fillColor=colors.HexColor('#FEE2E2'), strokeColor=colors.HexColor('#DC2626'), strokeWidth=1.5, rx=4, ry=4))
    d.add(String(420, 123, "4. CLASSIFIER", fontName="Helvetica-Bold", fontSize=8.5, fillColor=colors.HexColor('#B91C1C')))
    d.add(String(420, 110, "Decision Tree Rules", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))
    d.add(String(420, 99, "Clean/Hotspot/Dirt", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))
    d.add(String(420, 88, "Severity: Low -> Critical", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))

    # Bottom Row: Deliverables
    # Arrow 4 down to 5
    d.add(Line(462, 85, 462, 58, strokeColor=colors.HexColor('#64748B'), strokeWidth=1.5))
    d.add(Line(462, 58, 430, 58, strokeColor=colors.HexColor('#64748B'), strokeWidth=1.5))
    d.add(Polygon([430, 61, 424, 58, 430, 55], fillColor=colors.HexColor('#64748B'), strokeColor=None))

    # Deliverables Boxes
    d.add(Rect(10, 10, 150, 48, fillColor=colors.HexColor('#F3E8FF'), strokeColor=colors.HexColor('#9333EA'), strokeWidth=1.5, rx=4, ry=4))
    d.add(String(18, 44, "Interactive Dashboard", fontName="Helvetica-Bold", fontSize=8.5, fillColor=colors.HexColor('#7E22CE')))
    d.add(String(18, 31, "solar_dashboard.m", fontName="Courier-Bold", fontSize=7.5, fillColor=colors.HexColor('#581C87')))
    d.add(String(18, 18, "4 Live Quadrants + Metrics", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))

    d.add(Rect(175, 10, 150, 48, fillColor=colors.HexColor('#F3E8FF'), strokeColor=colors.HexColor('#9333EA'), strokeWidth=1.5, rx=4, ry=4))
    d.add(String(183, 44, "Automated Report Export", fontName="Helvetica-Bold", fontSize=8.5, fillColor=colors.HexColor('#7E22CE')))
    d.add(String(183, 31, "PDF & PNG Summary", fontName="Courier-Bold", fontSize=7.5, fillColor=colors.HexColor('#581C87')))
    d.add(String(183, 18, "Diagnostic Table & Advice", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))

    d.add(Rect(340, 10, 170, 48, fillColor=colors.HexColor('#F3E8FF'), strokeColor=colors.HexColor('#9333EA'), strokeWidth=1.5, rx=4, ry=4))
    d.add(String(348, 44, "I-V & P-V Curve Analysis", fontName="Helvetica-Bold", fontSize=8.5, fillColor=colors.HexColor('#7E22CE')))
    d.add(String(348, 31, "plot_iv_curve.m (.mat)", fontName="Courier-Bold", fontSize=7.5, fillColor=colors.HexColor('#581C87')))
    d.add(String(348, 18, "Power Loss (%) vs Baseline", fontName="Helvetica", fontSize=7.5, fillColor=colors.HexColor('#334155')))

    elements.append(d)
    elements.append(Spacer(1, 12))

    # Section 2: Dropdown Testing Conditions (Explained)
    elements.append(Paragraph("2. Dropdown-la Ulla 3 Testing Conditions (Enna & Ethukku?)", h1_style))
    cond_desc = (
        "Dataset-la 3 panels (Panel 1, 2, 3) test pannirukanga. Ovvoru panel-kum kaila irukura 3 testing states:"
    )
    elements.append(Paragraph(cond_desc, body_style))

    table_data = [
        [
            Paragraph("<b>Condition</b>", bold_body_style),
            Paragraph("<b>Meaning (Enna Athu?)</b>", bold_body_style),
            Paragraph("<b>Project Purpose (Ethukku?)</b>", bold_body_style)
        ],
        [
            Paragraph("<b>Clean Baseline</b>", code_style),
            Paragraph("Panel full-ah clean-ah, entha dust-o nizhalo illatha healthy state.", body_style),
            Paragraph("Reference standard. Normal operating temp and max power epdi irukumnu compare panna.", body_style)
        ],
        [
            Paragraph("<b>Dirt / Soiling</b>", code_style),
            Paragraph("Panel surface mela thooli (dust), mann padinthu irukura state.", body_style),
            Paragraph("Visual texture variation moolama dust-ah detect panni water wash recommend panna.", body_style)
        ],
        [
            Paragraph("<b>Partial Shadow</b>", code_style),
            Paragraph("Panel mela geometric shadow vizhundhu cell reverse bias heat aagura state.", body_style),
            Paragraph("Thermal camera moolama T_max (54-61 C) hotspot kandupidichu diode fault thadukka.", body_style)
        ]
    ]

    t_cond = Table(table_data, colWidths=[100, 210, 210])
    t_cond.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#E2E8F0')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#94A3B8')),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    elements.append(t_cond)
    elements.append(Spacer(1, 10))

    # Section 3: 4 Image Viewports
    elements.append(Paragraph("3. Dashboard-la Ulla 4 Image Viewports Vilakkam", h1_style))
    v_data = [
        [
            Paragraph("<b>Quadrant 1: Visual (RGB) Image</b><br/>"
                      "RGB camera-la edutha direct image. CLAHE contrast enhancement panni surface micro-cracks and shadow edges-ah highlight pannuthu.", body_style),
            Paragraph("<b>Quadrant 2: Thermal (IR) Heatmap</b><br/>"
                      "Fluke Ti400 thermal camera-la edutha calibrated heat image. Real CSV temperature matrix (80x60) vachu peak hotspot point mark pannuthu.", body_style)
        ],
        [
            Paragraph("<b>Quadrant 3: Fused Image (imfuse)</b><br/>"
                      "PPT Slide 13-la ulla algorithm: <code>imfuse(IT, Ig, 'blend')</code>. Visual cell edges + Thermal heat distribution orey image-la merge aagi display aagum.", body_style),
            Paragraph("<b>Quadrant 4: Defect Localization</b><br/>"
                      "Algorithm kandupidicha defect edathula <b>Red Bounding Box</b> and label (e.g. <code>[SHADOW: 22.6%]</code>) pottu screen-la kaatum.", body_style)
        ]
    ]
    t_v = Table(v_data, colWidths=[260, 260])
    t_v.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (0,0), colors.HexColor('#F1F5F9')),
        ('BACKGROUND', (1,0), (1,0), colors.HexColor('#FFF7ED')),
        ('BACKGROUND', (0,1), (0,1), colors.HexColor('#F0FDF4')),
        ('BACKGROUND', (1,1), (1,1), colors.HexColor('#FEF2F2')),
        ('GRID', (0,0), (-1,-1), 0.8, colors.HexColor('#CBD5E1')),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
    ]))
    elements.append(t_v)
    elements.append(Spacer(1, 10))

    # Section 4: File Structure & Module functions
    elements.append(Paragraph("4. Project Files & Source Modules", h1_style))
    f_data = [
        [Paragraph("<b>File / Script</b>", bold_body_style), Paragraph("<b>Path</b>", bold_body_style), Paragraph("<b>Function & Working</b>", bold_body_style)],
        [Paragraph("solar_dashboard.m", code_style), Paragraph("d:\\Solar-panel\\", body_style), Paragraph("Interactive live GUI. Dropdown switch panna automatic 4-quadrant display.", body_style)],
        [Paragraph("solar_panel_pipeline.archify", code_style), Paragraph("d:\\Solar-panel\\", body_style), Paragraph("Archify extension workflow schema. Live diagram view in VS Code.", body_style)],
        [Paragraph("read_thermal_csv.m", code_style), Paragraph("d:\\Solar-panel\\src\\", body_style), Paragraph("Ultra-fast CSV parser using compiled C sscanf (0.02s-la 80x60 matrix).", body_style)],
        [Paragraph("process_visual.m", code_style), Paragraph("d:\\Solar-panel\\src\\", body_style), Paragraph("Grayscale + CLAHE + Canny edge detection + local texture filter.", body_style)],
        [Paragraph("process_thermal.m", code_style), Paragraph("d:\\Solar-panel\\src\\", body_style), Paragraph("T_max, T_mean, Delta T (+8.5 C) calculation and hotspot mask extraction.", body_style)],
        [Paragraph("fuse_modalities.m", code_style), Paragraph("d:\\Solar-panel\\src\\", body_style), Paragraph("Slide 13 blend fusion combining visual texture and thermal heat.", body_style)],
        [Paragraph("classify_and_localize.m", code_style), Paragraph("d:\\Solar-panel\\src\\", body_style), Paragraph("Decision tree rules + regionprops bounding boxes + Severity rating.", body_style)],
        [Paragraph("plot_iv_curve.m", code_style), Paragraph("d:\\Solar-panel\\src\\", body_style), Paragraph("Loads 500k sample .mat electrical file and plots I-V and P-V power drop.", body_style)],
        [Paragraph("export_defect_report.m", code_style), Paragraph("d:\\Solar-panel\\src\\", body_style), Paragraph("Generates college review report in PNG/PDF inside reports/ folder.", body_style)]
    ]
    t_f = Table(f_data, colWidths=[130, 110, 280])
    t_f.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#E2E8F0')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#94A3B8')),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    elements.append(t_f)
    elements.append(Spacer(1, 10))

    # Section 5: How to Run
    elements.append(Paragraph("5. Epdi Run Pannanum? (How to Run)", h1_style))
    run_steps = (
        "<b>Step 1 (MATLAB Dashboard):</b><br/>"
        "&nbsp;&nbsp;1. MATLAB R2025b open pannunga.<br/>"
        "&nbsp;&nbsp;2. Current folder-ah <code>d:\\Solar-panel</code> nu set pannunga.<br/>"
        "&nbsp;&nbsp;3. Command Window-la <code>solar_dashboard</code> nu type panni Enter thantinga na Dashboard open aagidum.<br/>"
        "&nbsp;&nbsp;4. Dropdown-la entha panel select pannalum automatic-ah 4 images-um and live metrics-um update aagidum.<br/><br/>"
        "<b>Step 2 (VS Code Archify Extension):</b><br/>"
        "&nbsp;&nbsp;1. VS Code Extensions-la <b>'Archify Diagram Viewer'</b> install pannunga.<br/>"
        "&nbsp;&nbsp;2. <code>solar_panel_pipeline.archify</code> file-ah click panna interactive visual diagram open aagidum.<br/><br/>"
        "<b>Step 3 (Batch Demo Verification):</b><br/>"
        "&nbsp;&nbsp;MATLAB Command Window-la <code>run_demo</code> nu run panna ella panels-um batch test aagi "
        "<code>reports/</code> folder-la PDF & PNG diagnostic reports auto-save aagidum."
    )
    elements.append(Paragraph(run_steps, body_style))

    doc.build(elements)
    print("README PDF created successfully at:", pdf_path)

if __name__ == '__main__':
    out_pdf = r"d:\Solar-panel\README.pdf"
    create_readme_pdf(out_pdf)
