function [therm_features] = process_thermal(IT, temp_matrix, meta)
% PROCESS_THERMAL Thermal Branch Processing for Solar Panel Thermography
%
% Steps:
%   1. Map thermal temperatures from CSV or thermal colormap
%   2. Calculate thermal statistics: T_max, T_min, T_mean, Delta_T
%   3. Detect Hotspot regions (temperature exceeding ambient + threshold)
%   4. Locate peak hotspot coordinates
%
% Output:
%   therm_features - struct containing temperature maps, hotspot masks, and metrics

    [H, W, C] = size(IT);
    if C == 3
        IT_gray = rgb2gray(IT);
    else
        IT_gray = IT;
    end

    % 1. Calibrated Temperature Map
    if nargin >= 2 && ~isempty(temp_matrix) && ismatrix(temp_matrix) && ~all(isnan(temp_matrix(:)))
        % Interpolate 80x60 matrix to match image size HxW
        T_map = imresize(temp_matrix, [H, W], 'bilinear');
        T_min = meta.T_min;
        T_max = meta.T_max;
        T_mean = meta.T_mean;
    else
        % Thermal image intensity-based estimation (calibrated to nominal 25C - 65C range)
        norm_val = double(IT_gray) / 255.0;
        T_min = 30.0;
        T_max = 62.0;
        T_map = T_min + norm_val * (T_max - T_min);
        T_mean = mean(T_map(:));
    end

    % Inner region mask to ignore ambient boundary / camera background
    margin_y = round(H * 0.08);
    margin_x = round(W * 0.08);
    panel_mask = false(H, W);
    panel_mask(margin_y:H-margin_y, margin_x:W-margin_x) = true;

    panel_temps = T_map(panel_mask);
    actual_T_max = max(panel_temps);
    actual_T_min = min(panel_temps);
    actual_T_mean = mean(panel_temps);
    delta_T = actual_T_max - actual_T_mean;

    % 2. Hotspot Segmentation
    % Hotspot criterion: T > T_mean + 7°C or > 52°C
    hotspot_thresh = max(actual_T_mean + 7.5, 52.0);
    hotspot_mask = (T_map >= hotspot_thresh) & panel_mask;
    hotspot_mask = bwareaopen(hotspot_mask, 30);
    hotspot_mask = imclose(hotspot_mask, strel('disk', 3));

    % 3. Find Peak Hotspot Coordinate
    [max_val, max_idx] = max(T_map(:) .* double(panel_mask(:)));
    [peak_r, peak_c] = ind2sub([H, W], max_idx);

    % Build output struct
    therm_features = struct();
    therm_features.IT_gray = IT_gray;
    therm_features.T_map = T_map;
    therm_features.T_min = actual_T_min;
    therm_features.T_max = actual_T_max;
    therm_features.T_mean = actual_T_mean;
    therm_features.delta_T = delta_T;
    therm_features.hotspot_mask = hotspot_mask;
    therm_features.hotspot_area_ratio = sum(hotspot_mask(:)) / sum(panel_mask(:));
    therm_features.peak_hotspot_coord = [peak_c, peak_r]; % [X, Y]
    therm_features.peak_temp = max_val;
end
