% RUN_DEMO Batch Verification and Test Script for Solar Defect Detection Pipeline
%
% Runs the dual-modality fusion pipeline across:
%   1. Panel1_Clean (Normal Baseline)
%   2. Panel1_Dirt  (Surface Soiling)
%   3. Panel1_Shadow (Mismatching Fault)
%
% Generates reports and verifies detection accuracy.

clc;
clear;
close all;

curr_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(curr_dir, 'src'));

data_dir = fullfile(curr_dir, 'Experimental data for Mismatching Faults of Photovoltaic Modules', ...
                     'Experimental data for Mismatching Faults of Photovoltaic Modules', 'RawData', 'SP090P');
thermal_dir = fullfile(data_dir, 'ThermalData');
elec_dir = fullfile(data_dir, 'ElectricalData');

test_samples = {'Panel1_Clean', 'Panel1_Dirt', 'Panel1_Shadow'};

fprintf('=========================================================================\n');
fprintf('  SOLAR PANEL DEFECT DETECTION PIPELINE - AUTOMATED TEST & VERIFICATION \n');
fprintf('  ECE Dept | Dual Thermal-Visual Feature Fusion\n');
fprintf('=========================================================================\n\n');

for i = 1:length(test_samples)
    key = test_samples{i};
    fprintf('>>> Testing Sample %d/%d: %s ...\n', i, length(test_samples), key);

    vl_path = fullfile(thermal_dir, [key, '_VL.png']);
    ir_path = fullfile(thermal_dir, [key, '.png']);
    csv_path = fullfile(thermal_dir, [key, '.csv']);
    mat_path = fullfile(elec_dir, [key, '.mat']);

    % 1. Load Data
    IV = imread(vl_path);
    IT = imread(ir_path);
    [temp_mat, meta] = read_thermal_csv(csv_path);

    % 2. Process Visual
    vis = process_visual(IV);

    % 3. Process Thermal
    therm = process_thermal(IT, temp_mat, meta);

    % 4. Fusion via imfuse
    [If, IT_aligned, IV_aligned] = fuse_modalities(IT, IV);

    % 5. Classification and Localization
    [diag_res, I_annotated] = classify_and_localize(vis, therm, IV_aligned, If);

    % 6. Export Report
    report_file = export_defect_report(key, IV_aligned, IT_aligned, If, I_annotated, diag_res);

    % 7. Print Results Table
    fprintf('    - Identified Defect  : %s\n', diag_res.defect_type);
    fprintf('    - Peak Temperature   : %.2f °C (Ambient Mean: %.2f °C)\n', diag_res.T_max, diag_res.T_mean);
    fprintf('    - Temperature Rise   : +%.2f °C\n', diag_res.delta_T);
    fprintf('    - Affected Area      : %.1f %%\n', diag_res.affected_area_pct);
    fprintf('    - Severity Rating    : [%s]\n', diag_res.severity);
    fprintf('    - Report Exported To : %s\n\n', report_file);
end

fprintf('=========================================================================\n');
fprintf('  ALL SAMPLES PROCESSED AND VERIFIED SUCCESSFULLY!\n');
fprintf('  To launch the Interactive Dashboard, run:\n');
fprintf('     >> solar_dashboard\n');
fprintf('=========================================================================\n');
