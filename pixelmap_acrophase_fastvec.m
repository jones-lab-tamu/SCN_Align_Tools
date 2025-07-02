function [acrophase_map, rel_phase_map] = pixelmap_acrophase_fastvec(original, num_frames_per_day, thresh_prctile)
% PIXELMAP_ACROPHASE_FASTVEC
% Fast, fully vectorized version: computes per-pixel acrophase using
% linear Fourier regression.
%
% INPUTS:
%   original           - [pixels x frames] data matrix
%   num_frames_per_day - assumed period in frames (e.g., 96)
%   thresh_prctile     - percentile to threshold low-signal pixels
%
% OUTPUTS:
%   acrophase_map      - absolute acrophase in frames [0,T)
%   rel_phase_map      - mean-centered, wrapped relative phase [-T/2,T/2]

    % --- Reshape to image stack ---
    [n, m] = size(original);
    dimension = sqrt(n);
    if mod(dimension, 1) ~= 0
        error('Number of pixels must form a square.');
    end

    conv_image = zeros(dimension, dimension, m);
    for t = 1:m
        frameData = original(:, t);
        reshapedFrame = reshape(frameData, [dimension, dimension]);
        conv_image(:, :, t) = reshapedFrame';
    end

    % --- Build time basis ---
    t = (1:m)';
    omega = 2 * pi / num_frames_per_day;
    cos_vec = cos(omega * t);
    sin_vec = sin(omega * t);
    X = [ones(m,1), cos_vec, sin_vec];  % [m x 3]

    % --- Flatten to [m x n_pix] ---
    Y = reshape(conv_image, [], m)';  % [m x n_pix]

    % --- Apply max intensity threshold ---
    [max_intensity, ~] = max(conv_image, [], 3);
    threshold_value = prctile(max_intensity(:), thresh_prctile);
    valid_mask = max_intensity(:) >= threshold_value;

    % --- Fit only valid pixels ---
    Y_valid = Y(:, valid_mask);

    % --- Least squares fit ---
    B = X \ Y_valid;  % [3 x n_valid]
    a = B(2, :);
    b = B(3, :);

    % --- Compute absolute phase ---
    phi = atan2(-b, a);  % radians
    phi(phi < 0) = phi(phi < 0) + 2*pi;  % wrap to [0,2pi)
    phase_frames = phi / omega;  % convert to frames

    % --- Store in map ---
    acrophase_map = nan(dimension^2, 1);
    acrophase_map(valid_mask) = phase_frames;
    acrophase_map = reshape(acrophase_map, [dimension, dimension]);

    % --- Mean-center and wrap relative ---
    rel_phase_map = acrophase_map - mean(acrophase_map(:), 'omitnan');
    rel_phase_map = mod(rel_phase_map + num_frames_per_day/2, num_frames_per_day) - num_frames_per_day/2;

    % --- Plot absolute ---
    figure;
    imagesc(acrophase_map, [0 num_frames_per_day]);
    colorbar; colormap(viridis);
    title('Absolute Acrophase Map');
    xlabel('X'); ylabel('Y'); axis image;

    % --- Plot relative ---
    figure;
    imagesc(rel_phase_map, 'AlphaData', ~isnan(rel_phase_map));
    caxis([-num_frames_per_day/4 num_frames_per_day/4]);  % +/- 6 hr for 24 hr cycle
    colormap(centered('Spectral')); colorbar;
    title('Mean-Centered Relative Acrophase Map');
    xlabel('X'); ylabel('Y'); axis image;

end
