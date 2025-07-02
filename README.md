# SCN_Align_Tools

A minimal starter kit for:
- Pseudo-anatomy extraction from time series.
- Manual SCN masking.
- Landmark-based affine registration.
- Standardized phase map warping and batch processing.

## Included files

- `reshape_time_series.m`: Reshape [pixels x time] into [X x Y x T].
- `get_pseudo_anatomy.m`: Make pseudo-anatomical image (mean/max/std).
- `select_scn_mask.m`: Draw polygon mask on pseudo image.
- `pick_landmarks.m`: Open cpselect for slice landmarks vs reference.
- `align_to_reference.m`: Warp phase map with affine transform.
- `batch_align.m`: Process multiple slices, mask, landmark, warp, and save.
- `reference_SCN.png`: Placeholder standard template.


# SCN Phase Map + Alignment Workflow

This README explains how to process a single SCN slice from a `[pixels × time]` matrix all the way to a **mean-centered phase map**, aligned to a **reference SCN** template.

---

## 1) Reshape your time series

Convert your `original` matrix to a `[X × Y × T]` stack:

```matlab
conv_image = reshape_time_series(original);
```

**Example:**  
```
conv_image  -->  [50 × 50 × n_frames]
```

---

## 2) Compute fast acrophase & relative phase map

Use the vectorized Fourier version for speed and clarity:

```matlab
% Extract absolute acrophase and mean-centered relative phase
[acrophase_map, rel_phase_map] = pixelmap_acrophase_fastvec(original, num_frames_per_day, thresh_prctile);
```

**Outputs:**  
- `acrophase_map` = raw phase in frames  
- `rel_phase_map` = mean-centered, wrapped to [-T/2, T/2]

---

## 3) Build a pseudo-anatomy image

Since you don’t have a raw brightfield, generate one from the time series:

```matlab
pseudo_img = get_pseudo_anatomy(conv_image, 'max');
```

**Tip:** `'max'`, `'mean'`, or `'std'` — choose whichever shows your SCN shape clearest.

---

## 4) Draw your SCN mask

Use your pseudo image to draw the mask:

```matlab
scn_mask = select_scn_mask(pseudo_img);
```

Apply the mask to the phase map:

```matlab
rel_phase_map(~scn_mask) = NaN;
```

---

## 5) Pick landmarks

Load your standard reference SCN template:

```matlab
ref_image = imread('reference_SCN.png');
[movingPoints, fixedPoints] = pick_landmarks(pseudo_img, ref_image);
```

The `cpselect` GUI will open.  
Pick **2–3 clear anatomical landmarks** (e.g., dorsal tip, optic chiasm corners).  
When done, **export** `movingPoints` and `fixedPoints` from the GUI.

---

## 6) Align your relative phase map

Warp the masked phase map to match the reference SCN grid:

```matlab
aligned_rel_phase = align_to_reference(rel_phase_map, movingPoints, fixedPoints, ref_image);
```

---

## 7) Plot the aligned result

```matlab
figure;
imagesc(aligned_rel_phase, [-num_frames_per_day/4, num_frames_per_day/4]); % Example: +/- 6hr for T = 24hr
colormap(centered('Spectral')); colorbar;
axis image;
title('Aligned Relative Phase');
```

---

## 8) Save your results

```matlab
save('aligned_SCN_example.mat', ...
    'aligned_rel_phase', 'rel_phase_map', 'acrophase_map', ...
    'scn_mask', 'movingPoints', 'fixedPoints');
```

---

## Notes

- Always use the same `reference_SCN.png` for all slices for consistency.
- Save `movingPoints` and `fixedPoints` for reproducibility.
- For multiple slices, repeat this workflow and stack `aligned_rel_phase` maps for group-level stats and visualizations.

**Done!** Now you have a robust single-slice pipeline from raw time series to aligned relative phase.
