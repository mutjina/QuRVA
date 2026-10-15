# Upstream provenance and local compatibility fixes

Source: https://github.com/tamim4rtinez/QuRVA_modified_segmentation
Retrieved 2026-10-15; main resolved to 40568a4a86cd363e14f0619ece9a77aeb37ff375.
Original QuRVA: https://github.com/javimazzaf/QuRVA .
License: GPL-3.0, retained in qurva/LICENSE and project root LICENSE.

Local fixes:
- localCoherence.m: initialize empty branch/window arrays with explicit column
  dimensions, so absent branches/windows produce undefined summaries and an
  empty window table rather than indexing/dimension errors.
- statsFromQuRVA_v2.m, radialTopology.m, localCoherence.m: use
  struct2table(..., 'AsArray', true). Scalar structs with mixed-length text
  fields otherwise fail for a single image or a single radial bin.

The app passes shared settings explicitly instead of depending on inconsistent
upstream defaults. Radius zero is mapped to Inf before passing to upstream
functions, to implement the guide's advertised include-all-vessels mode.
No other upstream scientific definitions are intentionally changed.
