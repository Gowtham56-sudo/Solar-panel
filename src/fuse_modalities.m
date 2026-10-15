function [If, IT_aligned, IV_aligned] = fuse_modalities(IT, IV)
% FUSE_MODALITIES Thermal-Visual Image Fusion using MATLAB imfuse
%
% Implements the core fusion method defined in project presentation (Slide 13):
%   IT = imread('thermal_panel.jpg');
%   IV = imread('visual_panel.jpg');
%   Ig = rgb2gray(IV);
%   If = imfuse(IT, Ig, 'blend');
%
% Outputs:
%   If         - Fused RGB composite image highlighting both structural & thermal faults
%   IT_aligned - Thermal image resized to target dimension
%   IV_aligned - Visual image resized to target dimension

    % Standard processing dimension for fast, consistent analysis
    target_H = 480;
    target_W = 640;

    IT_aligned = imresize(IT, [target_H, target_W]);
    IV_aligned = imresize(IV, [target_H, target_W]);

    if size(IV_aligned, 3) == 3
        Ig = rgb2gray(IV_aligned);
    else
        Ig = IV_aligned;
    end

    if size(IT_aligned, 3) == 3
        IT_gray = rgb2gray(IT_aligned);
    else
        IT_gray = IT_aligned;
    end

    % Enhance Ig for structural details
    Ig_enhanced = adapthisteq(Ig, 'ClipLimit', 0.02);

    % PPT Slide 13 Core Fusion:
    % 'blend' combines complementary information: visual edges + thermal heat distributions
    If = imfuse(IT_aligned, Ig_enhanced, 'blend');
end
