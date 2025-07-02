function pseudo_img = get_pseudo_anatomy(conv_image, method)
% GET_PSEUDO_ANATOMY - Make pseudo anatomy image from time series.
% method: 'mean', 'max', or 'std'

    switch lower(method)
        case 'mean'
            pseudo_img = mean(conv_image, 3);
        case 'max'
            pseudo_img = max(conv_image, [], 3);
        case 'std'
            pseudo_img = std(conv_image, 0, 3);
        otherwise
            error('Unknown method: use mean, max, or std.');
    end

    figure; imagesc(pseudo_img); axis image; colormap gray;
    title(['Pseudo Anatomy: ', method]);
end
