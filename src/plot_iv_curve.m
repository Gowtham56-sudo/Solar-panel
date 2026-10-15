function [elec_summary] = plot_iv_curve(mat_path, clean_baseline_path)
% PLOT_IV_CURVE Plots Current-Voltage (I-V) and Power-Voltage (P-V) Curves
%
% Compares current panel state against Clean baseline to quantify
% power degradation caused by mismatching faults / soiling.
%
% Output:
%   elec_summary - struct with P_max, V_mp, I_mp, efficiency_loss_pct

    elec_summary = struct('P_max', NaN, 'P_clean', NaN, 'loss_pct', NaN, 'IRR', NaN);

    if ~exist(mat_path, 'file')
        warning('Electrical .mat file not found: %s', mat_path);
        return;
    end

    try
        data_curr = load(mat_path);
        V_curr = data_curr.Vpanel(:);
        I_curr = data_curr.Ipanel(:);
        P_curr = V_curr .* I_curr;

        % Subsample for smooth, high-speed rendering (500k -> 2000 points)
        step = max(1, round(length(V_curr) / 2000));
        V_curr_sub = V_curr(1:step:end);
        I_curr_sub = I_curr(1:step:end);
        P_curr_sub = P_curr(1:step:end);

        % Sort by Voltage
        [V_curr_sub, sort_idx] = sort(V_curr_sub);
        I_curr_sub = I_curr_sub(sort_idx);
        P_curr_sub = P_curr_sub(sort_idx);

        % Filter negative / artifact values
        valid_idx = (V_curr_sub >= 0) & (I_curr_sub >= 0);
        V_curr_sub = V_curr_sub(valid_idx);
        I_curr_sub = I_curr_sub(valid_idx);
        P_curr_sub = P_curr_sub(valid_idx);

        [P_max_curr, p_idx] = max(P_curr_sub);
        elec_summary.P_max = P_max_curr;
        elec_summary.V_mp = V_curr_sub(p_idx);
        elec_summary.I_mp = I_curr_sub(p_idx);
        elec_summary.IRR = double(data_curr.IRR);

        has_baseline = false;
        if nargin >= 2 && exist(clean_baseline_path, 'file')
            data_clean = load(clean_baseline_path);
            V_clean = data_clean.Vpanel(:);
            I_clean = data_clean.Ipanel(:);
            P_clean = V_clean .* I_clean;

            V_clean_sub = V_clean(1:step:end);
            I_clean_sub = I_clean(1:step:end);
            P_clean_sub = P_clean(1:step:end);

            [V_clean_sub, s_idx] = sort(V_clean_sub);
            I_clean_sub = I_clean_sub(s_idx);
            P_clean_sub = P_clean_sub(s_idx);

            v_idx = (V_clean_sub >= 0) & (I_clean_sub >= 0);
            V_clean_sub = V_clean_sub(v_idx);
            I_clean_sub = I_clean_sub(v_idx);
            P_clean_sub = P_clean_sub(v_idx);

            [P_max_clean, ~] = max(P_clean_sub);
            elec_summary.P_clean = P_max_clean;
            elec_summary.loss_pct = max(0, ((P_max_clean - P_max_curr) / P_max_clean) * 100);
            has_baseline = true;
        end

        % Create Figure
        fig = figure('Name', 'Electrical Performance Analysis (I-V & P-V Curves)', ...
                     'Color', [0.12, 0.14, 0.18], 'Position', [200, 200, 950, 480]);

        [~, panel_name, ~] = fileparts(mat_path);

        % Subplot 1: I-V Curve
        subplot(1, 2, 1);
        hold on;
        grid on;
        set(gca, 'Color', [0.18, 0.20, 0.25], 'XColor', [0.8, 0.85, 0.9], 'YColor', [0.8, 0.85, 0.9]);
        if has_baseline
            plot(V_clean_sub, I_clean_sub, 'g--', 'LineWidth', 2, 'DisplayName', 'Clean Baseline');
        end
        plot(V_curr_sub, I_curr_sub, 'r-', 'LineWidth', 2.5, 'DisplayName', strrep(panel_name, '_', ' '));
        xlabel('Voltage V (Volts)', 'FontSize', 12, 'Color', [0.9, 0.9, 0.9]);
        ylabel('Current I (Amperes)', 'FontSize', 12, 'Color', [0.9, 0.9, 0.9]);
        title('Current - Voltage (I-V) Characteristic', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [1, 1, 1]);
        legend('Location', 'southwest', 'TextColor', [0.9, 0.9, 0.9], 'Color', [0.25, 0.27, 0.32]);

        % Subplot 2: P-V Curve
        subplot(1, 2, 2);
        hold on;
        grid on;
        set(gca, 'Color', [0.18, 0.20, 0.25], 'XColor', [0.8, 0.85, 0.9], 'YColor', [0.8, 0.85, 0.9]);
        if has_baseline
            plot(V_clean_sub, P_clean_sub, 'g--', 'LineWidth', 2, 'DisplayName', sprintf('Clean (P_{max} = %.1f W)', P_max_clean));
        end
        plot(V_curr_sub, P_curr_sub, 'm-', 'LineWidth', 2.5, 'DisplayName', sprintf('Tested (P_{max} = %.1f W)', P_max_curr));
        xlabel('Voltage V (Volts)', 'FontSize', 12, 'Color', [0.9, 0.9, 0.9]);
        ylabel('Power P (Watts)', 'FontSize', 12, 'Color', [0.9, 0.9, 0.9]);
        if has_baseline
            title(sprintf('P-V Curve (Power Loss: %.1f%%)', elec_summary.loss_pct), ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', [1, 0.8, 0.2]);
        else
            title('Power - Voltage (P-V) Characteristic', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [1, 1, 1]);
        end
        legend('Location', 'northwest', 'TextColor', [0.9, 0.9, 0.9], 'Color', [0.25, 0.27, 0.32]);

    catch ME
        warning('Error generating I-V curve: %s', ME.message);
    end
end
