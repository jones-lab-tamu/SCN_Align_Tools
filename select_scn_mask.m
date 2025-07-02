function scn_mask = select_scn_mask(pseudo_image)
% SELECT_SCN_MASK - Draw polygon mask for SCN on pseudo anatomy.

    figure; imagesc(pseudo_image); axis image; colormap gray;
    title('Draw SCN polygon');
    h = drawpolygon;
    scn_mask = createMask(h);
    close;
end
