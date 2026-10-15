# QuRVA

English MATLAB desktop app for single-image modified QuRVA analysis.

## Run

In MATLAB, open this project folder and run:

```matlab
addpath(fullfile(pwd,'src'));
app = runQuRVA;
```

1. **Open TIFF**: single-page grayscale or RGB integer TIFF. Indexed TIFFs are expanded to RGB.
2. **Draw boundary**: double-click to finish the retinal polygon. Drag vertices to edit.
3. **Set optic nerve**: click inside the retinal boundary; drag the point to edit.
4. **Analysis settings**: enter the ORIGINAL TIFF pixel size (um/pixel), from acquisition metadata or a scale bar. For RGB, choose the channel containing vessels under Analysis channel. Initial selection is Red (the original QuRVA convention); no specific display color is required.
5. **Preview**: green is retained skeleton; magenta is excluded large vessels. Radius cutoff zero includes all vessels. Adjust settings and preview again as needed.
6. **Analyze**: result menus become enabled with an unread `*`. Opening each result removes its star. Hover over result column names for English definitions and units.
7. **Save results**: choose a parent folder, normally output/.

The interface uses circled step numbers. Image / Global / Radial / Coherence / Windows navigation labels are centered. Settings or region edits disable result menus and clear their unread stars until a new analysis completes.

Top workflow action buttons are taller and use larger bold text than the compact result-navigation buttons.

Open TIFF and Save results remember their most recently successful input/output parent folders separately, including after restarting the app. Preferences are stored in the MATLAB user preferences, outside the project. Canceling a dialog does not change them; a missing remembered folder falls back to the current working folder.

**Save settings / Load settings** reuse all numeric settings and the analysis-channel preference via JSON. Settings persist when another image is opened. Always verify the pixel size and channel for the new acquisition; saved settings do not include an image's boundary or optic nerve position. These values are starting examples, not validated defaults; there is no Reset defaults button.

The initial Large-vessel radius (um) is 50 and Pixel size (um/pixel) is 2.8986, as requested. Verify the pixel size against the acquisition scale. Loading settings applies the saved values instead.

Settings/ROI/channel changes invalidate earlier results. Hover over a setting label for its English explanation; there are no separate question-mark icons. The Analysis settings heading is centered. Initial values are guide examples, not universal validated defaults. Pixel size starts at the user-specified 2.8986 um/pixel; verify it for the acquisition scale. Multi-page stacks are not supported. No tuft analysis or model training is included. Computation uses temporary work folders; Save results creates the persistent export.

## Dependencies and build

Verified environment: MATLAB R2026b, Image Processing Toolbox, Statistics and Machine Learning Toolbox, Signal Processing Toolbox, Curve Fitting Toolbox, MATLAB Compiler.

Run `smokeQuRVA` to exercise UI construction and synthetic-image analysis. Real-image validation against the modified MATLAB workflow remains required.

During review, run the app directly in MATLAB using the commands above. Do not rebuild executables for intermediate changes. Existing executable/build artifacts have been removed at the user's request.

Once the final version is complete, `buildQuRVA` can build into output/build/. Recipients will need matching MATLAB Runtime, not a MATLAB license. Standalone execution requires separate verification before distribution.

The current user-requested Windows build is in `output/release/QuRVA.exe`; the shareable package is `output/QuRVA-Windows.zip`. It includes the executable, startup instructions, GPL license/attribution, matching source archive and executable checksum. MATLAB Runtime R2026b (Windows 64-bit) is required. Execution on a separate Runtime-only computer remains unverified.

Windows builds use the GUI application target (no console window). The startup entry point waits until the application window closes, and the window starts maximized. Startup progress/errors are recorded in `%TEMP%\QuRVA-startup.log`; if initialization fails, an English dialog identifies that log.

## Exports

- qurva_capillary_stats.csv: 51 columns, one row per image.
- radial_topology.csv: 24 columns, one row per radial bin.
- local_coherence_bins.csv: 10 columns, one row per radial bin.
- local_coherence_windows.csv: 5 columns, one row per overlapping analysis window.
- settings.json: settings, source image path, MATLAB/app version, scale factor, original retinal polygon vertices and optic nerve center coordinates.
- preview.png (RGB uint8, maximum side 4096): vessel skeleton overlay.

Save results writes exactly these six files. Intermediate masks, skeleton MAT files, session.mat and QC subfolders remain internal and are not copied to the export. Existing exports are not modified. ROI coordinates are recorded for reproducibility; loading ROI positions back into the app is not yet supported.

Preview display/export uses the analysis grid to avoid oversized full-resolution RGB double arrays and PNG byte-limit failures. Original-image ROI coordinates and quantitative analysis scaling are retained. App error dialogs use English; underlying localized diagnostics are retained in the temporary QuRVA-errors.log file instead of being shown directly.

Retinal masks are rasterized at the original image dimensions, independent of the displayed preview resolution. The optic nerve is checked against the polygon in the same original coordinates. Missing text values appear as blank cells and numeric NaNs remain `NaN`; raw result data is preserved. Column help stays above the table's independent scroll area, so it remains visible when inspecting columns far to the right.

Result tables use the MATLAB app background and a matching text palette. Coherence bins with `nTiles = 0` have undefined (`NaN`) summaries. Windows lists eligible overlapping local analysis windows, not image crops; if none qualify, the table is empty and the UI explains which settings to check. Increasing window size or reducing minimum branches/length changes eligibility and scientific interpretation; do not tune only to eliminate NaNs. Verify pixel size first.

Overlapping windows are not independent biological replicates. Upstream global junction counts group connected junction pixels; radial counts count junction pixels directly. These definitions are currently preserved.

## Structure

- src/: UI, analysis adapter, build and smoke entry points.
- src/vendor/qurva/: upstream modified QuRVA code and license.
- data/: input/research images; keep private research data out of Git.
- output/: generated results, logs and build artifacts (ignored by Git).
- PROJECT_NOTES.md: status, decisions and remaining work.

## Attribution

Original: https://github.com/javimazzaf/QuRVA (Javier Mazzaferri and Santiago Costantino et al.).
Modified: https://github.com/tamim4rtinez/QuRVA_modified_segmentation .
Retrieved main commit: 40568a4a86cd363e14f0619ece9a77aeb37ff375.
Paper: https://www.nature.com/articles/s41598-018-22251-7 .
GPL-3.0; see LICENSE and upstream source notices. Local compatibility fixes are documented in src/vendor/UPSTREAM.md.

