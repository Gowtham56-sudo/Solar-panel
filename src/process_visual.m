function [vis_features] = process_visual(IV)
% PROCESS_VISUAL Ultra-Fast Visual Branch Processing for Solar Panel Images
%
% Optimized for high-speed real-time execution in MATLAB Dashboard.
%
% Output:
%   vis_features - struct containing processed images and feature metrics

    % Normalize resolution to standard 480x640 for high-speed filtering (< 0.05s)
    target_H = 480;
    target_W = 640;
    if size(IV, 1) ~= target_H || size(IV, 2) ~= target_W
        IV = imresize(IV, [target_H, target_W]);
    end

    if size(IV, 3) == 3
        IV_gray = rgb2gray(IV);
    else
        IV_gray = IV;
    end

    % 1. Fast Contrast Enhancement (CLAHE)
    IV_enhanced = adapthisteq(IV_gray, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');

    % 2. Fast Canny Edge Detection
    IV_edges = edge(IV_enhanced, 'Canny', [0.08, 0.25]);

    % Inner panel surface mask (remove frame borders)
    [H, W] = size(IV_gray);
    margin_y = round(H * 0.06);
    margin_x = round(W * 0.06);
    inner_mask = false(H, W);
    inner_mask(margin_y:H-margin_y, margin_x:W-margin_x) = true;

    cell_edges = IV_edges & inner_mask;

    % 3. Surface Crack Detection (connected line components)
    crack_candidates = bwareaopen(cell_edges, 15);
    edge_density = sum(crack_candidates(:)) / sum(inner_mask(:));

    % 4. Fast Shading / Shadow Detection
    norm_gray = mat2gray(IV_gray);
    mean_val = mean(norm_gray(inner_mask));
    shadow_mask = (norm_gray < (mean_val - 0.20)) & inner_mask;
    shadow_mask = imopen(shadow_mask, strel('disk', 4));
    shadow_mask = bwareaopen(shadow_mask, 150);

    % 5. Fast Dust / Dirt Texture Analysis using fast local variance filter
    texture_std = stdfilt(norm_gray, ones(5, 5));
    dirt_mask = (texture_std > 0.12) & ~shadow_mask & inner_mask;
    dirt_mask = bwareaopen(dirt_mask, 80);

    % Build output struct
    vis_features = struct();
    vis_features.IV_gray = IV_gray;
    vis_features.IV_enhanced = IV_enhanced;
    vis_features.IV_edges = cell_edges;
    vis_features.crack_candidates = crack_candidates;
    vis_features.shadow_mask = shadow_mask;
    vis_features.dirt_mask = dirt_mask;
    vis_features.edge_density = edge_density;
    vis_features.shadow_area_ratio = sum(shadow_mask(:)) / sum(inner_mask(:));
    vis_features.dirt_area_ratio = sum(dirt_mask(:)) / sum(inner_mask(:));
end
