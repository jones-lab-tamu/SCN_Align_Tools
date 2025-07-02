function batch_align(slice_files, ref_image, output_dir)
% BATCH_ALIGN - Processes multiple slices: mask, landmark, align, save.

    n = numel(slice_files);

    for i = 1:n
        fprintf('Processing slice %d of %d...\n', i, n);

        load(slice_files{i}, 'original', 'rel_phase_map');

        % Rebuild conv_image:
        [N, T] = size(original);
        dimension = sqrt(N);
        conv_image = zeros(dimension, dimension, T);
        for t = 1:T
            conv_image(:,:,t) = reshape(original(:,t), [dimension, dimension])';
        end

        % Get pseudo anatomy:
        pseudo_image = get_pseudo_anatomy(conv_image, 'max');function batch_align(slice_files, ref_image, output_dir)
% BATCH_ALIGN - Loop through slices: mask, landmark, align, save.

    n = numel(slice_files);

    for i = 1:n
        fprintf('Processing slice %d of %d...\n', i, n);

        load(slice_files{i}, 'original', 'rel_phase_map');

        conv_image = reshape_time_series(original);

        pseudo_image = get_pseudo_anatomy(conv_image, 'max');

        scn_mask = select_scn_mask(pseudo_image);
        rel_phase_map(~scn_mask) = NaN;

        [movingPoints, fixedPoints] = pick_landmarks(pseudo_image, ref_image);

        aligned_map = align_to_reference(rel_phase_map, movingPoints, fixedPoints, ref_image);

        [~, name, ~] = fileparts(slice_files{i});
        save(fullfile(output_dir, [name '_aligned.mat']), ...
             'aligned_map', 'scn_mask', 'movingPoints', 'fixedPoints');
    end

    fprintf('All slices processed and saved.\n');
end


        % Mask:
        scn_mask = select_scn_mask(pseudo_image);
        rel_phase_map(~scn_mask) = NaN;

        % Pick landmarks:
        [movingPoints, fixedPoints] = pick_landmarks(pseudo_image, ref_image);

        % Align:
        aligned_map = align_to_reference(rel_phase_map, movingPoints, fixedPoints, ref_image);

        % Save:
        [~, name, ~] = fileparts(slice_files{i});
        save(fullfile(output_dir, [name '_aligned.mat']), 'aligned_map', 'scn_mask', 'movingPoints', 'fixedPoints');
    end

    fprintf('All slices processed and saved.\n');
end