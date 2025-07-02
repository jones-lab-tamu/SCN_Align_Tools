function aligned = align_to_reference(map, movingPoints, fixedPoints, ref_image)
% ALIGN_TO_REFERENCE - Warp map to reference using affine transform.

    tform = fitgeotrans(movingPoints, fixedPoints, 'affine');
    ref = imref2d(size(ref_image));
    aligned = imwarp(map, tform, 'OutputView', ref);
end
