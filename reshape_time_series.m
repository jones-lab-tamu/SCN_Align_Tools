function conv_image = reshape_time_series(original)
% RESHAPE_TIME_SERIES - Converts [pixels x time] to [X x Y x T] stack.
% Assumes square grid.

    [n_pixels, n_frames] = size(original);
    dimension = sqrt(n_pixels);

    if mod(dimension, 1) ~= 0
        error('Number of pixels must form a square grid. Got %.2f', dimension);
    end

    conv_image = zeros(dimension, dimension, n_frames);

    for t = 1:n_frames
        frameData = original(:, t);
        reshapedFrame = reshape(frameData, [dimension, dimension]);
        conv_image(:, :, t) = reshapedFrame'; % Transpose if ImageJ style
    end
end
