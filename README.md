# Solar Panel Defect Detection Using Thermal and Visual Images
### Based on MATLAB Image Processing (ECE Batch 9)

An automated, lightweight, non-deep-learning solar panel defect detection and diagnostic system built in MATLAB. It utilizes dual-modality image fusion (`imfuse`), morphological segmentation, calibrated thermal thermography, and decision-tree classification to detect, localize, and evaluate mismatching faults, hotspots, dust/dirt accumulation, and physical cracks.

---

## 🚀 Quick Start Guide

### 1. Launch Interactive MATLAB Dashboard
Open MATLAB, set current folder to `d:\Solar-panel`, and type in the MATLAB Command Window:
```matlab
solar_dashboard
```
Or open [`solar_dashboard.m`](file:///d:/Solar-panel/solar_dashboard.m) in the MATLAB Editor and press **Run (F5)**.

### 2. Run Automated Batch Test
To test all test samples (Clean, Dirt, Shadow) and generate reports automatically:
```matlab
run_demo
```

---

## 🖥️ Dashboard Features

1. **Preset Dropdown Selector**:
   - Easily switch between `SP090P` panels under different operating conditions:
     - `Panel 1 (Clean Baseline)`
     - `Panel 1 (Dirt / Soiling)`
     - `Panel 1 (Partial Shadow)`
     - `Panel 2 (Clean / Dirt / Shadow)`
     - `Panel 3 (Clean / Dirt / Shadow)`
   - Or click **📂 Browse Custom Pair** to analyze custom visual & thermal images.

2. **4-Quadrant Viewports**:
   - **Quadrant 1 (Visual RGB)**: Contrast enhancement (CLAHE) with edge detail highlight.
   - **Quadrant 2 (Thermal IR)**: Calibrated heatmap matrix with peak temperature detection.
   - **Quadrant 3 (Fused Modality)**: MATLAB `imfuse(IT, Ig, 'blend')` combining structural and thermal features.
   - **Quadrant 4 (Defect Localization)**: Automated bounding boxes, defect labels, and hotspot crosshair.

3. **Diagnostic Telemetry Cards**:
   - **Primary Defect Type**: Clean, Hotspot, Dirt/Dust, Shadow Mismatch, Crack.
   - **Severity Rating Badge**: `[ LOW ]` (Green) / `[ MEDIUM ]` (Yellow) / `[ HIGH ]` (Orange) / `[ CRITICAL ]` (Red).
   - **Thermal Telemetry**: Peak Temperature ($T_{\max}$), Ambient Mean ($T_{\text{avg}}$), and Temperature Rise ($\Delta T$).
   - **Surface Impact**: Affected surface damage percentage.
   - **Actionable Maintenance Recommendation**: Practical engineering advice (cleaning instructions, diode checks, string isolation).

4. **1-Click Actions**:
   - **▶ Run Full Detection**: Executes the 5-step dual-modality pipeline.
   - **📈 Plot I-V & P-V Curve**: Compares Current-Voltage and Power-Voltage curves against baseline to quantify power degradation ($P_{\max}$ drop).
   - **📥 Export Report**: Automatically compiles and exports an academic diagnostic report as high-resolution PNG and PDF to the `reports/` folder.

---

## 📂 Project Structure

```text
d:\Solar-panel\
│
├── solar_dashboard.m        # Interactive MATLAB GUI Dashboard
├── run_demo.m               # Batch test and verification script
│
├── src/
│   ├── read_thermal_csv.m      # 80x60 UTF-16LE calibrated temperature matrix reader
│   ├── process_visual.m        # Grayscale, CLAHE contrast enhancement & Canny edge detection
│   ├── process_thermal.m       # Temperature mapping, delta T calculation & hotspot detection
│   ├── fuse_modalities.m       # Thermal-visual fusion using MATLAB imfuse (Slide 13)
│   ├── classify_and_localize.m # Decision tree classifier & bounding box localization
│   ├── plot_iv_curve.m         # I-V & P-V curve plotter with power drop analysis
│   └── export_defect_report.m  # Automated PDF/PNG diagnostic report generator
│
├── reports/                 # Saved diagnostic reports (PDF / PNG)
│
└── Experimental data.../    # Raw dataset (SP090P & M5_30112 visual, thermal & electrical data)
```

---

## 🔬 Algorithmic Pipeline

| Step | Operation | MATLAB Function | Purpose |
| :--- | :--- | :--- | :--- |
| **1** | Preprocessing | `imresize`, `adapthisteq` | Resizing, noise suppression, contrast boost |
| **2** | Visual Branch | `rgb2gray`, `edge(..., 'Canny')`, `stdfilt` | Crack detection, dust texture, shadow masking |
| **3** | Thermal Branch | `read_thermal_csv`, `imclose`, `bwareaopen` | Temperature calibration, hotspot isolation ($\Delta T$) |
| **4** | Image Fusion | `imfuse(IT, Ig, 'blend')` | Complementary thermal & structural feature fusion |
| **5** | Feature Extraction | `regionprops(..., 'Area', 'BoundingBox')` | Extract area, bounding box coordinates, centroid |
| **6** | Classification | Decision Tree Rules | Categorize into Clean, Hotspot, Dirt, Shadow, Crack |
| **7** | Localization | `insertShape`, `insertText` | Overlay bounding boxes and defect labels |
| **8** | Report Export | `exportgraphics`, `saveas` | Automated maintenance report generation |
