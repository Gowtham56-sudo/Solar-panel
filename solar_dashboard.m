function solar_dashboard()
% SOLAR_DASHBOARD Interactive MATLAB Dashboard for Solar Panel Defect Detection
%
% Project: Solar Panel Defect Detection Using Thermal and Visual Images
%          Based on MATLAB Image Processing
% Department: ECE, Excel Engineering College (Autonomous)
%
% Run this file in MATLAB:
%   >> solar_dashboard
%   or press F5 in the Editor.

    % Ensure src directory is in path
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(curr_dir, 'src'));

    % Dataset base path
    data_dir = fullfile(curr_dir, 'Experimental data for Mismatching Faults of Photovoltaic Modules', ...
                         'Experimental data for Mismatching Faults of Photovoltaic Modules', 'RawData', 'SP090P');
    thermal_dir = fullfile(data_dir, 'ThermalData');
    elec_dir = fullfile(data_dir, 'ElectricalData');

    % Preset Panels List
    preset_labels = {
        'SP090P - Panel 1 (Clean Baseline)';
        'SP090P - Panel 1 (Dirt / Soiling)';
        'SP090P - Panel 1 (Partial Shadow)';
        'SP090P - Panel 2 (Clean Baseline)';
        'SP090P - Panel 2 (Dirt / Soiling)';
        'SP090P - Panel 2 (Partial Shadow)';
        'SP090P - Panel 3 (Clean Baseline)';
        'SP090P - Panel 3 (Dirt / Soiling)';
        'SP090P - Panel 3 (Partial Shadow)'
    };

    preset_keys = {
        'Panel1_Clean';
        'Panel1_Dirt';
        'Panel1_Shadow';
        'Panel2_Clean';
        'Panel2_Dirt';
        'Panel2_Shadow';
        'Panel3_Clean';
        'Panel3_Dirt';
        'Panel3_Shadow'
    };

    % Application State Struct
    app_data = struct();
    app_data.current_key = preset_keys{3}; % Default to Panel1_Shadow for prominent demo
    app_data.thermal_dir = thermal_dir;
    app_data.elec_dir = elec_dir;
    app_data.IV_raw = [];
    app_data.IT_raw = [];
    app_data.temp_matrix = [];
    app_data.vis_features = [];
    app_data.therm_features = [];
    app_data.If = [];
    app_data.I_annotated = [];
    app_data.diag_result = [];

    % -------------------------------------------------------------
    % 1. MAIN FIGURE WINDOW
    % -------------------------------------------------------------
    screen_sz = get(0, 'ScreenSize');
    fig_w = min(1360, screen_sz(3) - 60);
    fig_h = min(840, screen_sz(4) - 80);
    fig_x = max(30, round((screen_sz(3) - fig_w) / 2));
    fig_y = max(40, round((screen_sz(4) - fig_h) / 2));

    hFig = figure('Name', 'Solar Panel Defect Detection & Diagnostic Dashboard', ...
                  'NumberTitle', 'off', ...
                  'MenuBar', 'none', ...
                  'ToolBar', 'none', ...
                  'Color', [0.09, 0.11, 0.14], ...
                  'Position', [fig_x, fig_y, fig_w, fig_h]);

    % -------------------------------------------------------------
    % 2. HEADER BANNER
    % -------------------------------------------------------------
    uicontrol('Parent', hFig, 'Style', 'text', ...
              'String', '☀️ SOLAR PANEL DEFECT DETECTION & DIAGNOSTIC SYSTEM', ...
              'Units', 'normalized', 'Position', [0.02, 0.935, 0.65, 0.05], ...
              'FontSize', 15, 'FontWeight', 'bold', 'ForegroundColor', [1, 0.85, 0.3], ...
              'BackgroundColor', [0.09, 0.11, 0.14], 'HorizontalAlignment', 'left');

    uicontrol('Parent', hFig, 'Style', 'text', ...
              'String', 'ECE Department | Thermal-Visual Image Fusion Pipeline | MATLAB R2025b', ...
              'Units', 'normalized', 'Position', [0.02, 0.905, 0.65, 0.03], ...
              'FontSize', 9.5, 'ForegroundColor', [0.65, 0.75, 0.85], ...
              'BackgroundColor', [0.09, 0.11, 0.14], 'HorizontalAlignment', 'left');

    % -------------------------------------------------------------
    % 3. TOP TOOLBAR / CONTROL PANEL
    % -------------------------------------------------------------
    pnl_ctrl = uipanel('Parent', hFig, 'Units', 'normalized', ...
                       'Position', [0.02, 0.835, 0.96, 0.065], ...
                       'BackgroundColor', [0.14, 0.17, 0.22], ...
                       'HighlightColor', [0.25, 0.30, 0.40]);

    % Dropdown label
    uicontrol('Parent', pnl_ctrl, 'Style', 'text', 'String', 'Select Panel Sample:', ...
              'Units', 'normalized', 'Position', [0.01, 0.25, 0.12, 0.50], ...
              'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', [0.9, 0.95, 1.0], ...
              'BackgroundColor', [0.14, 0.17, 0.22], 'HorizontalAlignment', 'left');

    % Dropdown control
    hDropdown = uicontrol('Parent', pnl_ctrl, 'Style', 'popupmenu', ...
                          'String', preset_labels, 'Value', 3, ...
                          'Units', 'normalized', 'Position', [0.14, 0.20, 0.28, 0.60], ...
                          'FontSize', 10, 'BackgroundColor', [0.22, 0.26, 0.34], ...
                          'ForegroundColor', [1, 1, 1], ...
                          'Callback', @on_panel_selected);

    % Custom Browse Button
    uicontrol('Parent', pnl_ctrl, 'Style', 'pushbutton', 'String', '📂 Browse Custom Pair', ...
              'Units', 'normalized', 'Position', [0.43, 0.18, 0.13, 0.65], ...
              'FontSize', 9.5, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.20, 0.25, 0.35], 'ForegroundColor', [0.85, 0.92, 1.0], ...
              'Callback', @on_browse_custom);

    % Run Analysis Button (Bright Accent)
    btn_run = uicontrol('Parent', pnl_ctrl, 'Style', 'pushbutton', 'String', '▶ Run Full Detection', ...
                        'Units', 'normalized', 'Position', [0.57, 0.18, 0.14, 0.65], ...
                        'FontSize', 10, 'FontWeight', 'bold', ...
                        'BackgroundColor', [0.12, 0.55, 0.35], 'ForegroundColor', [1, 1, 1], ...
                        'Callback', @on_run_analysis);

    % Plot I-V Curve Button
    uicontrol('Parent', pnl_ctrl, 'Style', 'pushbutton', 'String', '📈 Plot I-V & P-V Curve', ...
              'Units', 'normalized', 'Position', [0.72, 0.18, 0.13, 0.65], ...
              'FontSize', 9.5, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.25, 0.35, 0.55], 'ForegroundColor', [1, 1, 1], ...
              'Callback', @on_plot_iv);

    % Export Report Button
    uicontrol('Parent', pnl_ctrl, 'Style', 'pushbutton', 'String', '📥 Export Report', ...
              'Units', 'normalized', 'Position', [0.86, 0.18, 0.13, 0.65], ...
              'FontSize', 9.5, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.65, 0.35, 0.15], 'ForegroundColor', [1, 1, 1], ...
              'Callback', @on_export_report);

    % -------------------------------------------------------------
    % 4. FOUR IMAGE QUADRANT VIEWPORTS
    % -------------------------------------------------------------
    % Quadrant 1: Visual Image (Top Left)
    ax1 = axes('Parent', hFig, 'Units', 'normalized', ...
               'Position', [0.02, 0.44, 0.32, 0.36], ...
               'Color', [0.05, 0.06, 0.08]);
    title(ax1, '1. Visual (RGB) Image', 'Color', [0.75, 0.85, 0.95], 'FontSize', 10.5, 'FontWeight', 'bold');
    axis(ax1, 'off');

    % Quadrant 2: Thermal Image (Top Middle)
    ax2 = axes('Parent', hFig, 'Units', 'normalized', ...
               'Position', [0.35, 0.44, 0.32, 0.36], ...
               'Color', [0.05, 0.06, 0.08]);
    title(ax2, '2. Thermal (IR) Heatmap', 'Color', [1.0, 0.70, 0.50], 'FontSize', 10.5, 'FontWeight', 'bold');
    axis(ax2, 'off');

    % Quadrant 3: Fused Image (Bottom Left)
    ax3 = axes('Parent', hFig, 'Units', 'normalized', ...
               'Position', [0.02, 0.03, 0.32, 0.36], ...
               'Color', [0.05, 0.06, 0.08]);
    title(ax3, '3. Dual-Modality Fused Image (imfuse)', 'Color', [0.60, 0.95, 0.70], 'FontSize', 10.5, 'FontWeight', 'bold');
    axis(ax3, 'off');

    % Quadrant 4: Final Annotated Detection (Bottom Middle)
    ax4 = axes('Parent', hFig, 'Units', 'normalized', ...
               'Position', [0.35, 0.03, 0.32, 0.36], ...
               'Color', [0.05, 0.06, 0.08]);
    title(ax4, '4. Defect Localization & Bounding Box', 'Color', [1.0, 0.85, 0.40], 'FontSize', 10.5, 'FontWeight', 'bold');
    axis(ax4, 'off');

    % -------------------------------------------------------------
    % 5. RIGHT SIDE DIAGNOSTIC CARDS & METRICS PANEL
    % -------------------------------------------------------------
    pnl_diag = uipanel('Parent', hFig, 'Units', 'normalized', ...
                       'Position', [0.69, 0.03, 0.29, 0.77], ...
                       'BackgroundColor', [0.13, 0.15, 0.20], ...
                       'HighlightColor', [0.25, 0.30, 0.40], ...
                       'Title', '  DIAGNOSTIC TELEMETRY & REPORT  ', ...
                       'FontWeight', 'bold', 'FontSize', 10, ...
                       'ForegroundColor', [0.85, 0.92, 1.0]);

    % Metric 1: Defect Classification Card
    uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'DETECTED DEFECT:', ...
              'Units', 'normalized', 'Position', [0.06, 0.89, 0.88, 0.035], ...
              'FontSize', 9, 'FontWeight', 'bold', 'ForegroundColor', [0.65, 0.75, 0.85], ...
              'BackgroundColor', [0.13, 0.15, 0.20], 'HorizontalAlignment', 'left');

    txt_defect = uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'Pending Analysis...', ...
                           'Units', 'normalized', 'Position', [0.06, 0.835, 0.88, 0.055], ...
                           'FontSize', 12, 'FontWeight', 'bold', 'ForegroundColor', [1.0, 0.85, 0.30], ...
                           'BackgroundColor', [0.18, 0.21, 0.28], 'HorizontalAlignment', 'center');

    % Metric 2: Severity Badge Card
    uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'SEVERITY RATING:', ...
              'Units', 'normalized', 'Position', [0.06, 0.775, 0.88, 0.035], ...
              'FontSize', 9, 'FontWeight', 'bold', 'ForegroundColor', [0.65, 0.75, 0.85], ...
              'BackgroundColor', [0.13, 0.15, 0.20], 'HorizontalAlignment', 'left');

    txt_severity = uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', '---', ...
                             'Units', 'normalized', 'Position', [0.06, 0.720, 0.88, 0.055], ...
                             'FontSize', 12, 'FontWeight', 'bold', 'ForegroundColor', [0.7, 0.7, 0.7], ...
                             'BackgroundColor', [0.18, 0.21, 0.28], 'HorizontalAlignment', 'center');

    % Metric 3: Thermal Statistics Card
    uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'THERMAL TELEMETRY:', ...
              'Units', 'normalized', 'Position', [0.06, 0.660, 0.88, 0.035], ...
              'FontSize', 9, 'FontWeight', 'bold', 'ForegroundColor', [0.65, 0.75, 0.85], ...
              'BackgroundColor', [0.13, 0.15, 0.20], 'HorizontalAlignment', 'left');

    txt_thermal = uicontrol('Parent', pnl_diag, 'Style', 'text', ...
                            'String', sprintf('• Peak Temp (T_max) : ---\n• Mean Temp (T_avg) : ---\n• Temp Rise (\\DeltaT)   : ---'), ...
                            'Units', 'normalized', 'Position', [0.06, 0.540, 0.88, 0.115], ...
                            'FontSize', 9.5, 'ForegroundColor', [0.90, 0.95, 1.0], ...
                            'BackgroundColor', [0.18, 0.21, 0.28], 'HorizontalAlignment', 'left');

    % Metric 4: Affected Surface Area
    uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'SURFACE DAMAGE AREA:', ...
              'Units', 'normalized', 'Position', [0.06, 0.485, 0.88, 0.035], ...
              'FontSize', 9, 'FontWeight', 'bold', 'ForegroundColor', [0.65, 0.75, 0.85], ...
              'BackgroundColor', [0.13, 0.15, 0.20], 'HorizontalAlignment', 'left');

    txt_area = uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'Affected Surface: --- %', ...
                         'Units', 'normalized', 'Position', [0.06, 0.440, 0.88, 0.045], ...
                         'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', [0.90, 0.95, 1.0], ...
                         'BackgroundColor', [0.18, 0.21, 0.28], 'HorizontalAlignment', 'center');

    % Recommendation Card
    uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'ACTIONABLE RECOMMENDATION:', ...
              'Units', 'normalized', 'Position', [0.06, 0.385, 0.88, 0.035], ...
              'FontSize', 9, 'FontWeight', 'bold', 'ForegroundColor', [0.65, 0.75, 0.85], ...
              'BackgroundColor', [0.13, 0.15, 0.20], 'HorizontalAlignment', 'left');

    txt_rec = uicontrol('Parent', pnl_diag, 'Style', 'text', ...
                        'String', 'Select panel and click "Run Full Detection" to view maintenance guidance.', ...
                        'Units', 'normalized', 'Position', [0.06, 0.220, 0.88, 0.160], ...
                        'FontSize', 9, 'ForegroundColor', [0.85, 0.95, 0.85], ...
                        'BackgroundColor', [0.16, 0.22, 0.20], 'HorizontalAlignment', 'left');

    % Console / Execution Status Log
    uicontrol('Parent', pnl_diag, 'Style', 'text', 'String', 'SYSTEM LOG:', ...
              'Units', 'normalized', 'Position', [0.06, 0.165, 0.88, 0.035], ...
              'FontSize', 8.5, 'ForegroundColor', [0.6, 0.65, 0.7], ...
              'BackgroundColor', [0.13, 0.15, 0.20], 'HorizontalAlignment', 'left');

    txt_log = uicontrol('Parent', pnl_diag, 'Style', 'text', ...
                        'String', 'Ready. Select a sample and click Run Full Detection.', ...
                        'Units', 'normalized', 'Position', [0.06, 0.035, 0.88, 0.125], ...
                        'FontSize', 8.5, 'ForegroundColor', [0.4, 0.85, 0.4], ...
                        'BackgroundColor', [0.07, 0.09, 0.12], 'HorizontalAlignment', 'left');

    % -------------------------------------------------------------
    % AUTO-LOAD DEFAULT PANEL ON STARTUP
    % -------------------------------------------------------------
    load_and_display_panel(app_data.current_key);

    % =============================================================
    % CALLBACK FUNCTIONS
    % =============================================================

    function on_panel_selected(src, ~)
        val = src.Value;
        app_data.current_key = preset_keys{val};
        load_and_display_panel(app_data.current_key);
    end

    function load_and_display_panel(key)
        update_log(sprintf('Loading paired images for %s...', key));

        vl_path = fullfile(app_data.thermal_dir, [key, '_VL.png']);
        ir_path = fullfile(app_data.thermal_dir, [key, '.png']);
        csv_path = fullfile(app_data.thermal_dir, [key, '.csv']);

        if ~exist(vl_path, 'file') || ~exist(ir_path, 'file')
            errordlg(sprintf('Files for %s not found in:\n%s', key, app_data.thermal_dir), 'File Missing');
            return;
        end

        app_data.IV_raw = imread(vl_path);
        app_data.IT_raw = imread(ir_path);

        % Read Calibrated CSV Temperature Matrix (< 0.05s)
        [temp_mat, meta] = read_thermal_csv(csv_path);
        app_data.temp_matrix = temp_mat;
        app_data.temp_meta = meta;

        % Show Raw Images in Top Quadrants
        imshow(app_data.IV_raw, 'Parent', ax1);
        title(ax1, sprintf('1. Visual (RGB): %s', strrep(key, '_', ' ')), ...
              'Color', [0.75, 0.85, 0.95], 'FontSize', 10.5, 'FontWeight', 'bold');

        imshow(app_data.IT_raw, 'Parent', ax2);
        if ~isnan(meta.T_max)
            title(ax2, sprintf('2. Thermal Heatmap (Max: %.1f °C)', meta.T_max), ...
                  'Color', [1.0, 0.70, 0.50], 'FontSize', 10.5, 'FontWeight', 'bold');
        else
            title(ax2, '2. Thermal (IR) Heatmap', ...
                  'Color', [1.0, 0.70, 0.50], 'FontSize', 10.5, 'FontWeight', 'bold');
        end

        % Clear bottom quadrants until Run Analysis is clicked
        cla(ax3); axis(ax3, 'off');
        title(ax3, '3. Fused Image (Click "Run Full Detection")', 'Color', [0.5, 0.5, 0.5], 'FontSize', 10.5);

        cla(ax4); axis(ax4, 'off');
        title(ax4, '4. Defect Localization (Click "Run Full Detection")', 'Color', [0.5, 0.5, 0.5], 'FontSize', 10.5);

        % Reset metrics
        set(txt_defect, 'String', 'Ready for Analysis', 'ForegroundColor', [0.7, 0.8, 0.9]);
        set(txt_severity, 'String', '---', 'BackgroundColor', [0.18, 0.21, 0.28], 'ForegroundColor', [0.7, 0.7, 0.7]);
        if ~isnan(meta.T_max)
            set(txt_thermal, 'String', sprintf('• Peak Temp (T_max) : %.1f °C\n• Mean Temp (T_avg) : %.1f °C\n• Temp Range        : %.1f - %.1f °C', ...
                meta.T_max, meta.T_mean, meta.T_min, meta.T_max));
        else
            set(txt_thermal, 'String', sprintf('• Peak Temp (T_max) : ---\n• Mean Temp (T_avg) : ---\n• Temp Rise (\\DeltaT)   : ---'));
        end
        set(txt_area, 'String', 'Affected Surface: --- %');
        set(txt_rec, 'String', 'Click "Run Full Detection" to analyze.');
        update_log(sprintf('✓ Loaded %s ready.', key));
    end

    function on_run_analysis(~, ~)
        if isempty(app_data.IV_raw) || isempty(app_data.IT_raw)
            warndlg('Please select or load an image pair first.', 'No Image');
            return;
        end

        try
            set(btn_run, 'Enable', 'off');
            update_log('Processing: Fusing thermal and visual images via imfuse...');
            drawnow;

            % Step 1: Preprocessing & Fusion (Resizes both to 480x640)
            [If, IT_aligned, IV_aligned] = fuse_modalities(app_data.IT_raw, app_data.IV_raw);
            app_data.If = If;
            app_data.IT_aligned = IT_aligned;
            app_data.IV_aligned = IV_aligned;

            update_log('Processing: Analyzing visual surface features (Canny & CLAHE)...');
            drawnow;

            % Step 2: Visual Branch
            vis_features = process_visual(IV_aligned);
            app_data.vis_features = vis_features;

            update_log('Processing: Analyzing calibrated thermography & hotspots...');
            drawnow;

            % Step 3: Thermal Branch
            therm_features = process_thermal(IT_aligned, app_data.temp_matrix, app_data.temp_meta);
            app_data.therm_features = therm_features;

            update_log('Processing: Defect classification & bounding box localization...');
            drawnow;

            % Step 4: Decision Tree Defect Classification & Localization
            [diag_result, I_annotated] = classify_and_localize(vis_features, therm_features, IV_aligned, If);
            app_data.diag_result = diag_result;
            app_data.I_annotated = I_annotated;

            % Step 5: Render Results to Quadrants
            imshow(If, 'Parent', ax3);
            title(ax3, '3. Dual-Modality Fused Image (imfuse)', 'Color', [0.60, 0.95, 0.70], 'FontSize', 10.5, 'FontWeight', 'bold');

            imshow(I_annotated, 'Parent', ax4);
            title(ax4, sprintf('4. %s [%s]', diag_result.defect_type, diag_result.severity), ...
                  'Color', [1.0, 0.85, 0.40], 'FontSize', 10.5, 'FontWeight', 'bold');

            % Update Diagnostic Telemetry Cards
            set(txt_defect, 'String', diag_result.defect_type, 'ForegroundColor', [1.0, 0.9, 0.2]);

            % Severity Card Styling
            set(txt_severity, 'String', sprintf('[ %s ]', diag_result.severity), ...
                              'BackgroundColor', diag_result.severity_color, ...
                              'ForegroundColor', [1, 1, 1]);

            % Thermal Card
            set(txt_thermal, 'String', sprintf('• Peak Temp (T_max) : %.2f °C\n• Mean Temp (T_avg) : %.2f °C\n• Temp Rise (\\DeltaT)   : +%.2f °C', ...
                diag_result.T_max, diag_result.T_mean, diag_result.delta_T));

            % Affected Area Card
            set(txt_area, 'String', sprintf('Affected Surface: %.1f %%', diag_result.affected_area_pct));

            % Recommendation Card
            set(txt_rec, 'String', diag_result.recommendation);

            update_log(sprintf('✓ Complete! Condition: %s (Severity: %s)', diag_result.defect_type, diag_result.severity));

        catch ME
            errordlg(sprintf('Processing Error: %s', ME.message), 'Detection Failed');
            update_log(sprintf('Error: %s', ME.message));
        end

        set(btn_run, 'Enable', 'on');
    end

    function on_plot_iv(~, ~)
        key = app_data.current_key;
        mat_path = fullfile(app_data.elec_dir, [key, '.mat']);
        clean_path = fullfile(app_data.elec_dir, 'Panel1_Clean.mat');

        if ~exist(mat_path, 'file')
            warndlg(sprintf('Electrical data not found for %s:\n%s', key, mat_path), 'No .mat File');
            return;
        end

        update_log(sprintf('Plotting I-V & P-V curves from %s.mat...', key));
        plot_iv_curve(mat_path, clean_path);
    end

    function on_export_report(~, ~)
        if isempty(app_data.diag_result)
            warndlg('Please run detection first before exporting report.', 'Run Detection First');
            return;
        end

        update_log('Exporting automated diagnostic PDF/PNG report...');
        report_path = export_defect_report(app_data.current_key, app_data.IV_aligned, ...
                                           app_data.IT_aligned, app_data.If, ...
                                           app_data.I_annotated, app_data.diag_result);

        update_log(sprintf('✓ Report saved to:\n%s', report_path));
        msgbox(sprintf('Automated Diagnostic Report generated successfully!\n\nLocation:\n%s', report_path), ...
               'Report Exported', 'help');
    end

    function on_browse_custom(~, ~)
        [vl_file, vl_dir] = uigetfile({'*.png;*.jpg;*.jpeg', 'Visual Images (*.png, *.jpg)'}, 'Select Visual (RGB) Image');
        if isequal(vl_file, 0); return; end

        [ir_file, ir_dir] = uigetfile({'*.png;*.jpg;*.jpeg', 'Thermal Images (*.png, *.jpg)'}, 'Select Matching Thermal Image');
        if isequal(ir_file, 0); return; end

        app_data.current_key = 'Custom_Panel_Pair';
        app_data.IV_raw = imread(fullfile(vl_dir, vl_file));
        app_data.IT_raw = imread(fullfile(ir_dir, ir_file));
        app_data.temp_matrix = [];
        app_data.temp_meta = struct('T_min', NaN, 'T_max', NaN, 'T_mean', NaN);

        imshow(app_data.IV_raw, 'Parent', ax1);
        title(ax1, '1. Visual (RGB) [Custom]', 'Color', [0.75, 0.85, 0.95], 'FontSize', 10.5, 'FontWeight', 'bold');

        imshow(app_data.IT_raw, 'Parent', ax2);
        title(ax2, '2. Thermal (IR) [Custom]', 'Color', [1.0, 0.70, 0.50], 'FontSize', 10.5, 'FontWeight', 'bold');

        cla(ax3); axis(ax3, 'off');
        cla(ax4); axis(ax4, 'off');
        set(txt_defect, 'String', 'Custom Pair Loaded', 'ForegroundColor', [0.7, 0.8, 0.9]);
        update_log('Custom image pair loaded. Click "Run Full Detection" to analyze.');
    end

    function update_log(msg)
        set(txt_log, 'String', msg);
        drawnow;
    end
end
