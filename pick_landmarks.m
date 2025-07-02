function [movingPoints, fixedPoints] = pick_landmarks(moving_image, fixed_image)
% PICK_LANDMARKS - Open cpselect for manual landmark picking.
% Auto-normalizes both images for safe display.

    % Safely normalize to [0,1] if not already
    moving_image = mat2gray(moving_image);
    fixed_image = mat2gray(fixed_image);

    % Open cpselect GUI
    cpselect(moving_image, fixed_image);

    % Use GUI to pick points.
    % Export movingPoints & fixedPoints in GUI.
end