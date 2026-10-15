function [report_path] = export_defect_report(panel_name, IV_aligned, IT_aligned, If, I_annotated, diag_result)
% EXPORT_DEFECT_REPORT Automated Diagnostic Report Generator
%
% Implements automated maintenance report generation requirement
% as defined in project presentation (Slides 4, 8, 9, 10).
%
% Output:
%   report_path - Full path to exported report image (PNG/PDF)

    reports_dir = fullfile('d:\Solar-panel', 'reports');
    if ~exist(reports_dir, 'dir')
        mkdir(reports_dir);
    end

    timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
    safe_name = regexprep(panel_name, '[^a-zA-Z0-9_-]', '_');
    report_filename = sprintf('Solar_Diagnostic_Report_%s_%s.png', safe_name, timestamp);
    report_path = fullfile(reports_dir, report_filename);

    % Create Off-Screen Figure for Report Generation
    fig_report = figure('Visible', 'off', 'Color', [0.98, 0.98, 1.0], ...
                        'Position', [50, 50, 1100, 1300], 'PaperPositionMode', 'auto');

    % 1. Header Banner
    annotation('rectangle', [0.03, 0.90, 0.94, 0.08], 'FaceColor', [0.08, 0.22, 0.40], 'EdgeColor', 'none');
    annotation('textbox', [0.05, 0.935, 0.90, 0.04], 'String', 'EXCEL ENGINEERING COLLEGE (AUTONOMOUS) - DEPARTMENT OF ECE', ...
        'FontSize', 14, 'FontWeight', 'bold', 'Color', [1, 1, 1], 'EdgeColor', 'none', 'HorizontalAlignment', 'center');
    annotation('textbox', [0.05, 0.905, 0.90, 0.03], 'String', 'SOLAR PANEL DEFECT DETECTION & DIAGNOSTIC REPORT (MATLAB FUSION PIPELINE)', ...
        'FontSize', 12, 'Color', [0.85, 0.92, 1.0], 'EdgeColor', 'none', 'HorizontalAlignment', 'center');

    % 2. Metadata Box
    annotation('rectangle', [0.03, 0.82, 0.94, 0.065], 'FaceColor', [0.92, 0.94, 0.98], 'EdgeColor', [0.8, 0.85, 0.92]);
    meta_str = sprintf('Panel ID: %s   |   Inspection Date: %s   |   Analysis Method: Dual Thermal-Visual Feature Fusion', ...
        strrep(panel_name, '_', ' '), datestr(now, 'dd-mmm-yyyy HH:MM:SS'));
    annotation('textbox', [0.05, 0.83, 0.90, 0.045], 'String', meta_str, ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.1, 0.15, 0.25], 'EdgeColor', 'none');

    % 3. Image Grid (4 Modalities)
    % Quadrant 1: Visual Image
    subplot('Position', [0.06, 0.58, 0.41, 0.21]);
    imshow(IV_aligned);
    title('(A) Visual (RGB) Inspection', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.1, 0.2, 0.3]);

    % Quadrant 2: Thermal Image
    subplot('Position', [0.53, 0.58, 0.41, 0.21]);
    imshow(IT_aligned);
    title(sprintf('(B) Thermal Thermography (T_{max}: %.1f °C)', diag_result.T_max), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.7, 0.1, 0.1]);

    % Quadrant 3: Fused Image
    subplot('Position', [0.06, 0.33, 0.41, 0.21]);
    imshow(If);
    title('(C) imfuse Thermal-Visual Composite', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.1, 0.4, 0.2]);

    % Quadrant 4: Final Annotated Detection
    subplot('Position', [0.53, 0.33, 0.41, 0.21]);
    imshow(I_annotated);
    title('(D) Defect Localization & Bounding Boxes', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.6, 0.1, 0.6]);

    % 4. Diagnostic Summary Table & Score Card
    annotation('rectangle', [0.03, 0.16, 0.94, 0.14], 'FaceColor', [1, 1, 1], 'EdgeColor', [0.75, 0.8, 0.88], 'LineWidth', 1.2);
    annotation('textbox', [0.05, 0.26, 0.90, 0.03], 'String', 'DIAGNOSTIC SUMMARY & THERMAL METRICS', ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.08, 0.22, 0.40], 'EdgeColor', 'none');

    diag_text = {
        sprintf('• Primary Defect Identified : %s', diag_result.defect_type), ...
        sprintf('• Peak Temperature (T_max)  : %.2f °C  (Ambient Mean: %.2f °C)', diag_result.T_max, diag_result.T_mean), ...
        sprintf('• Temperature Rise (\\Delta T)   : +%.2f °C', diag_result.delta_T), ...
        sprintf('• Affected Panel Surface    : %.1f %%', diag_result.affected_area_pct), ...
        sprintf('• Severity Rating           : [%s]', diag_result.severity)
    };
    annotation('textbox', [0.06, 0.165, 0.60, 0.095], 'String', diag_text, ...
        'FontSize', 11, 'Color', [0.15, 0.20, 0.30], 'EdgeColor', 'none', 'FontName', 'FixedWidth');

    % Severity Color Badge
    sev_box_color = diag_result.severity_color;
    annotation('rectangle', [0.72, 0.175, 0.22, 0.07], 'FaceColor', sev_box_color, 'EdgeColor', 'none');
    annotation('textbox', [0.72, 0.175, 0.22, 0.07], 'String', sprintf('STATUS\n%s', diag_result.severity), ...
        'FontSize', 13, 'FontWeight', 'bold', 'Color', [1, 1, 1], 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'EdgeColor', 'none');

    % 5. Maintenance Recommendation Banner
    annotation('rectangle', [0.03, 0.04, 0.94, 0.10], 'FaceColor', [0.94, 0.97, 0.94], 'EdgeColor', [0.6, 0.8, 0.6]);
    annotation('textbox', [0.05, 0.095, 0.90, 0.035], 'String', 'ENGINEERING MAINTENANCE RECOMMENDATION:', ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.1, 0.5, 0.2], 'EdgeColor', 'none');
    annotation('textbox', [0.05, 0.045, 0.90, 0.05], 'String', diag_result.recommendation, ...
        'FontSize', 11, 'Color', [0.15, 0.2, 0.15], 'EdgeColor', 'none');

    % Save Image
    try
        saveas(fig_report, report_path);
        % Also export PDF version for academic submission
        pdf_path = strrep(report_path, '.png', '.pdf');
        exportgraphics(fig_report, pdf_path, 'ContentType', 'image');
    catch
        print(fig_report, report_path, '-dpng', '-r150');
    end

    close(fig_report);
end
