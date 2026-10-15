function [diag_result, I_annotated] = classify_and_localize(vis_features, therm_features, IV_aligned, If)
% CLASSIFY_AND_LOCALIZE Defect Classification, Localization, and Severity Rating
%
% Robust against any dimension variations between modalities.

    [H, W, ~] = size(IV_aligned);

    % Base image for annotation
    I_annotated = IV_aligned;

    % Ensure all masks match the exact [H, W] resolution
    sh_mask = ensure_mask_size(vis_features.shadow_mask, H, W);
    dt_mask = ensure_mask_size(vis_features.dirt_mask, H, W);
    hot_mask = ensure_mask_size(therm_features.hotspot_mask, H, W);
    crk_mask = ensure_mask_size(vis_features.crack_candidates, H, W);

    % Combined defect candidates
    combined_mask = sh_mask | dt_mask | hot_mask;

    % Decision Tree Classification Logic
    delta_T = therm_features.delta_T;
    T_max = therm_features.T_max;
    shadow_ratio = sum(sh_mask(:)) / (H * W);
    dirt_ratio = sum(dt_mask(:)) / (H * W);
    edge_density = vis_features.edge_density;

    defect_type = 'Clean / Normal';
    severity = 'LOW';
    severity_color = [0.1, 0.75, 0.2]; % Green
    recommendation = 'Panel operating normally within standard thermal tolerances. Periodic routine monitoring recommended.';
    boxes = {};
    labels = {};

    % Rule 1: Shadow / Partial Mismatching Fault
    if shadow_ratio > 0.05
        defect_type = 'Shadow / Shading Mismatch';
        if delta_T > 9.0 || shadow_ratio > 0.20
            severity = 'HIGH';
            severity_color = [1.0, 0.45, 0.0]; % Orange
            recommendation = 'Significant partial shading detected causing reverse bias heating. Remove physical obstructions and verify bypass diodes.';
        else
            severity = 'MEDIUM';
            severity_color = [0.95, 0.75, 0.0]; % Yellow
            recommendation = 'Partial shading identified. Relocate obstruction or tilt array to eliminate recurrent shadow.';
        end
        
        shadow_stats = regionprops(sh_mask, 'BoundingBox', 'Area');
        for k = 1:length(shadow_stats)
            if shadow_stats(k).Area > 200
                boxes{end+1} = shadow_stats(k).BoundingBox; %#ok<AGROW>
                labels{end+1} = sprintf('SHADOW: %.1f%% Area', (shadow_stats(k).Area / (H*W))*100); %#ok<AGROW>
            end
        end

    % Rule 2: Hotspot Fault
    elseif (delta_T >= 8.0 && therm_features.hotspot_area_ratio > 0.003) || T_max > 54.0
        defect_type = 'Hotspot / Cell Overheating';
        if delta_T > 12.0 || T_max > 57.0
            severity = 'CRITICAL';
            severity_color = [0.9, 0.1, 0.1]; % Red
            recommendation = 'Critical localized thermal hotspot. High risk of EVA browning / backsheet burn-through. Isolate string and replace cell/module immediately.';
        else
            severity = 'HIGH';
            severity_color = [1.0, 0.45, 0.0];
            recommendation = 'Active hotspot detected. Check for localized shading, solder joint degradation, or defective bypass diode.';
        end

        hot_stats = regionprops(hot_mask, 'BoundingBox', 'Area');
        for k = 1:length(hot_stats)
            if hot_stats(k).Area > 15
                boxes{end+1} = hot_stats(k).BoundingBox; %#ok<AGROW>
                labels{end+1} = sprintf('HOTSPOT: %.1f °C', T_max); %#ok<AGROW>
            end
        end

    % Rule 3: Dust / Dirt Accumulation (Soiling)
    elseif dirt_ratio > 0.03 || (dirt_ratio > 0.015 && delta_T >= 3.0)
        defect_type = 'Dust / Dirt Accumulation';
        severity = 'MEDIUM';
        severity_color = [0.95, 0.75, 0.0];
        recommendation = 'Surface soiling / dirt accumulation detected. Schedule pressurized demineralized water cleaning to restore generation efficiency.';

        dirt_stats = regionprops(dt_mask, 'BoundingBox', 'Area');
        for k = 1:length(dirt_stats)
            if dirt_stats(k).Area > 100
                boxes{end+1} = dirt_stats(k).BoundingBox; %#ok<AGROW>
                labels{end+1} = 'DIRT / SOILING'; %#ok<AGROW>
            end
        end

    % Rule 4: Surface Crack / Scratch
    elseif edge_density > 0.030
        defect_type = 'Surface Crack / Micro-Crack';
        severity = 'HIGH';
        severity_color = [1.0, 0.45, 0.0];
        recommendation = 'Physical micro-crack / glass fracture detected. Monitor for moisture ingress and perform electroluminescence (EL) test.';

        crack_stats = regionprops(crk_mask, 'BoundingBox', 'Area');
        for k = 1:length(crack_stats)
            if crack_stats(k).Area > 40
                boxes{end+1} = crack_stats(k).BoundingBox; %#ok<AGROW>
                labels{end+1} = 'CRACK'; %#ok<AGROW>
            end
        end
    end

    % If no bounding boxes created for a flagged defect, place box around hotspot peak
    if isempty(boxes) && ~strcmp(defect_type, 'Clean / Normal')
        pk = therm_features.peak_hotspot_coord;
        % scale coordinate if needed
        pk_x = min(W - 40, max(40, round(pk(1))));
        pk_y = min(H - 40, max(40, round(pk(2))));
        boxes{1} = [pk_x - 35, pk_y - 35, 70, 70];
        labels{1} = sprintf('%s (%.1f °C)', defect_type, T_max);
    end

    % Render Annotations
    try
        if ~isempty(boxes)
            rect_mat = vertcat(boxes{:});
            if strcmp(severity, 'CRITICAL') || strcmp(severity, 'HIGH')
                box_color = 'red';
            else
                box_color = 'yellow';
            end
            I_annotated = insertShape(I_annotated, 'Rectangle', rect_mat, 'LineWidth', 3, 'Color', box_color);
            text_pos = [rect_mat(:,1), max(1, rect_mat(:,2) - 22)];
            I_annotated = insertText(I_annotated, text_pos, labels, 'FontSize', 14, ...
                'BoxColor', box_color, 'BoxOpacity', 0.85, 'TextColor', 'black');
        end

        pk = therm_features.peak_hotspot_coord;
        pk_x = min(W, max(1, round(pk(1))));
        pk_y = min(H, max(1, round(pk(2))));
        I_annotated = insertShape(I_annotated, 'FilledCircle', [pk_x, pk_y, 4], 'Color', 'cyan');
        I_annotated = insertShape(I_annotated, 'Circle', [pk_x, pk_y, 12], 'LineWidth', 2, 'Color', 'cyan');
    catch
        % Fallback if vision toolbox throws
    end

    total_affected_ratio = max([shadow_ratio, dirt_ratio, therm_features.hotspot_area_ratio]);

    % Build diagnostic result struct
    diag_result = struct();
    diag_result.defect_type = defect_type;
    diag_result.severity = severity;
    diag_result.severity_color = severity_color;
    diag_result.recommendation = recommendation;
    diag_result.T_max = T_max;
    diag_result.T_min = therm_features.T_min;
    diag_result.T_mean = therm_features.T_mean;
    diag_result.delta_T = delta_T;
    diag_result.affected_area_pct = round(total_affected_ratio * 100, 1);
    diag_result.peak_coord = [pk_x, pk_y];
    diag_result.num_defects = length(boxes);
end

function out_mask = ensure_mask_size(in_mask, H, W)
    if isempty(in_mask)
        out_mask = false(H, W);
    elseif size(in_mask, 1) ~= H || size(in_mask, 2) ~= W
        out_mask = imresize(in_mask, [H, W], 'nearest') > 0.5;
    else
        out_mask = in_mask;
    end
end
