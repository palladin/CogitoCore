# ARC Exploration Notes

## Puzzle 017c7c7b (Easy)
- **Observation**: Inputs are 6×3 stripes; outputs are 9×3 repeats where color `1` becomes `2` and the first three input rows are appended again to reach height 9. Zeros remain zeros.
- **Hypothesis**: Apply a color substitution `1→2`, then output the original rows in sequence until the grid height hits 9 (which means appending the first three rows once more).
- **Next Steps**: Confirm every training example follows the same wraparound, and harden the row-repetition logic to support other possible target heights if variants arise.

## Puzzle 025d127b (Easy)
- **Observation**: Shapes keep their relative geometry but shift one column to the right; nothing wraps around. All non-zero colors (6, 2, 8, 4) translate equally, and zeros stay put.
- **Hypothesis**: For each non-zero pixel, write the same color at `(row, col+1)` if that slot is empty, otherwise the outputs show the target location set regardless of conflicts (no collisions in training), so a simple translation should work.
- **Next Steps**: Implement a uniform right-shift transformation with bounds checking, and guard against underflow when a non-zero pixel already sits at the rightmost column (training never hits that edge, but the test should be checked).

## Puzzle 08ed6ac7 (Easy)
- **Observation**: Color `5` columns become a monotonic gradient: the first column with `5` maps to color `1`, the second to `2`, etc., moving clockwise from left to right then top to bottom. Zeros remain zeros.
- **Hypothesis**: Determine the order in which `5` columns appear (likely reading width-first) and assign them colors `[1,2,3,4]` sequentially. Fill each entire column with the assigned color, leaving other cells intact.
- **Next Steps**: Validate the ordering rule on all training cases and guard against grids with fewer than four columns of `5`.

## Puzzle 0a938d79 (Easy)
- **Observation**: A single colored cell spawns a repeating horizontal stripe alternating between two colors with period 4. The stripe spans the entire row block and replicates vertically for every row below the trigger cell.
- **Hypothesis**: Read the seed color(s) (`2` with partner `8`, `1` with `3`, etc.) from the row containing the non-zero pixel, then tile the entire output rectangle with that alternating pair, starting with the seed column alignment.
- **Next Steps**: Determine the partner color by scanning to the right of the seed (training suggests a specific pair) and make the tiler resilient to different grid widths.

## Puzzle 0dfd9992 (Easy)
- **Observation**: Every input is a 21×21 wallpaper built from a 3-row repeating stripe. The training inputs contain rectangular holes set to `0`, but the non-zero cells still reveal the underlying periodic motif. The corresponding outputs restore the full wallpaper with no gaps, matching the dominant pattern already present.
- **Hypothesis**: Learn the repeating template by taking majority colors for each `(row mod 3, col mod 3)` (or by copying the first complete stripe), then repaint every zero cell with the template's color at that residue class. Non-zero cells remain untouched, so the repair is effectively a tiling fill-in.
- **Next Steps**: Confirm the periodicity on all training pairs, codify a template extractor, and ensure the repair handles cases where an entire stripe is missing (fall back to previously deduced motif).

## Puzzle 0d3d703e (Easy)
- **Observation**: Each example is a 3×3 stripe formed by repeating a single row three times. Outputs mirror the same geometry but with colors permuted; across training pairs the mapping is consistent: `1→5`, `2→6`, `3→4`, `4→3`, `5→1`, `6→2`, `8→9`, `9→8`.
- **Hypothesis**: Derive the color substitution table by pairing every input color with its output counterpart (any cell suffices because the mapping is global). Apply this bijection pointwise to reconstruct the target grid without changing layout.
- **Next Steps**: Generalize the substitution learner to guard against unseen colors (fallback to identity), and verify the test stripe only contains colors covered by the learned permutation.

## Puzzle 10fcaaa3 (Easy)
- **Observation**: Outputs are strict 2× upscales of the inputs: each source row is duplicated consecutively, each column becomes a two-column block, and the newly inserted parity cells alternate color `8` while original colored pixels replicate into the northwest cell of each block.
- **Hypothesis**: Perform a Kronecker product with `[[1,0],[0,1]]` for colored cells and an `8`-filled mask for the inserted slots, effectively doubling both dimensions while weaving an `8` lattice through the negative space.
- **Next Steps**: Formalize the upscale so it preserves the original color in the top-left of each 2×2 expansion, fills other slots with `8`, and validate on the taller test example to ensure row duplication handles odd heights.

## Puzzle 11852cab (Easy)
- **Observation**: Every non-zero column in the input is duplicated one step to the right in the output, yielding paired columns of identical color stacks separated by single zero columns. Existing zero columns remain untouched, so the motif is effectively mirrored to create a “double helix” of the same strokes.
- **Hypothesis**: Detect columns containing any non-zero cell, clone their contents into the immediate neighbor on the right, and leave the rest of the grid unchanged. Handle cases where duplicates would spill past the border by trimming instead of wrapping.
- **Next Steps**: Implement a column duplication pass, confirm that cloning happens exactly once per source column (no cascading), and ensure the algorithm skips already-filled columns to avoid compounding effects.

## Puzzle 178fcbfb (Easy)
- **Observation**: The inputs place isolated seeds of colors `1`, `2`, and `3`. Outputs expand each seed into a full stripe: `3` grows into a complete horizontal line across its row, `1` also spans its row, and `2` floods the column that hosted it, while unaffected rows/columns stay zero.
- **Hypothesis**: For every color, choose an expansion axis (row for `1` and `3`, column for `2`) and fill that entire line with the color of the seed. Multiple seeds of the same color yield redundant strokes that simply overlap.
- **Next Steps**: Encode the color→axis map, add guards to prevent overwriting when different colors intersect (the training pairs show they never clash), and check the test grid for extra colors before expansion.

## Puzzle 1b2d62fb (Easy)
- **Observation**: Each row is dominated by `9`s wrapped around a central column of `1`s, with pockets of zeros at the margins. The outputs condense every row to a length-3 signature (left/mid/right blocks) marking troublesome zero pockets with `8` while leaving all-clear blocks at `0`.
- **Hypothesis**: Partition the columns into three bins around the `1` column, inspect each bin for zeros that remain after trimming leading and trailing `9`s, and emit `8` wherever such a gap exists.
- **Next Steps**: Verify the bin boundaries across all training examples, ensure the zero detection skips the central `1`, and confirm the test case does not introduce additional colors or offset columns.

## Puzzle 1caeab9d (Easy)
- **Observation**: Clusters of `2`, `4`, and `1` consolidate into solid 2-row bands: each color’s bounding box becomes a rectangle two rows tall, while everything else zeros out. Detached groups aligned in different quadrants simply occupy distinct columns inside the same band.
- **Hypothesis**: For every color, extract its minimal bounding box, expand it to height two centered on the original footprint, and paint that rectangle uniformly with the color. Clear all other cells.
- **Next Steps**: Confirm every color has at least two rows available; if the box is only one row tall, duplicate it either upward or downward while staying within bounds.

## Puzzle 1cf80156 (Easy)
- **Observation**: Sparse plus signs compress to their tight bounding boxes—outputs drop all-zero rows/columns and keep only the occupied cross, yielding compact 4×4 or 5×3 schematics that mirror the original layout.
- **Hypothesis**: Crop each grid to the min/max row/col containing non-zero values and return the cropped submatrix without further scaling or recoloring.
- **Next Steps**: Ensure the crop preserves orientation (no rotation), and handle the degenerate case where the grid is already tight by returning it unchanged.

## Puzzle 1f876c06 (Easy)
- **Observation**: Colors slide along a southeast chain: starting from each seed, the output marches it diagonally down-right, moving one step per row until it hits the grid edge. Each subsequent diagonal keeps the same color, so the result is a staircase of shifted copies.
- **Hypothesis**: For every non-zero cell, repeatedly advance it one row down and one column to the right, stamping the color until the move would leave the grid. Leave the original position filled as well.
- **Next Steps**: Decide iteration order when multiple seeds compete (training suggests independent processing) and ensure we accept overlapping trails by letting later passes overwrite zeros only.

## Puzzle 22eb0ac0 (Easy)
- **Observation**: Every row is either blank/paired or contains matching colors at both extremes. When the two edge colors are identical and non-zero, the output fills the entire row with that color; rows with mismatched or zero ends remain unchanged.
- **Hypothesis**: For each row, look at the first and last non-zero value. If they exist and match, broadcast that color across the row; otherwise, copy the row verbatim. The columnar pairs simply persist.
- **Next Steps**: Verify that no row ever contains more than one non-zero at each end (simplifying detection), confirm the behavior when only one edge is non-zero, and test whether similar symmetry shows up in columns in case of rotated variants.

## Puzzle 23581191 (Easy)
- **Observation**: A lone `8` and a lone `7` seed bloom into full crosshairs: the `8`’s column and row become solid `8`s, the `7`’s column and row become solid `7`s, and the orthogonal intersection flips to `2`. The rest of the grid mirrors this plus-shaped scaffold while keeping zeros untouched elsewhere.
- **Hypothesis**: Locate the coordinates of the unique `8` and `7`, paint their columns and rows accordingly, and drop a `2` at each intersection (`8`-row × `7`-column and vice versa). Cells already containing the seed colors retain them.
- **Next Steps**: Confirm there is always exactly one seed of each color, handle the case where the seeds share a row or column (intersection degeneracy), and make sure the repeated rows/columns do not bleed beyond the grid bounds in rectangular variants.

## Puzzle 239be575 (Easy)
- **Observation**: Each grid reduces to a single pixel labeled either `0` or `8`, depending on which color dominates the global layout of `2`s versus `8`s. Training cases favor `8` when the `8` clusters occupy more of the non-zero area or surround key boundaries, and output `0` when the `2`s take that role.
- **Hypothesis**: Count the number of non-zero cells per color (or weight connected-component coverage), then emit `8` when the `8` tally beats the `2` tally, otherwise return `0`. Ties can default to `0`, matching the first example.
- **Next Steps**: Validate the count-based rule over the full training set, test whether component count (instead of raw area) gives better alignment, and gather more samples before hard-coding the tie-breaker.

## Puzzle 25d8a9c8 (Easy)
- **Observation**: Outputs mark whichever rows in the 3×3 input are uniform. Any row composed entirely of one color becomes `5 5 5` in the output, while mixed rows collapse to zeros.
- **Hypothesis**: Scan each row; if all three entries match, replace the row with `5`s, otherwise output zeros. No column logic is involved.
- **Next Steps**: Verify there are never all-zero uniform rows (if they appear, decide whether to keep them zero or promote them), and confirm future puzzles will not demand analogous column-aware behavior.

## Puzzle 25ff71a9 (Easy)
- **Observation**: Every example simply slides the non-zero footprint one row downward, leaving the top row blank and keeping colors intact. Shapes that already touch the bottom row just settle there without wrapping.
- **Hypothesis**: Shift the entire grid down by exactly one row, copy each non-zero cell to `(r+1, c)`, and zero out the first row. Cells that would fall off the board are discarded.
- **Next Steps**: Double-check that no training case places color in the bottom row (to avoid ambiguity), and make sure the implementation handles multiple colors simultaneously without order dependence.

## Puzzle 28e73c20 (Easy)
- **Observation**: Despite blank inputs, outputs always draw a fixed maze-like border of `3`s whose design scales with the grid size. The pattern is deterministic for each dimension.
- **Hypothesis**: Ignore the input values entirely and generate the templated border by index (precompute for each observed size, or derive procedurally from the training masks).
- **Next Steps**: Derive a compact rule for the border (e.g., spiral + mirrored segments) so new grid sizes can be handled without a lookup table, and verify symmetry holds for the large test board.

## Puzzle 2bcee788 (Easy)
- **Observation**: The sparse input blob is replaced by a filled rectangle of the blob’s dominant color, surrounded by a sea of `3`s. The rectangle’s footprint matches the blob’s bounding box.
- **Hypothesis**: Compute the bounding box of all non-zero cells, determine the prevailing color inside, flood that box with the color, and fill every other cell with `3`.
- **Next Steps**: Confirm ties never occur when choosing the dominant color, and extend the logic to handle multiple disjoint blobs if a future case introduces them.

## Puzzle 31aa019c (Easy)
- **Observation**: Among many scattered digits there is always one standout color that occurs exactly once. The output blanks the canvas and replaces only the 3×3 neighborhood (clipped at edges) around that unique cell with a stencil of `2`s surrounding the original color.
- **Hypothesis**: Find the unique-color singleton, stamp a 3×3 template centered there with the center cell equal to the singleton and every ortho/diagonal neighbor set to `2`, clipping where the grid ends.
- **Next Steps**: Verify the uniqueness assumption across all samples and add boundary-aware stamping so edge cases trim cleanly.

## Puzzle 3618c87e (Easy)
- **Observation**: Every grid is the same 5×5 scaffold: a floor of `5`s, a support row that may contain extra `5`s, and one row of suspended `1`s. The solution simply lets each `1` fall vertically until it hits the base row, replacing the `5` beneath it. All other cells—including the mid-level `5`s—stay put.
- **Hypothesis**: For each column, detect a `1` above a run of `5`s and move it to the lowest cell in that column, overwriting the `5` there while clearing the original `1` location.
- **Next Steps**: Implement a column-wise gravity pass that only acts on color `1`, and verify the procedure when multiple `1`s share a column (training never stacks them, but a guard is prudent).

## Puzzle 36fdfd69 (Easy)
- **Observation**: Color `2` forms thick bands bordered by `1`s. The outputs recolor every `1` that touches a `2` (orthogonally) to `4`, leaving solitary `1`s elsewhere unchanged. The effect is a two-tone stripe: `2` cores with `4` edging.
- **Hypothesis**: Scan all `1`s and upgrade any whose von Neumann neighborhood contains a `2` to `4`, keeping the rest as `1`. No other colors are altered.
- **Next Steps**: Code the adjacency check, ensure multiple adjacent `2`s don’t cause repeated work, and verify nothing special happens for diagonal contacts (training shows only orthogonal triggers).

## Puzzle 3906de3d (Easy)
- **Observation**: A block of `1`s hovers above a sparse column containing a few `2`s near the bottom. The output stretches that column of `2`s upward until it meets the underside of the `1` block, filling the intervening cells with `2` while leaving everything else untouched.
- **Hypothesis**: Locate the column containing `2`s, find the highest and lowest occurrences, and fill the entire vertical span between them, stopping if a non-zero blocker appears.
- **Next Steps**: Implement the column fill, add guards for multiple `2` columns (copy each independently), and confirm that the procedure respects any intervening non-zero colors besides `1`.

## Puzzle 39a8645d (Easy)
- **Observation**: Inputs feature several sparse plus-shaped clusters made of a single accent color (`8`, `4`, or `2`) floating in a sea of zeros. The output ignores global positioning and simply reports the canonical 3×3 plus stencil of that accent color, with the center and four arms painted and the corners zeroed.
- **Hypothesis**: Identify which non-zero color appears in plus form (they never mix), then emit the fixed 3×3 template for that color regardless of where the cluster originally sat.
- **Next Steps**: Build a color→template lookup from training, verify only one candidate color appears per puzzle, and fall back to returning the input if no plus is found.

## Puzzle 3bd67248 (Easy)
- **Observation**: Inputs show a solid column of a single color on the far left and nothing elsewhere. Outputs keep that column unchanged, draw a descending anti-diagonal of `2`s from the top-right toward column one, and replace the bottom row (except the first cell) with `4`s.
- **Hypothesis**: For an `n×m` board, preserve column 0, write `2` at `(r, m-1-r)` for rows `0..n-2`, and overwrite row `n-1` columns `1..m-1` with `4`. The diagonal stops one column shy of the left edge, matching the samples.
- **Next Steps**: Parameterize the diagonal and bottom-row fill so they respect non-square grids, and confirm the test case’s dimensions (10×10) follow the same limits.

## Puzzle ba26e723 (Easy)
- **Observation**: Inputs are checkerboard stripes of color `4` and `0`. Outputs recolor the `4`s that sit in columns whose index is congruent to `0 mod 3` (counting from the left) to color `6`, leaving the other `4`s and all zeros untouched. The 6/4/4 rhythm repeats cleanly across every row.
- **Hypothesis**: Iterate through columns, and whenever the column index modulo three is zero, overwrite any `4` in that column with `6`. Keep all other cells as-is; because the grids are purely striped, this recreates the observed alternating pattern without further checks.
- **Next Steps**: Validate against longer widths and ensure the implementation respects zero columns so we do not accidentally recolor padding cells that already equal zero.

## Puzzle bd4472b8 (Easy)
- **Observation**: The top two rows describe a palette: a header row of distinct colors followed by a full row of `5`s acting as a separator. The output keeps those rows and then repeats the header colors downward, converting each column into uniform stripes with the column’s header color cycling in the same order as the header itself.
- **Hypothesis**: Copy the input verbatim through the separator row. For the remaining rows, fill row `r` (starting after the separator) with the header color at index `(r-2) mod header_width`, producing repeating horizontal bands that match the samples.
- **Next Steps**: Confirm behaviour when there are more blank rows than header cells (wrap-around vs truncation), and handle the degenerate two-column case where the separator width matches the header exactly.

## Puzzle bdad9b1f (Easy)
- **Observation**: Inputs show one dominant column of `8`s and one dominant row of `2`s that do not fully extend. Outputs extend the column and row so they span the entire grid, placing the special color `4` exactly at their intersection. Outside the plus sign, the grid remains zero.
- **Hypothesis**: Identify the column occupied by `8`s and fill that entire column with `8`. Do the same for the row containing `2`s. After the fills, overwrite the intersection cell with `4` to match the highlighted junction.
- **Next Steps**: Confirm there is always a single row and column to extend, and add tie-handling in case multiple candidate rows/columns of the same color appear in future puzzles.

## Puzzle c9e6f938 (Easy)
- **Observation**: Each 3×3 input is duplicated horizontally; the right half is just the left half mirrored so the output becomes a 3×6 palindromic strip. Layout and colors inside the original stay untouched.
- **Hypothesis**: Build the answer by concatenating the input with its column-reversed copy (`[input | flip_lr(input)]`). That guarantees the reflected half matches the examples without needing any per-cell logic.
- **Next Steps**: Double-check that every test row uses only colors seen in training (no surprises on the mirrored side) and add a unit test that the mirror routine preserves rectangular inputs.

## Puzzle c9f8e694 (Easy)
- **Observation**: Background `5`s act as placeholders; the output rewrites each `5` run with the row’s leading non-zero color (the first value encountered scanning left-to-right). Zeros and other colors remain exactly where they were.
- **Hypothesis**: For each row, grab the first non-zero entry and repaint every `5` in that row with that color. Leave cells that are already non-zero (and not 5) untouched.
- **Next Steps**: Verify that every row really has a non-zero seed before the `5`s start; if not, fall back to leaving the `5`s alone. Add regression coverage for rows that host multiple disjoint `5` segments.

## Puzzle cce03e0d (Easy)
- **Observation**: The 3×3 input tile is reused verbatim inside a 3×3 block grid (9×9 canvas). Each placement corresponds exactly to a cell in the input that contains the color `2`; other cells contribute nothing.
- **Hypothesis**: Iterate over the 3×3 input, and whenever the value is `2`, paste the whole tile into the matching 3×3 block of the 9×9 output (same row/column index). Leave all other blocks zero.
- **Next Steps**: Confirm multiple placements simply overwrite the same content (they should agree) and add a guard for the edge case where no `2` appears—returning an all-zero board.

## Puzzle ce22a75a (Easy)
- **Observation**: Every `5` acts like a seed for a 3×3 block of ones. The outputs simply superimpose those 3×3 patches (clipped at the borders); overlapping regions stay filled with `1`s.
- **Hypothesis**: For each coordinate equal to `5`, add a 3×3 stencil of `1`s centred on that cell. Combine stencils by logical OR so overlaps don’t change the value.
- **Next Steps**: Implement the stencil writer with boundary checks, and confirm overlapping seeds in the training set never require anything other than `1` in the union.

## Puzzle ce4f8723 (Easy)
- **Observation**: The upper block (rows 0–3) encodes a binary mask with `1`s, the lower block (rows 5–8) encodes a second mask with `2`s, and row 4 of `4`s is just a separator. The output is the logical OR of those two masks rendered in color `3`.
- **Hypothesis**: Convert the top block to a boolean mask, convert the bottom block by treating `2` as true, OR them cell-wise, and write `3` wherever the result is true (else `0`).
- **Next Steps**: Guard against stray non-zero values in the separator row and add a sanity check that the two masks are the same shape before combining.

## Puzzle d037b0a7 (Easy)
- **Observation**: Each 3×3 input already contains a monotone corner path of colors. The transformation fills the missing cells by propagating the last seen non-zero color downward and to the right, producing a lower-triangular cascade like `[0,0,6; 0,4,6; 3,4,6]`.
- **Hypothesis**: Scan the grid row-wise; whenever a zero is encountered, copy the nearest non-zero among its north or west neighbors (preferring the west value when both exist). Iterating this rule left-to-right, top-to-bottom reproduces the completed staircase in every sample.
- **Next Steps**: Validate the propagation order (west before north) with a quick script and ensure diagonally isolated colors still flow correctly into the southeast corner.

## Puzzle d06dbe63 (Easy)
- **Observation**: A lone `8` sits inside an otherwise empty 13×13 board. The output stamps a symmetric star of `5`s around that `8`, drawing orthogonal arms and short diagonals while keeping the rest zero.
- **Hypothesis**: Locate the single `8`, then paint a fixed stencil: a plus-shaped ring and its diagonals composed of `5`s, with the `8` untouched at the center. Because the board is blank elsewhere, this stencil alone yields the target image.
- **Next Steps**: Extract the exact stencil offsets from the training trio and assert the same template matches the test case regardless of where the `8` lies.

## Puzzle d0f5fe59 (Easy)
- **Observation**: Sparse clusters of `8`s shrink to small identity matrices: the number of clusters determines the output size, and the diagonal is filled with `8` while all off-diagonal cells stay zero.
- **Hypothesis**: Count connected components of `8` in the input. Create an `n×n` zero matrix where `n` is the component count, then place `8` along the main diagonal. That exactly matches each training input/output pair.
- **Next Steps**: Confirm the component counter treats diagonally touching `8`s as separate clusters (4-connectivity) and check the held-out puzzle to ensure the cluster count equals five.

## Puzzle d10ecb37 (Easy)
- **Observation**: Regardless of board size, the answer is always the top-left 2×2 block copied verbatim. The wider grid just tiles that quadrant repeatedly.
- **Hypothesis**: Crop rows `[0..1]` and columns `[0..1]` and return the 2×2 submatrix unchanged. No additional recoloring is required.
- **Next Steps**: Add a guard to confirm the input dimensions are at least 2×2 and, if larger grids appear later, verify the crop still suffices.

## Puzzle d23f8c26 (Easy)
- **Observation**: Only one column per puzzle survives. The solver zeros every other column but preserves the original values in the column that held the strongest vertical signal (the one with multiple non-zero entries aligned).
- **Hypothesis**: Identify the column whose non-zero count exceeds one (or the leftmost such column when there are several) and copy that column into the output, leaving all other columns zeroed.
- **Next Steps**: Validate the column-selector rule on all training grids and confirm there are no cases with two equally populated columns requiring a different tie-break.

## Puzzle c1d99e64 (Easy)
- **Observation**: Every grid contains an all-zero row and an all-zero column that carve the canvas into blocks. The solution turns that blank cross into a highlight by repainting the entire row and column with color `2`, leaving every other cell untouched.
- **Hypothesis**: Locate the unique all-zero row and column, repaint them with `2`, and return the updated grid. For inputs with multiple zero rows/columns, select the one that simultaneously intersects both halves (i.e., the separator between dense regions).
- **Next Steps**: Verify that the test data always has a single qualifying row/column pair and add a sanity check to avoid recoloring grids that already contain `2` in other places.

## Puzzle c3e719e8 (Easy)
- **Observation**: A 3×3 input tile is replicated three times along both axes with zero padding between copies, yielding a 9×9 output whose three block-columns and block-rows each contain the original tile in exactly one position.
- **Hypothesis**: Build a 3×3 block matrix; place the source tile on the main diagonal slots (top-left, middle, bottom-right) and fill the remaining cells with zeros. Concatenate the blocks to reach 9×9.
- **Next Steps**: Confirm that every training example truly uses three repeats (no rotated variants) and that the input tile is always 3×3 so we can avoid parameterising the block size.

## Puzzle c444b776 (Easy)
- **Observation**: A vertical column (or pair) of `4`s acts as a mirror axis. Every non-zero pixel off the axis is duplicated to the symmetric position across that column, producing paired motifs while preserving the axis itself.
- **Hypothesis**: Identify the mirror column(s) filled with `4`. For each non-zero elsewhere, reflect it horizontally about the axis and write the same color on the partner cell. Skip cells that already hold that color to avoid double writes.
- **Next Steps**: Confirm how to handle pixels already on the far side (do they stay put or get duplicated back) and make sure the code gracefully handles even vs. odd grid widths.

## Puzzle c59eb873 (Easy)
- **Observation**: Outputs are 2× enlargements of the inputs—every source cell becomes a 2×2 block of the same color, so rows and columns both double in length without inserting new colors.
- **Hypothesis**: Perform a Kronecker product with a 2×2 matrix of ones: duplicate each row, and inside each row duplicate every element horizontally to build the 2× upscale.
- **Next Steps**: Ensure the scaler handles rectangular inputs and confirm there’s no requirement to insert separators or special padding in unseen tests.

## Puzzle c8f0f002 (Easy)
- **Observation**: The only change between input and output is that every `7` turns into `5`; all other colors stay untouched and positions are identical.
- **Hypothesis**: Apply a global color substitution `7→5` and leave all other values unchanged.
- **Next Steps**: Sanity-check that no training case ever contains `5` in the input (to avoid conflating original `5`s), and verify the test set doesn’t introduce extra colors needing remaps.

## Puzzle a2fd1cf0 (Easy)
- **Observation**: Each scene contains a single `2` and a distant `3`. Outputs connect them with a right-angled pipeline of `8`s: run horizontally from the `2` toward the `3`’s column, then vertically until the `3`’s row, leaving the endpoints untouched.
- **Hypothesis**: Identify the coordinates of the lone `2` and `3`. Draw an orthogonal path that first steps along columns (respecting the observed ordering) until the column matches the `3`, then proceed row-wise, filling traversed cells with `8` unless one endpoint already occupies them.
- **Next Steps**: Verify the preferred “horizontal then vertical” ordering matches all cases, and ensure paths never cross other non-zero colors (if they do, decide whether to overwrite or stop early).

## Puzzle a416b8f3 (Easy)
- **Observation**: Every output is simply two horizontal copies of the input stitched side by side. No colors change, and the height remains identical.
- **Hypothesis**: Concatenate each row with itself to double the width while preserving row order, producing a `[row | row]` tiling.
- **Next Steps**: Guard against inputs that already repeat (so we do not accidentally quadruple them), and confirm no vertical duplication is ever required.

## Puzzle 3befdf3e (Easy)
- **Observation**: Two colors are present: a surrounding “frame” and an interior blob that never touches the outer boundary. Outputs crop to that interior blob’s bounding box and recolor its non-zero cells with the frame color, effectively shrinking and recoloring the inner component.
- **Hypothesis**: Identify the connected component whose bounding box is strictly interior, slice that subgrid, and replace the component’s color with the frame color while leaving zeros untouched. Return the cropped slice so all external padding disappears.
- **Next Steps**: Verify the interior color is unique, handle cases where multiple interior components exist, and ensure recoloring does not bleed into background zeros.

## Puzzle 3c9b0459 (Easy)
- **Observation**: Every output matches the input rotated 180°—rows appear in reverse order and each row’s entries are reversed. Colors and relative placements stay exactly the same after the flip.
- **Hypothesis**: Implement a 180° rotation by reversing the row order and reversing each row in place. No color remapping or scaling is required.
- **Next Steps**: Add a helper that performs the double reversal, confirm it preserves rectangular grids, and include a regression test that round-tripping twice returns the original grid.

## Puzzle 3f7978a0 (Easy)
- **Observation**: Non-zero pixels occupy only a handful of rows and columns. The solution squeezes out every all-zero row and column while leaving the remaining rows/columns in order, producing a compact tile that keeps the original relative layout of `5`s and `8`s.
- **Hypothesis**: Collect the index set of rows and columns that contain any non-zero entry, then rebuild the grid using those indices in ascending order. This projection removes empty space but preserves the pattern of non-zero cells.
- **Next Steps**: Implement row/column filtering, handle the degenerate all-zero case gracefully, and add a check that the compressed grid reproduces the training outputs exactly.

## Puzzle 4258a5f9 (Easy)
- **Observation**: Each isolated `5` in the sparse grid blossoms into a 3×3 patch whose outer ring is `1` while the center remains `5`. Disjoint seeds yield disjoint flowers; blanks stay untouched.
- **Hypothesis**: For every `5`, stamp a fixed 3×3 template centered on that coordinate with `5` in the middle and `1`s on the orthogonal and diagonal neighbors, clipping at borders.
- **Next Steps**: Ensure the template application skips cells that were already non-zero (to avoid blending overlapping flowers) and add regression checks for seeds near edges.

## Puzzle 42a50994 (Easy)
- **Observation**: Every row may contain multiple copies of the same non-zero color. The output keeps only the leftmost occurrence of each color per row and zeros out the others, so each row hosts at most one marked cell for any given hue.
- **Hypothesis**: Scan each row left-to-right, retain the first sighting of each color, and rewrite subsequent sightings of that color to `0`.
- **Next Steps**: Decide whether zeros created this way can later be reused by other colors (they should), confirm behavior when two different colors alternate, and add a guard that already-unique rows pass through unchanged.

## Puzzle 445eab21 (Easy)
- **Observation**: Inputs always hold two large rectangular blobs of different colors. The output collapses the scene to a 2×2 solid block whose color matches the blob with the larger area.
- **Hypothesis**: Label connected components, measure their sizes, pick the largest, and emit a 2×2 matrix filled with its color.
- **Next Steps**: Handle ties deterministically (e.g., choose the topmost color), verify components are always disjoint rectangles, and confirm the approach still works when more than two blobs appear.

## Puzzle 44f52bb0 (Easy)
- **Observation**: Each 3×3 input sprinkles a handful of `2`s on black background; whenever that footprint is perfectly mirrored left-to-right the output is a single red `1`, and when the layout is lopsided the lone cell turns orange `7` instead.
- **Hypothesis**: Ignore the zeros, reflect the occupied cells across the vertical axis, and compare; emit `1` if the two masks match exactly, otherwise emit `7`.
- **Next Steps**: Double-check behaviour for degenerate cases (all zeros, only the centre set), and make sure horizontal symmetry or rotations do not accidentally trigger the “balanced” verdict.

## Puzzle 46442a0e (Easy)
- **Observation**: Small coloured matrices expand to twice their width and height with a perfectly mirrored tiling—the input pattern repeats, mirrors horizontally, then the resulting strip mirrors vertically to form a 4×4 or 6×6 symmetric quilt.
- **Hypothesis**: Produce the horizontal reflection of the input, concatenate original + mirror for each row, then mirror that doubled slab vertically for the final stack.
- **Next Steps**: Verify the procedure handles non-square inputs, ensure shared centre rows/columns aren’t duplicated twice, and check whether colour palettes ever require special treatment.

## Puzzle 484b58aa (Easy)
- **Observation**: Huge patterned grids deliberately contain swaths of zero columns/rows breaking an otherwise periodic wallpaper; the target strips those blank seams and returns the underlying repeating motif intact.
- **Hypothesis**: Identify columns (and matching rows) filled entirely with zeros, remove them, and emit the trimmed matrix—what remains already holds the seamless tile.
- **Next Steps**: Confirm no legitimate motif columns are all-zero, keep row/column removals in sync so the pattern stays square, and test whether multiple zero seams appear back-to-back.

## Puzzle 496994bd (Easy)
- **Observation**: Tall grids begin with a stack of coloured rows followed by empty space; the answer copies those leading non-zero rows, reverses their order, and appends the mirror stack at the bottom while leaving the original top intact.
- **Hypothesis**: Find the contiguous band of non-zero rows from the top, then append its reverse to the bottom (preserving zeros in between) so the palette reappears in opposite order.
- **Next Steps**: Handle cases with interspersed non-zero rows deeper in the grid, decide whether fully blank inputs remain unchanged, and confirm the reversal keeps duplicate colours collapsed correctly.

## Puzzle 49d1d64f (Easy)
- **Observation**: Small matrices grow by a one-cell frame; the interior remains untouched, side borders repeat the nearest edge values, and the four corners are zeroed to keep the frame from wrapping around.
- **Hypothesis**: Embed the original array inside a padded grid, copy the first and last rows/columns outward into the new border, and explicitly set the four corner cells to `0`.
- **Next Steps**: Define behaviour when the source already contains zeros on its edges, ensure non-rectangular padding (e.g., 1×n) still works, and check that corner zeros never clobber meaningful data.

## Puzzle 4c4377d9 (Easy)
- **Observation**: Each 3×4 source is echoed twice vertically: first in reverse row order, then in its original order, producing a 6-row stack with the original layout sitting in the lower half.
- **Hypothesis**: Build the output by concatenating `reverse(rows)` with the untouched row list, effectively creating a vertical palindrome.
- **Next Steps**: Confirm the rule generalises to taller inputs, ensure horizontal mirroring is never required, and handle the edge case where reversing duplicate rows leaves the grid unchanged.

## Puzzle 50cb2852 (Easy)
- **Observation**: Each solid-colour rectangle gains an inset of `8`s—effectively carving out its interior while the original colour remains as a border—regardless of whether the block is built from `1`, `2`, or `3`.
- **Hypothesis**: Detect maximal rectangles of a single colour, fill their interior (rows/columns excluding the perimeter) with `8`, and leave the outer ring untouched.
- **Next Steps**: Handle thin rectangles where no interior exists, decide how nested rectangles should interact, and ensure adjacent regions of the same colour are not merged accidentally.

## Puzzle 54d82841 (Easy)
- **Observation**: The inputs already contain plus-shaped “antennae” that stay untouched, while the output appends a brand-new row of `4`s directly below each plus centre, one per active column.
- **Hypothesis**: Identify the column indices where a vertical limb of the plus exists, then, if the canvas has spare room, populate the bottom row at those columns with `4` while leaving the original structure unchanged.
- **Next Steps**: Handle cases where a plus sits flush with the bottom (no room to add a marker), coalesce duplicate columns when multiple pluses share the same centre, and make sure the routine does not overwrite pre-existing non-zero cells in the last row.

## Puzzle 5582e5ca (Easy)
- **Observation**: Every 3×3 vignette collapses to a homogeneous colour—the hue that appears most often in the input—yielding a solid patch regardless of the non-majority pixels around it.
- **Hypothesis**: Count the frequency of each non-zero colour (optionally treat zeros as candidates), pick the modal one with a deterministic tie-break, and fill the entire grid with that colour.
- **Next Steps**: Decide whether zeros participate in the vote, settle on a tie-breaking rule (e.g., highest colour id or first-seen), and double-check the counts on the provided training cases.

## Puzzle 5614dbcf (Easy)
- **Observation**: The 9×9 boards decompose into nine 3×3 macro-cells; the solution compresses them into a 3×3 summary where each cell reports the dominant non-zero colour of its corresponding block (leaving `0` when the block is empty).
- **Hypothesis**: Partition the grid into a 3×3 tiling, tally colours inside each macro-cell, and emit either the winning colour or zero if no non-zero pixels are present.
- **Next Steps**: Verify ties never arise once stray `5`s are ignored, enforce that inputs are indeed multiples of three, and confirm zeros in a macro-cell propagate as zeros in the compressed output.

## Puzzle 5bd6f4ac (Easy)
- **Observation**: Every output is just the 3×3 submatrix formed by the three rightmost columns of the input—the area where all salient digits cluster.
- **Hypothesis**: Identify the last three non-empty columns, crop those columns across all rows for a tight 3×3 view, and return the crop unchanged.
- **Next Steps**: Double-check that the “rightmost three” heuristic holds when trailing columns are all zero, and guard against cases where the interesting block is wider than three columns.

## Puzzle 5daaa586 (Easy)
- **Observation**: Inputs feature a vertical column of `3`s paired with a column of `8`s plus intermittent bands of `1`s and `2`s. The output crops away the zero-heavy margins, retaining only the columns spanned by the non-zero data and presenting them as a compact strip where each row mirrors the original colour sequence from `3` to `8`.
- **Hypothesis**: Scan the input row-wise, locate the first and last non-zero column indices per row, and emit that slice trimmed of surrounding zeros, preserving the order of colours encountered between the `3` spine and the `8` rail.
- **Next Steps**: Confirm that every row has at most one contiguous non-zero run, decide how to treat rows that are entirely zero between the anchors, and ensure the cropping width stays consistent across all rows in the reconstructed strip.

## Puzzle 6150a2bd (Easy)
- **Observation**: The solver simply rotates the input 180°—rows and columns both reverse—yielding a central symmetry across the grid.
- **Hypothesis**: Reverse the row order and reverse each row in place to achieve a half-turn rotation, leaving colours otherwise unchanged.
- **Next Steps**: Guard against rectangular inputs that may appear later, and confirm the routine is idempotent (two applications restore the original state).

## Puzzle 623ea044 (Easy)
- **Observation**: A solitary non-zero pixel radiates along both diagonals to draw an “X” of the same colour, continuing outward until the pattern hits the board edges and producing a symmetric hourglass.
- **Hypothesis**: Locate the seed, iterate along the four diagonal directions, and paint those cells with the seed colour while keeping all orthogonal directions at zero.
- **Next Steps**: Check the behaviour when the seed sits off-centre (the diagonals should still reach the corners), and confirm multiple seeds do not appear in hidden tests.

## Puzzle 62c24649 (Easy)
- **Observation**: The 3×3 input tiles expand into a 6×6 quilt made of four reflections: the original block anchors the top-left quadrant, while the other quadrants mirror it horizontally, vertically, and both.
- **Hypothesis**: Construct a 2× upscaled board where each quadrant is filled by the original matrix after applying the appropriate reflections (none, horizontal flip, vertical flip, both), ensuring seams align.
- **Next Steps**: Verify the reflections handle asymmetric colour layouts and confirm the process extends cleanly if the source grid is not square.

## Puzzle 6430c8c4 (Easy)
- **Observation**: Each input is two aligned 4×4 masks separated by a row of `4`s: a top mask of `7`/`0` and a bottom mask of `2`/`0`. Outputs are 4×4 grids of `3`s exactly at the coordinates where both masks contain `0` in the same row/column.
- **Hypothesis**: Iterate rows `i=0..3`, find columns where the top row has `0` and the corresponding bottom row also has `0`, and drop `3` there; leave everything else `0`. Training examples all follow this per-row intersection rule.
- **Next Steps**: Confirm the alignment in code (top rows map to bottom rows directly, middle row of `4`s is ignored) and double-check the test scene, which should simply place `3`s at the shared zero coordinates.

## Puzzle 67385a82 (Easy)
- **Observation**: Sparse `3` components live on a zero background. In the outputs, every component whose size ≥2 is recoloured entirely to `8`, while singleton `3`s stay as `3`. The training grids all follow that size-based flip.
- **Hypothesis**: Run a connected-component labelling on colour `3`, measure the cell count, recolour components with size >1 to `8`, and leave components of size 1 untouched.
- **Next Steps**: Confirm there are no overlapping components (so recolouring is independent), and ensure the test set doesn’t introduce size-1 clusters sharing diagonals that might confuse the labeller.

## Puzzle 67a3c6ac (Easy)
- **Observation**: Every output is the horizontal mirror image of the corresponding input—each row is reversed while columns and colours are otherwise unchanged.
- **Hypothesis**: Implement a simple left-right flip (`reverse(row)`) for every row to reproduce the training outputs.
- **Next Steps**: Verify the mirror works for the rectangular 7×7 example and the 3×3 test grid, keeping an eye out for ties where reversing leaves the row unchanged.

## Puzzle 67e8384a (Easy)
- **Observation**: Each 3×3 seed grows into a 6×6 quilt with fourfold symmetry: the input block, its horizontal mirror, vertical mirror, and double mirror occupy the four quadrants, and the middle rows/columns are duplicated to stitch the seams.
- **Hypothesis**: Build the 6×6 by first tiling the input and its horizontal mirror into a 3×6 strip, then stack that strip with its vertical mirror to reach 6×6.
- **Next Steps**: Ensure the mirroring order preserves the centre alignment (duplicate the middle row/column once, not twice) and verify with the training quartet before applying to the test grid.

## Puzzle 68b16354 (Easy)
- **Observation**: Outputs are the inputs reflected over a horizontal axis—row order reverses, while columns stay in place. Colours and patterns otherwise match verbatim.
- **Hypothesis**: Reverse the list of rows for each grid (i.e., apply a vertical flip) without altering row contents.
- **Next Steps**: Implement a simple row reversal and add a guard so the routine is idempotent (double-flip restores the original board).

## Puzzle 6cf79266 (Easy)
- **Observation**: Each wallpaper of `5`s contains a rectangular 3×3 cavity of zeros bracketed by `5` bands. The solution plugs that cavity with `1`s, stamping a solid 3×3 block exactly where the void sits, while leaving the rest of the pattern untouched.
- **Hypothesis**: Scan for zero regions surrounded orthogonally by `5`s, confirm it is a 3×3 window, and overwrite it with `1` in place.
- **Next Steps**: Add detection for multiple cavities (just in case), guard against cavities touching the border, and ensure the algorithm ignores stray zeros that are not fully enclosed.

## Puzzle 6d0aefbc (Easy)
- **Observation**: Each 3×3 input expands to 3×6 by appending a mirror image: the first three columns reproduce the input row, the last three columns echo the same entries in reverse order. There are no color substitutions.
- **Hypothesis**: For every row, concatenate the original row with its reversal so the output width doubles while remaining palindromic.
- **Next Steps**: Double-check that future examples never introduce wider inputs or demand vertical mirroring, then codify the row-wise reflection.

## Puzzle 6d75e8bb (Easy)
- **Observation**: Big patches of `8` contain scattered zeros. The transformation turns those interior zeros into `2`s whenever they lie fully surrounded by `8`s, effectively shading the holes while leaving the outer perimeter untouched.
- **Hypothesis**: Within every `8` component, classify zero cells whose four neighbours are `8` (or part of the same component) and recolor them to `2`; preserve exterior zeros that border the background.
- **Next Steps**: Implement a component-based interior test (e.g., BFS plus boundary flag) so only enclosed zeros flip, and run it on the test board where corridors of `8`s snake around.

## Puzzle 6e82a1ae (Easy)
- **Observation**: Everything non-zero starts as color `5`. Outputs recolor each connected component with a distinct label (`1`, `2`, or `3`) while preserving shape, seemingly based on the component’s vertical ordering (upper clusters → `1`, central/right → `2`, lower/left → `3`).
- **Hypothesis**: Segment the `5` components, sort them by centroid (top-to-bottom, tiebreak left-to-right), and assign palette colors in that sorted order.
- **Next Steps**: Confirm the ordering rule across all training cases (especially when components share rows) and make sure the test puzzle has no more than three components; otherwise extend the palette mapping.

## Puzzle 6f8cd79b (Easy)
- **Observation**: Empty grids become hollow rectangles of `8`: the border is `8`, the interior remains `0`, and the border thickness is one cell regardless of original size.
- **Hypothesis**: Fill the outermost row and column coordinates with `8` and leave everything else `0`.
- **Next Steps**: Confirm behaviour on degenerate 1×N or N×1 boards (where the “border” collapses) before implementing the straightforward border fill.

## Puzzle 6fa7a44f (Easy)
- **Observation**: Every 3×3 input is stacked with its vertical mirror to produce six rows—the original three followed by the same rows in reverse order—yielding a vertical palindrome.
- **Hypothesis**: Output the input rows in their original order, then append the list reversed, without altering individual rows.
- **Next Steps**: Confirm the test grid follows the same rule and that no example ever requests additional horizontal mirroring or color changes.

## Puzzle 72ca375d (Easy)
- **Observation**: Only one color survives: the output is the tight bounding box of whichever connected component is largest and most coherent (e.g., the `6` carpet, the `4` square, the `5` ribbon). Other colors vanish entirely.
- **Hypothesis**: Label components, pick the one with maximal area (ties broken by first encountered), crop that component’s bounding box, and return it verbatim (including interior zeros if any) while discarding every other cell.
- **Next Steps**: Confirm the selected component really is the largest across all examples and check edge cases where two blobs share the same size so we know how to break ties deterministically.

## Puzzle 7447852a (Easy)
- **Observation**: A sparse zig-zag of `2`s gains orange `4`s that bridge the gaps: every zero between successive `2`s along rows/columns is recolored to `4`, yielding a repeating `2-4-4-4-2` cadence while untouched zeros remain zero.
- **Hypothesis**: Detect stripes bounded by `2`s in the same row or column and flood the interior cells with `4`, leaving exterior zeros untouched. Repeat until every bounded gap is filled.
- **Next Steps**: Validate that the fill only triggers when both ends are `2` and ensure expansions in long inputs (the test case) still alternate cleanly without leaking past the final `2`.

## Puzzle 7468f01a (Easy)
- **Observation**: Outputs are simply the non-zero content cropped to its minimal rectangle—blank borders disappear, orientation stays intact, and internal zeros (none in the samples) would be preserved if present.
- **Hypothesis**: Compute the min/max row and column containing non-zero values, slice that submatrix, and return it as the answer without further scaling or recoloring.
- **Next Steps**: Implement a generic cropper and confirm it behaves on cases with multiple disjoint blobs (just in case a future instance introduces separated components).

## Puzzle 74dd1130 (Easy)
- **Observation**: Each output is the transpose of its input—rows become columns and vice versa—with no color changes.
- **Hypothesis**: Apply a simple matrix transpose regardless of shape (3×3, 3×4, etc.).
- **Next Steps**: Handle rectangular inputs explicitly and add a regression test so future refactors do not accidentally swap axes twice.

## Puzzle 75b8110e (Easy)
- **Observation**: Eight-by-eight (or similar) canvases collapse to 4×4 tiles where each cell reflects the dominant color in the corresponding 2×2 block of the original grid. Colors never appear outside their source quadrants; zeros remain only when the entire block was empty.
- **Hypothesis**: Partition the input into non-overlapping 2×2 blocks, compute the majority color for each, and emit those votes as the 4×4 output. This matches the observed downsampling while preserving palette distribution (`4`, `5`, `6`, `9`, `0`).
- **Next Steps**: Recompute the training outputs with this pooling scheme to confirm the mapping and decide how to break ties if a 2×2 block mixes four colors evenly.

## Puzzle 7e0986d6 (Easy)
- **Observation**: Inputs mix solid swaths of `3`s with noisy `8`s sprinkled throughout. The outputs simply purge the `8`s, leaving the underlying `3` corridors intact and turning every former `8` pixel into `0`, so only `{0,3}` remain.
- **Hypothesis**: Iterate over the grid, rewrite every `8` to `0`, and leave all other colors untouched—the `3` structure already forms the desired shapes.
- **Next Steps**: Verify there are no other colors that need special handling, ensure adjacent `8`s don’t require post-processing (no gap-filling), and confirm the purged test grid matches the provided target.

## Puzzle 7f4411dc (Easy)
- **Observation**: Each puzzle uses a single accent color (5/6/7/8) with small stray pixels and larger horizontal slabs. The outputs keep only the slabs whose row-wise runs reach length three or more and erase every shorter streak, so whiskers and singletons disappear while the main bars remain.
- **Hypothesis**: Scan every row, measure contiguous segments of the non-zero color, and zero out spans shorter than three cells before copying the survivors into the answer.
- **Next Steps**: Double-check edge cases where wide runs abut via a diagonal (should still be removed) and confirm the test grid contains no vertical-only structures that would erroneously vanish.

## Puzzle 7fe24cdd (Easy)
- **Observation**: The 3×3 inputs expand into 6×6 canvases made from the four rotations of the source tile: the northwest quadrant is the original, northeast is a clockwise rotation, southwest a counter-clockwise rotation, and southeast the 180° flip.
- **Hypothesis**: Generate a 2×2 block of quadrants by stamping the input and its three rotations in that order, ensuring seams coincide exactly with the training mosaics.
- **Next Steps**: Sanity-check that the rotations still work when duplicate colors produce palindromic rows and confirm the same tiling handles the test case without needing further alignment.

## Puzzle 810b9b61 (Easy)
- **Observation**: The grids are mostly `0`s with intricate glyphs in `1`. Whenever the `1`s form a solid 3×3 square, the output recolors that entire square to `3` while leaving all other `1`s untouched; scattered pixels and narrow corridors stay the same.
- **Hypothesis**: Detect 3×3 windows that are fully `1`, write `3` into those nine cells, and copy every other cell verbatim.
- **Next Steps**: Confirm overlapping squares either match perfectly or are disjoint, and ensure diagonal contacts don’t trick the detector into recoloring a partial block.

## Puzzle 82819916 (Easy)
- **Observation**: Non-empty rows start with a short motif (two or three non-zero entries) followed by zeros. The target rows simply continue that motif—repeating the observed cycle across the remaining columns—while rows of pure zeros remain blank.
- **Hypothesis**: For each row, capture the prefix up to the first zero, treat it as the repeating pattern, and tile it across the full width to replace the zeros.
- **Next Steps**: Validate the period detection when the prefix itself contains repeated colors (e.g., `3,3,1`), and handle leftover columns that truncate the final repetition cleanly.

## Puzzle 8a004b2b (Easy)
- **Observation**: Giant canvases contain sparse colored rectangles floating in zeros. The target simply trims away the dead space—the outputs are the minimal axis-aligned bounding boxes that contain every non-zero cell.
- **Hypothesis**: Scan for the min/max row and column indices that host non-zero entries and return that rectangular slice verbatim.
- **Next Steps**: Guard against the all-zero case (should probably return an empty grid or a single zero row) and confirm the cropper keeps interior zero rows intact.

## Puzzle 8be77c9e (Easy)
- **Observation**: Every 3×3 input reappears unchanged on top, and the bottom half is its vertical mirror. Effectively the puzzle builds a 6×3 palindrome of the original rows.
- **Hypothesis**: Concatenate the input with its row list reversed (rows 3,2,1) to compose the output.
- **Next Steps**: Ensure the routine works for arbitrarily tall inputs (always doubling height) and confirm there is no need for horizontal mirroring or color tweaks.

## Puzzle 8e1813be (Easy)
- **Observation**: Inputs are made of wide horizontal stripes separated by zero bands. The solution compresses those stripes into a tiny signature: each distinct horizontal color band becomes one row in the output, filled uniformly with that band’s color.
- **Hypothesis**: Detect contiguous non-zero row runs, map each to its color, and emit a stacked matrix of those colors (optionally trimming zero-only stripes entirely).
- **Next Steps**: Confirm multi-color rows never appear inside a band, decide how to treat repeated colors, and size the output width deterministically (e.g., number of stripe groups or a fixed small constant).

## Puzzle 9172f3a0 (Easy)
- **Observation**: This is a straight 3× upsample. Each input cell becomes a 3×3 block in the output, preserving the original colour for non-zero entries and leaving zero cells blank. The resulting 9×9 grid is just the input blown up with nearest-neighbour copying.
- **Hypothesis**: For every `(r, c)` in the 3×3 source, fill the output slice `[3r..3r+2] × [3c..3c+2]` with that value; zeros naturally produce zero blocks.
- **Next Steps**: Implement the simple block-stamping loop (or a Kronecker product), add quick shape assertions, and write a regression test to confirm all colours upscale as expected.

## Puzzle 94f9d214 (Easy)
- **Observation**: Inputs are two stacked 4×4 motifs: a top half of `3`s in assorted L-shapes and a bottom half of `1`s. The output is a 4×4 mask of `2`s that flags the offsets where the silhouettes differ—corners and edges that exist in one half but not the other light up, while agreements stay at zero.
- **Hypothesis**: Build binary masks for each half (non-zero → 1), take their XOR, and write `2` wherever the XOR is 1. Everything that both halves either share or both omit should remain zero.
- **Next Steps**: Run the XOR idea across all training pairs to ensure the sparse `2` placements match exactly, and confirm test data never mixes additional colours in the halves.

## Puzzle 963e52fc (Easy)
- **Observation**: Short banded patterns repeat horizontally to fill twice the original width—the colourful rows (e.g., `2,8,2,8,...`) are duplicated seamlessly, while the zero rows simply become longer stretches of zeros.
- **Hypothesis**: Concatenate each row with itself until the width doubles (a simple horizontal tiling) and return the enlarged board.
- **Next Steps**: Guard against inputs whose width is already even but not a divisor of the target; otherwise the tiling logic is trivial.

## Puzzle 97999447 (Easy)
- **Observation**: Single coloured seeds sit in otherwise blank rows. The answer extends each seed into a rightward ribbon that alternates between the seed colour and `5`, producing a repeating “colour-5-colour-5” cadence until the row ends. Other rows remain zero.
- **Hypothesis**: For every non-zero pixel, walk to the right writing `seed,5` in alternation, starting with the original cell’s colour and stopping at the grid edge or another non-zero.
- **Next Steps**: Encode the alternating fill with collision checks so overlapping ribbons agree on the shared cells, and add unit tests per colour.

## Puzzle a5313dff (Easy)
- **Observation**: Each input features a hollow frame of `2`s (rectangles or windmills). The solution paints the entire interior cavity with `1`s while leaving the `2` frame – including any inner spokes already present – untouched.
- **Hypothesis**: Treat the `2` structure as a closed polygon, run a flood fill from the outside to identify enclosed zeros, and repaint that interior set to `1`. Any `2`s already inside (such as central crossbars) remain as-is and act as barriers.
- **Next Steps**: Implement hole detection via complement flood fill, confirm there are no leaks in the frame, and be careful to skip cells already occupied by non-zero colours when applying the `1` fill.

## Puzzle a699fb00 (Easy)
- **Observation**: Sparse `1`s appear in aligned pairs horizontally; the output inserts `2`s in the zero cells that lie directly between each adjacent `1` pair, effectively drawing short bridges while keeping the original `1`s intact.
- **Hypothesis**: For every row, sort the columns containing `1`s and fill any intervening zero run of length one with `2`. Rows lacking such pairs stay unchanged; vertical adjacency is ignored.
- **Next Steps**: Confirm there are no pairs separated by more than one zero (would require a longer bridge), and add guards so existing non-zero colours in the gap halt the insertion.

## Puzzle a740d043 (Easy)
- **Observation**: Inputs are almost all `1`s except for a compact blob of other colours. The output crops the minimal bounding box that contains all non-`1` cells and rewrites any `1`s inside that crop to `0`, yielding a tight patch of only the salient colours.
- **Hypothesis**: Find the min/max rows and columns holding values ≠ `1`, slice that rectangle, and replace any residual `1`s within it by `0` while leaving other colours untouched.
- **Next Steps**: Ensure cropping works for blobs touching the border, and check whether a future case with multiple disjoint blobs should merge them before cropping.

## Puzzle a79310a0 (Easy)
- **Observation**: Every connected component of `8`s simply drops one row and changes colour to `2`, while all other cells remain zero.
- **Hypothesis**: Detect each `8` component, translate it down by exactly one row (discarding any part that would fall below the canvas), and recolour the moved pixels to `2`.
- **Next Steps**: Double-check behaviour when an `8` component already sits on the bottom row—training never shows overlap—then guard against collisions between multiple components after the shift.

## Puzzle a9f96cdd (Easy)
- **Observation**: A lone `2` in a 3×5 grid triggers a four-node compass rose: the diagonally adjacent cells become `3` (NW), `6` (NE), `8` (SW), and `7` (SE) whenever those positions exist inside the board.
- **Hypothesis**: Locate each `2`, iterate over the four diagonal offsets, and write the corresponding colour code if the target coordinate lies in-bounds; leave other cells at zero.
- **Next Steps**: Confirm there is always exactly one `2`, and add bounds-aware stamping so missing diagonals simply stay zero without raising errors.

## Puzzle aabf363d (Easy)
- **Observation**: The bulk of the structure is drawn in one colour (`2` or `3`), with a lone seed of a different colour (`4` or `6`) parked at the bottom edge. Outputs repaint the entire blob with the seed colour and remove the seed itself.
- **Hypothesis**: Identify the connected component containing the non-zero mass above, flood it with the value of the bottom sentinel, and finally reset the sentinel cell to zero.
- **Next Steps**: Ensure the sentinel is always unique and adjacent to the blob, enforce that only the target component is recoloured, and guard against cases where the sentinel might sit off to the side.

## Puzzle aedd82e4 (Easy)
- **Observation**: Colour `2` fills most structures, but any `2` pixel that lacks an orthogonal ally flips to `1`. Connected clusters of `2` remain intact.
- **Hypothesis**: For each `2`, inspect its von Neumann neighbourhood; if none of the four neighbours is `2`, repaint the pixel to `1`, otherwise leave it alone.
- **Next Steps**: Implement the adjacency check with border-aware indexing and add regression cases for single-pixel islands touching the edges.

## Puzzle b1948b0a (Easy)
- **Observation**: Every `6` simply turns into `2`, while `7` stays `7`; geometry and zeros remain untouched.
- **Hypothesis**: Apply a global palette substitution `{6→2}` and leave all other colours as-is.
- **Next Steps**: Implement the one-line map and include a quick assertion that no other colours leak into the dataset.

## Puzzle d364b489 (Easy)
- **Observation**: Every `1` in the sparse input sprouts a mini compass rose: the cell above becomes `2`, the left neighbour `7`, the right neighbour `6`, and the cell below `8`, while the centre stays `1`. Where crosses overlap, the later stamps simply reinforce the same values.
- **Hypothesis**: Locate all `1`s and, for each, stamp the fixed cross stencil inside bounds, writing only onto zero cells or the same target colour to avoid clobbering other digits.
- **Next Steps**: Handle boundary cases where parts of the stencil would fall off-grid, and verify the order of stamping is irrelevant when crosses touch.

## Puzzle d406998b (Easy)
- **Observation**: Each column still contains its lone non-zero from the input, but the colour alternates by column between `5` and `3`, producing a regular 5/3 stripe pattern while preserving the original row assignment.
- **Hypothesis**: Read the first non-zero column to lock the phase, then recolour columns in an alternating `{5,3}` cycle without moving the existing pixels.
- **Next Steps**: Confirm the training set only uses two phases (starting with either `5` or `3`), and add a guard to leave columns untouched if they already match the desired colour.

## Puzzle d4a91cb9 (Easy)
- **Observation**: A single `8` and a distant `2` get connected by a corridor of `4`s: the output draws a vertical shaft of `4`s from the `8` down to the `2`’s row, then a horizontal run over to the `2`, leaving the endpoints untouched.
- **Hypothesis**: Locate the unique `8` and `2`, fill the Manhattan path between them with `4`, and preserve any pre-existing non-zero at the endpoints.
- **Next Steps**: Ensure the path is strictly L-shaped (vertical first, then horizontal) and confirm no other non-zeros intervene along the route.

## Puzzle d511f180 (Easy)
- **Observation**: The geometry stays fixed; the transformation simply swaps every `5` with `8` and vice versa across the grid.
- **Hypothesis**: Apply a global palette substitution `{5↔8}` while leaving all other colours untouched.
- **Next Steps**: Add a sanity check that no other colours are affected and include a quick regression where both colours co-exist.

## Puzzle d631b094 (Easy)
- **Observation**: The only non-zero colour in the 3×3 input is reproduced as a 1×N strip whose length equals that colour’s pixel count.
- **Hypothesis**: Count the occurrences of the non-zero value and emit a one-row array filled with that value repeated the same number of times.
- **Next Steps**: Assert that exactly one non-zero colour appears; if more show up, decide whether to prioritise the most frequent or treat it as an error.

## Puzzle d8c310e9 (Easy)
- **Observation**: The input encodes a short horizontal motif that already repeats once; the output tiles that motif across the full width by copying the observed period, leaving the top blank rows untouched.
- **Hypothesis**: Infer the minimal repeating window along each row and replicate it to the right until the canvas fills, ensuring already-blank prefixes remain zero.
- **Next Steps**: Implement a period detector robust to mixed row lengths and fallback to the whole row when no shorter repeat is found.

## Puzzle d9f24cd1 (Easy)
- **Observation**: The bottom row provides a barcode of `2`s; the output broadcasts that barcode upward into every row, and any column that originally hosted a `5` keeps that `5` at the same coordinates while inheriting the surrounding `2`s.
- **Hypothesis**: Copy the final row’s pattern of `2`s into all rows, then overlay the original `5`s without moving them.
- **Next Steps**: Verify there is always exactly one template row (the last), and add a guard in case a puzzle already has non-zero entries above that should be preserved.

## Puzzle d9fac9be (Easy)
- **Observation**: Regardless of layout, the answer collapses to a 1×1 grid whose value is simply the most frequent non-zero colour in the input.
- **Hypothesis**: Count colour frequencies excluding zero, select the argmax, and emit it as the lone output cell.
- **Next Steps**: Define deterministic tie-breaking (e.g., prefer the colour that appears first in reading order) to cover edge cases.

## Puzzle dc1df850 (Easy)
- **Observation**: Lone `2`s grow 3×3 halos of `1`s while leaving other colours unchanged; the halos clip neatly at the board edges and do not overwrite existing non-zero cells.
- **Hypothesis**: For each `2`, stamp a 3×3 neighbourhood centred on it, writing `1` to every surrounding zero cell and preserving the centre value `2`. Skip placements that would fall outside the grid or collide with existing coloured cells.
- **Next Steps**: Implement the stencil with bounds checking and add a regression test covering adjacent `2`s to ensure overlapping halos remain consistent with the samples.

## Puzzle dc433765 (Easy)
- **Observation**: Every grid contains exactly one `3` and one `4`. The `3` moves one step along the shortest path toward the `4` (diagonally if both deltas are non-zero, otherwise straight), while the `4` stays put.
- **Hypothesis**: Compute the row/column deltas between the `3` and `4`, clamp each delta to {-1, 0, 1}, and relocate the `3` by that single-step vector, clearing its former cell.
- **Next Steps**: Handle the adjacent case where no movement is needed and verify diagonal moves never skip over the `4`.

## Puzzle ded97339 (Easy)
- **Observation**: Inputs scatter `8`s that already align horizontally or vertically. Outputs fill every straight stretch between aligned `8`s with more `8`s, turning the sparse dots into solid bars while leaving all other cells zero.
- **Hypothesis**: For each row (and column), find adjacent `8`s and fill the inclusive segment between them with `8`s, repeating until no gaps remain.
- **Next Steps**: Watch for rows or columns containing more than two `8`s so the filler connects each consecutive pair, and ensure existing non-zero colours are never overwritten.

## Puzzle e26a3af2 (Easy)
- **Observation**: Rows contain a dominant colour with occasional noise. Outputs flatten each row to its modal colour, yielding horizontal stripes that preserve the input row order.
- **Hypothesis**: For every row, tally colour frequencies (ignoring zeros unless the row is all zero) and repaint the row uniformly with the most frequent colour, breaking ties by the leftmost winner.
- **Next Steps**: Build the frequency counter, verify the tie-break reproduces the training outputs, and cover the edge case where a row is entirely zero by leaving it unchanged.

## Puzzle e3497940 (Easy)
- **Observation**: A solid column of `5`s acts as a divider; all interesting structure lies to its right. The answer crops out that eastern submatrix down to the tight bounding box of non-zero pixels, discarding the `5` column and the empty padding.
- **Hypothesis**: Identify the all-`5` column, locate the minimal rectangle of non-zero cells strictly to its right, and output that crop verbatim.
- **Next Steps**: Double-check no relevant colour ever appears left of the divider and ensure the crop retains every row that intersects the non-zero region so tall shapes survive intact.

## Puzzle e50d258f (Easy)
- **Observation**: Every input hides a dense block framed by zeros—the interesting digits sit in a contiguous sub-rectangle separated by blank rows and columns. The outputs are simply those sub-rectangles, cropped exactly to the non-zero block that contains both `1`s and `2`s.
- **Hypothesis**: Detect all-zero rows and columns, slice the grid into candidate rectangles, and emit the unique submatrix that contains both `1` and `2` (and is framed by the background colour `8`).
- **Next Steps**: Formalize the block-selection logic when multiple candidates exist, and guard against cases where the salient block abuts the border so no zero separator is present.

## Puzzle e73095fd (Easy)
- **Observation**: The inputs are maze-like arrangements of `5`s with rectangular voids. The outputs keep the `5` skeleton but fill interior cavities with `4`s, so every closed corridor gains a solid `4` floor while the outer hull and open passages stay at `5` or `0`.
- **Hypothesis**: Treat `5` as walls; flood-fill the complement to mark exterior space. Any zero cell not reachable from the outside gets repainted `4`, leaving walls untouched.
- **Next Steps**: Implement an exterior flood fill, double-check that open bays (touching the border) remain zero, and confirm no original non-zero cell is overwritten.

## Puzzle e9614598 (Easy)
- **Observation**: Sparse `1`s always appear in aligned pairs (same row or same column). Every output adds a plus-shaped cluster of `3`s centred halfway between the pair, while the original `1`s remain as anchors.
- **Hypothesis**: Detect the two `1`s, compute their midpoint (integer because they share an axis), and stamp a 5-cell cross of `3` there (horizontal and vertical arms reaching exactly one cell). Preserve the original pixels.
- **Next Steps**: Confirm there are never more than two `1`s, handle both horizontal and vertical alignments, and double-check the cross size when the midpoint lies near a border.

## Puzzle e9afcf9a (Easy)
- **Observation**: Inputs are two uniform rows of different colours. The solution interleaves them into a checkerboard: columns alternate the two colours, and the second row is just a one-step shift of the first.
- **Hypothesis**: Repeat the colour pair `[top,bottom]` across the width so the first row alternates `top,bottom,…` and the second row begins with `bottom` to stay out of phase.
- **Next Steps**: Generalise to any even width and assert that widths are always even so the alternation ends on the top colour as in training.

## Puzzle eb281b96 (Easy)
- **Observation**: Each training input is a short strip whose rows already alternate colours. The answer simply tiles that strip by repeating the observed row cycle so the pattern continues vertically.
- **Hypothesis**: Determine the minimal row period (three rows in the samples) and repeat it until the output height matches the target, copying rows verbatim.
- **Next Steps**: Check whether some puzzles require padding to reach a multiple of the period and keep an eye out for horizontal flips that might break the simple tiling.

## Puzzle f25ffba3 (Easy)
- **Observation**: Only the bottom block of rows contains colour; the solution mirrors that block up and down, yielding a vertical palindrome where the densest row ends up at both the top and bottom of the grid and the original zero padding survives in the middle.
- **Hypothesis**: Locate the first non-empty row from the bottom, slice the contiguous run of populated rows, and rebuild the board by stacking that slice in reverse order followed by the slice in forward order (sharing the central row when the height is odd). Leave any untouched leading zeros alone when the slice does not reach them.
- **Next Steps**: Guard against inputs with multiple disjoint non-zero bands, validate that the slice detection handles repeated rows cleanly, and see whether a compact in-place reversal is cleaner than allocating a new buffer.

## Puzzle f5b8619d (Easy)
- **Observation**: Every puzzle is a nearest-neighbour upscale: the target doubles both width and height, copies the source colour into the north-west cell of each 2×2 block, and fills the other three cells of that block with `8`. Zeros therefore generate `[0,8;8,8]` tiles, while non-zero seeds propagate as `[c,8;8,8]` tiles.
- **Hypothesis**: Perform a simple 2× Kronecker expansion. For each input cell `(r,c)` with value `v`, write `v` to `(2r,2c)` and `8` to `(2r,2c+1)`, `(2r+1,2c)`, `(2r+1,2c+1)` in the output. No blending is required because every block is independent.
- **Next Steps**: Add bounds checks so 2× indices stay inside the enlarged canvas, and verify that the routine gracefully handles rectangular inputs (non-square but still doubled).

## Puzzle f8b3ba0a (Easy)
- **Observation**: The inputs are mosaics of 2×2 tiles separated by blank columns and rows. Every non-blank tile uses one dominant colour, and the tiles are arranged in horizontal bands with repeated patterns. The output shrinks the whole picture to a 3×1 column that simply lists the prominent tile colour from each band, top to bottom.
- **Hypothesis**: Partition the grid into horizontal strips separated by the all-zero rows, identify the majority colour within the non-zero tiles of each strip, and emit those colours as a vertical list. Ignore the ubiquitous filler colour `1` when a strip also contains a more distinctive hue.
- **Next Steps**: Validate the strip detection when multiple blank rows appear between bands, and confirm how to break ties if a band contains more than one non-filler colour.

## Puzzle f8ff0b80 (Easy)
- **Observation**: Each board contains exactly three disjoint coloured clusters. The output compresses the scene to a 3×1 column whose entries are the colours of those clusters ordered by their centroid’s horizontal position (leftmost cluster first). Zeros never appear in the targets.
- **Hypothesis**: Label connected components ignoring zeros, compute each component’s x-centroid, sort them left-to-right, and write their colours into a one-column array. Because there are always three components, the output height is fixed at three.
- **Next Steps**: Double-check that the components never overlap horizontally (to keep the ordering stable), and add a guard in case a future puzzle introduces a fourth cluster or merging components.

## Puzzle 2013d3e2 (Easy)
- **Observation**: Each input is a padded 10×10 wallpaper whose non-zero content sits inside a tight rectangle. The 3×3 answer is simply the top-left quadrant of that minimal bounding box, with zeros preserved.
- **Hypothesis**: Crop to the min/max rows and columns that contain non-zero values, then return the submatrix covering rows `0..2` and cols `0..2` of that crop without any further recoloring.
- **Next Steps**: Add a crop utility, ensure the bounding box is at least 3×3 in every example, and guard the code for puzzles where the salient motif already hugs the border so the slice still aligns correctly.

## Puzzle 2204b7a8 (Easy)
- **Observation**: Left and right borders are solid color rails, while stray `3`s float in the interior. In the targets every `3` is replaced by whichever border color sits on the same row, so interior markers collapse back to the nearest guard rail without moving their coordinates.
- **Hypothesis**: Treat each row independently: find the first and last non-zero entries (the border colors), and recolor any `3` in that row to whichever border color is closer (preferring the left rail on ties as seen in training).
- **Next Steps**: Implement a row-wise sweep that records border hues, confirm there are never conflicting markers between the rails, and validate that the transformation leaves existing border pixels untouched.

## Puzzle 98cf29f8 (Easy)
- **Observation**: Each colour in the source already forms a near-rectangular patch but with missing rows or columns. The outputs simply fill the entire axis-aligned bounding box of every colour component, yielding clean solid rectangles that keep their original positions.
- **Hypothesis**: Identify connected components per colour, grab the min/max rows and columns for each, and repaint *every* cell inside that rectangle with the component colour. Because components never overlap, the rectangles can be drawn independently.
- **Next Steps**: Build a component→bounding-box map, confirm degenerate strips (one-cell width) still expand correctly, and ensure the routine skips colour `0` so the empty background remains untouched.

## Puzzle 99b1bc43 (Easy)
- **Observation**: Above a separator row of `4`s sits a 4×4 glyph in colour `1`, and below it a second 4×4 glyph in colour `2`. The answer fuses the two by taking the logical OR of their shapes (after converting both to colour `3`), effectively overlaying the top form and the bottom form in a single 4×4 canvas.
- **Hypothesis**: Slice the board at the `4` row, convert each non-zero in the upper and lower blocks to `3`, and OR the masks cell by cell so any lit pixel becomes `3` in the output. Zeros stay zero when both halves were empty.
- **Next Steps**: Implement the splitter, double-check both halves are always 4×4, and confirm there is no colour collision other than `{0,1,2}` before converting everything to the unified colour `3`.

## Puzzle 99fa7670 (Easy)
- **Observation**: Each non-zero seed spawns an L-shaped extrusion: a solid horizontal bar extends to the right edge, and the colour then drops vertically from the bar’s end, leaving the original seed in place.
- **Hypothesis**: For every coloured cell, paint its entire row to the right with that colour, then continue straight down the last painted column until leaving the board or hitting another coloured trail. Seeds never conflict in training, so later trails can be drawn independently.
- **Next Steps**: Write a deterministic right-then-down fill routine, prove that overlapping trails must have matching colours in the dataset, and run it across the held-out puzzle to verify the sequence `[8,7,2]` reproduces the provided answer.

## Puzzle ef135b50 (Easy)
- **Observation**: Every row already hosts a pair of `2` blocks; the solution simply paints `9`s across whatever zero gap lies between the leftmost and rightmost `2`, turning those disjoint runs into single solid bars.
- **Hypothesis**: For each row, find the minimum and maximum column containing colour `2`, leave the `2`s themselves untouched, and fill any intervening zeros with `9`. Rows with fewer than two `2`s remain unchanged, so the injected `9`s only appear when the span actually exists.
- **Next Steps**: Stress rows that contain multiple disjoint `2` segments to ensure the fill logic only targets the outer span, and assert that vertical adjacency is irrelevant so there’s no temptation to leak `9`s into neighbouring rows.

## Puzzle fafffa47 (Easy)
- **Observation**: Each input stacks two 3×3 masks: the upper half marks blocked cells with `9`, the lower half marks occupied cells with `1`. The output highlights (with `2`) exactly those coordinates that stay empty in both masks.
- **Hypothesis**: Split the grid into the top and bottom thirds, align them cell by cell, and write `2` wherever both layers hold `0`; any cell containing either a `9` or a `1` should return to `0` in the answer.
- **Next Steps**: Confirm the split is always 3+3 rows before generalising, and add guards so future anomalies (e.g. overlapping non-zero colours) don’t accidentally produce `2`s.

## Puzzle fcc82909 (Easy)
- **Observation**: Every 2×2 glyph in the source keeps its original colours, but the answer introduces a `3` patch of the same width immediately beneath each glyph, producing trailing shadows that can stack into taller columns when multiple motifs align.
- **Hypothesis**: Detect the top-left corner of every 2×2 non-zero block, stamp a 2×2 block of `3`s directly below it (clipped to the board and skipping cells that already contain the glyph itself), and leave existing colours untouched so overlapping shadows simply reinforce the columnar effect.
- **Next Steps**: Decide whether shadows should be omitted when the glyph touches the bottom edge, and add a collision rule in case two glyphs sit vertically adjacent with no gap.

## Puzzle ff28f65a (Easy)
- **Observation**: The boards are mosaics of 2×2 `2` components located in a handful of coarse regions. The outputs boil that layout down to a 3×3 bitmap where `1`s flag which thirds of the canvas (top-left, centre, bottom-right, etc.) actually hosted a component.
- **Hypothesis**: Partition the input into three bands both horizontally and vertically (using floor/ceiling splits for uneven dimensions), test each cell of the coarse grid for the presence of at least one `2`, and copy that presence/absence map into the 3×3 answer.
- **Next Steps**: Verify that components straddling a boundary appropriately light up multiple coarse cells, and add tests for small boards where a third might collapse to width one.

## Puzzle 007bbfb7 (Medium)
- **Observation**: Every 3×3 input grid is inflated to 9×9 by replacing each cell with a 3×3 glyph that depends only on the cell color. Zero maps to a blank 3×3 block, while non-zero colors (e.g., 7, 4, 2, 6) produce distinctive digit-like shapes positioned exactly where the source cell sits in the 3×3 layout.
- **Hypothesis**: Learn a color→glyph dictionary from the training pairs by slicing each 9×9 output into 3×3 blocks. Reconstruct the target by tiling the glyph associated to each input cell. The test case should then be solvable by look-up, assuming all colors appear in training.
- **Next Steps**: Verify that each color present in the test grid is represented in either the training inputs or outputs. Implement a helper that extracts glyphs automatically and generalizes the tiling process.

## Puzzle 00d62c1b (Medium)
- **Observation**: Color `3` traces skinny orthogonal paths; whenever those paths form a convex turn or T-junction, the interior elbow is recolored to `4`. Every training pair shows the same pattern: search for 2×2 blocks with two or more `3`s touching at right angles, and paint the shared orthogonal neighbor with `4`.
- **Hypothesis**: Scan the grid for each `3` pixel that has another `3` one step north/south and one step east/west. Mark that pivot cell, plus any immediately interior neighbors, as `4`. The rest of the structure stays untouched.
- **Next Steps**: Formalize the elbow detector, double-check that the test grid only needs right-angle fills (no diagonals), and ensure we do not repaint existing `3`s.

## Puzzle 0520fde7 (Medium)
- **Observation**: Inputs are 3×7 bands always containing a vertical column of color `5`; outputs collapse to 3×3 grids highlighting where color `1` appears relative to that column. The `5` column becomes the center column of the output and the `1`s mark which rows/edges get color `2` in the output.
- **Hypothesis**: Map each input row to an output row: for each row, if `1`s appear to the left/right of the `5`, place `2`s in the corresponding left/right cell of the reduced grid. The middle column stays 0 except when a `1` overlaps the `5`. Colors other than `1`/`5` are ignored.
- **Next Steps**: Formalize the per-row projection and ensure we correctly identify the central `5` column index even if shifted.

## Puzzle 05269061 (Medium)
- **Observation**: The top-left triangular non-zero region is symmetrically copied to fill the entire 7×7 output with a repeating diagonal braid (cyclic color sequence). The specific color order depends on reading the non-zero diagonal stripe from the input.
- **Hypothesis**: Extract the sequence of non-zero cells along a NE-SW diagonal (e.g., `[2,8,3]`) and tile the output with that sequence along rows and columns, using modulo arithmetic to maintain the pattern.
- **Next Steps**: Implement diagonal extraction plus a toroidal tiler, and verify robustness when the input diagonal starts deeper inside the grid.

## Puzzle 05f2a901 (Medium)
- **Observation**: Blocks of colors `2` and `8` translate vertically: each connected component is slid so its centroid ends up near the lower half, preserving shape and relative offsets. Essentially the upper and lower color patches swap vertical bands.
- **Hypothesis**: For each color, compute the minimal bounding box and move it to a target row band (e.g., `2` to bottom-third, `8` to upper-third). The outputs show consistent destination zones, not scaling.
- **Next Steps**: Confirm deterministic target rows across all training cases, then encode a color→row-band translation table.

## Puzzle 09629e4f (Medium)
- **Observation**: The grid is partitioned into 3×11 bands separated by solid `5` rows. Within each band, colors collapse into solid zones at fixed positions (top three rows become color A, middle three rows color B, etc.).
- **Hypothesis**: For each band, detect the most frequent color in each vertical third and repaint that third uniformly, using row groups anchored by the consistent `5` separators.
- **Next Steps**: Implement band extraction and majority-color enforcement; confirm the band heights are always multiples of three.

## Puzzle 0962bcdd (Medium)
- **Observation**: Sparse plus-shaped motifs (center value with arms) get magnified: the center color stays put, while arms expand with alternating secondary colors, creating a 3×3 diamond plus mirrored pattern.
- **Hypothesis**: Locate every cross pattern (value `center`, arms of same color) and rewrite the surrounding 3×3 region using a prelearned stencil that depends on the center value (e.g., `2→` pattern with 7 and 2). Keep zeros elsewhere.
- **Next Steps**: Compile the stencil mapping from each training cross and ensure overlapping stencils either agree or can be merged.

## Puzzle 0ca9ddb6 (Medium)
- **Observation**: Single pixels of different colors spawn arms: the center stays the same, while orthogonal neighbors get repainted with a repeating pattern `4` around vertical axes and `7` around horizontal axes, forming a small plus with highlights.
- **Hypothesis**: For each color seed, write a fixed 3×3 template (depending on the seed color) centered on it. Templates seem to combine the seed, `4`s, and `7`s symmetrically.
- **Next Steps**: Extract exact templates per color from training data and ensure superposition rules handle overlapping arms safely.

## Puzzle 1190e5a7 (Medium)
- **Observation**: Inputs are massive checkerboards made of uniform stripes; outputs collapse them into tiny grids whose cells simply report the dominant color of each stripe bundle. Regardless of stripe thickness, the reduced grids keep the same number of stripe groups seen vertically.
- **Hypothesis**: Segment the input into maximal constant-color bands (alternating high/low colors), collect the modal color for each, and render a compressed matrix with one cell per band pair—resulting in solid blocks of the majority hue.
- **Next Steps**: Parameterize the stripe detector so it tolerates noise-free but variable-width runs, confirm the downsampling ratio for both dimensions, and guard against the all-one-color situation by defaulting to that color everywhere.

## Puzzle 150deff5 (Medium)
- **Observation**: Color `5` forms amoeba-like blobs that the outputs recolor into two tones: interior corridors and vertical legs become `2`, while outer plates and horizontal flanges turn into `8`, preserving the original footprint exactly.
- **Hypothesis**: Treat each connected `5` region, compute for every cell whether it has a horizontal neighbor within the blob (flagging it as edge vs interior), and assign `8` to cells with horizontal exposure and `2` otherwise.
- **Next Steps**: Validate the edge classifier against all training instances, ensure single-pixel appendages pick the right color, and confirm no new colors appear in the recoloring.

## Puzzle 1a07d186 (Medium)
- **Observation**: Many rows and columns contain repeated appearances of the same color separated by zeros. The outputs bridge those repeats by painting the corridor between them, effectively filling rectangles or bars whenever two identical colors align either horizontally or vertically.
- **Hypothesis**: Scan rows for matching-colored endpoints, flood the span between them with that color, and repeat the process for columns—taking care not to overwrite previously filled corridors with conflicting colors.
- **Next Steps**: Prototype separate horizontal and vertical fills, decide a precedence order when spans intersect, and verify on the training grids that every painted segment corresponds to an endpoint pair.

## Puzzle 1b60fb0c (Medium)
- **Observation**: The shape drawn in `1`s stays fixed, but the outputs add `2`s flush against the left flank of every horizontal run of `1`s, sometimes extending vertically to keep the outline contiguous. Essentially, `2` traces the western perimeter of the `1` polyomino.
- **Hypothesis**: For each `1` cell, test whether the neighbor immediately to its left lies outside the shape; if so, write a `2` there. Propagate the same logic upward when vertical runs would otherwise leave gaps in the outline.
- **Next Steps**: Implement the perimeter tracer on the binary mask, confirm overlapping proposals do not leak inside the shape, and double-check that the test grid’s outline matches the training pattern.

## Puzzle 1bfc4729 (Medium)
- **Observation**: A single colored seed (e.g., `6` or `7`) blossoms into a 5×5 hollow square: the outer ring is the seed color, the interior stays zero, and distinct seeds stack vertically in the order they appear from top-to-bottom. Empty rows separate the bands.
- **Hypothesis**: Locate each non-zero pixel, sort by row, and for each one stamp a fixed 5×5 frame template centered on the seed column while offsetting successive frames down by five rows to avoid overlap.
- **Next Steps**: Derive the exact template from training output (note the two alternating row patterns) and ensure multiple seeds never collide; if they do, favor the first-seen color.

## Puzzle 1c786137 (Medium)
- **Observation**: Giant 23×21 canvases shrink to 6×8 mosaics whose columns capture the dominant color in each 4×4 macro-cell. The condensed grid preserves coarse structure (e.g., diagonals of `3`, `5`, `8`) while discarding fine detail.
- **Hypothesis**: Partition the input into non-overlapping 4×4 blocks, tally colors, and emit the majority color per block to build the downsampled mosaic. Ignore leftover fringe rows/cols beyond the tiled region.
- **Next Steps**: Validate the block size by reconstructing the training outputs; if ties occur, adopt a deterministic breaker (e.g., prefer the non-zero with highest frequency).

## Puzzle 1e0a9b12 (Medium)
- **Observation**: Non-zero tiles slide toward the southwest corner: the lower row holds the values in reading order, while any vertical stacks become short columns directly above that row. Everything north-east of the final staircase is cleared.
- **Hypothesis**: Collect non-zero cells left-to-right, append them to the bottom row, and for columns that had multiple hits, keep the previously seen values one row above to produce the little tail seen in training.
- **Next Steps**: Codify the placement order (row-major vs column-major) so the reconstructed tail matches exactly, and guard against pushing cells past the leftmost column when reflowing.

## Puzzle 1e32b0e9 (Medium)
- **Observation**: Grids consist of alternating horizontal “track” rows of `8` with occasional `2` or `9` motifs embedded between them. Outputs mirror the same roadbed but mirror each motif across the track centerline, duplicating every non-zero pattern on both sides.
- **Hypothesis**: Treat each slab between consecutive `8` rows as a band, reflect its interior columns across the band midpoint, and OR the reflected colors with the original positions. Leave the `8` rails untouched.
- **Next Steps**: Verify reflection width per band (most samples span four columns) and ensure newly mirrored colors do not leak into neighboring bands or overwrite the rails.

## Puzzle 1f0c79e5 (Medium)
- **Observation**: Small 2×2 blobs of color expand into diagonal ramps: the seed occupies the top of the ramp and is replicated three times while descending one step to the right each row, forming a 45° wedge of constant color.
- **Hypothesis**: Find the 2×2 block, then emit a nine-row pattern where each consecutive row shifts the color one column right until the diagonal reaches the far edge, padding remaining cells with zero.
- **Next Steps**: Deduce ramp length from training (eight or nine steps), confirm the wedge never wraps horizontally, and handle the symmetric case where the block might sit mirrored.

## Puzzle 1f642eb9 (Medium)
- **Observation**: A central 3×N slab of `8`s acts as a canvas; peripheral colors (`9`, `6`, `4`, `2`) project onto the nearest edge of that slab, replacing the rail cell with the projected color while leaving the rest intact.
- **Hypothesis**: For each non-zero outside the 8-slab, drop a perpendicular to the slab boundary and repaint that boundary cell with the source color. If two projections hit the same cell, later ones win (matching the examples).
- **Next Steps**: Extract the slab bounds automatically (contiguous block of `8`s), implement the projection step, and double-check projections along diagonals choose the orthogonal direction observed in training.

## Puzzle 22233c11 (Medium)
- **Observation**: `3`s retain their footprints, but every connected cluster spawns a detached patch of `8`s whose footprint matches the cluster’s bounding box and sits in the quadrant obtained by reflecting the cluster across the grid center. Rectangular clusters therefore yield solid 2×k or k×2 blocks of `8`s, while skinny diagonals generate small offset diamonds of the same width/height.
- **Hypothesis**: Segment the `3` components, capture each bounding box, then place an `8` block of identical shape in the mirrored quadrant (swap the box’s relative row/column offsets with respect to the grid midpoint). Keep the original `3`s untouched.
- **Next Steps**: Validate the reflection rule across all training pairs, nail down how to pick the destination quadrant for clusters near the center, and confirm the test example’s large blocks still map cleanly under the same mirroring.

## Puzzle 2281f1f4 (Medium)
- **Observation**: A sentinel column of `5`s at the far right tags specific rows; whenever a row holds that sentinel, the output copies the first-row `5` silhouette into that row using color `2`, while keeping the original `5`s in place. Rows lacking the terminal `5` stay zeroed except for any existing `5`s.
- **Hypothesis**: Detect the rightmost column containing `5`, treat it as the trigger, collect the mask of non-zero columns from the template row (topmost row with multiple `5`s), and stamp that mask with color `2` on every row that also contains a `5` in the trigger column. Preserve the original entries elsewhere.
- **Next Steps**: Confirm the template row is always unique, guard against cases where the sentinel sits in a different column, and ensure overlapping `2` placements do not overwrite non-zero colors other than zero.

## Puzzle 234bbc79 (Medium)
- **Observation**: The three-row inputs treat `5` as a vertical fence. Outputs strip the `5` columns and compress the remaining colored segments toward the west, preserving their relative ordering but collapsing gaps. Colors that were separated by `5` barriers now sit adjacent, while rows that were purely scaffolding collapse to zeros.
- **Hypothesis**: Identify every column that is all zeros or contains a `5` anywhere, drop those columns, and pack the surviving columns leftward. Within the shrunken slab, copy the remaining non-zero values directly, yielding the skinny mosaics seen in training.
- **Next Steps**: Double-check that no needed color ever lives in a column that also hosts a `5`, ensure the compression keeps row alignment consistent across train/test, and consider adding a safeguard to keep at least one zero column between formerly separated blocks if a future sample requires it.

## Puzzle 23b5c85d (Medium)
- **Observation**: Massive blocky scenes always contain a deeply nested “core” color (e.g., `8`, `1`, `6`, `7`, `4`). The outputs crop away everything else and report only that inner fill as a small solid rectangle whose size matches the inner component’s footprint.
- **Hypothesis**: Compute connected components by color, choose the one with the highest level of enclosure (or smallest bounding box entirely inside others), and output its bounding box as a compact matrix filled with the component’s color. All other structure collapses away.
- **Next Steps**: Formalize an enclosure depth metric (e.g., via BFS layering), confirm that the innermost region is always a simple rectangle, and ensure the shrink-to-bbox operation preserves orientation for asymmetric cores.

## Puzzle 253bf280 (Medium)
- **Observation**: Isolated `8` beacons appear in symmetric pairs. The solution connects paired beacons with ribbons of `3`s that run straight along the axis separating them, leaving unrelated zeros untouched. Horizontal, vertical, and diagonal alignments all produce the expected straight or L-shaped bridges.
- **Hypothesis**: Group `8`s into pairs (typically via symmetry or equal spacing), then fill the minimal Manhattan corridor between each pair with `3`, retaining the `8`s at the endpoints. Repeat for all pairs without overwriting preexisting `8`s.
- **Next Steps**: Nail down the pairing heuristic (most likely opposite sides of a rectangle), verify how to handle odd counts of `8`s, and add guardrails so corridors never overwrite other non-zero colors that might appear in future variants.

## Puzzle 25d487eb (Medium)
- **Observation**: Each example features a “minority” color embedded inside a larger blob. The output extrudes that minority color into a full stripe that spans the host shape—horizontal in the first and last pair, vertical in the middle one—while keeping the wrapper color untouched.
- **Hypothesis**: Detect the single-color patch with the smallest area inside each composite shape, determine whether its extent is wider than tall (horizontal vs vertical), and extend it across the bounding box along that axis, filling the stripe with the minority color and leaving the rest of the blob intact.
- **Next Steps**: Confirm the minority patch is always unique, codify the axis selection logic (compare width/height), and ensure extrusion halts at the blob boundary so we do not leak into zeros.

## Puzzle 27a28665 (Medium)
- **Observation**: Each 3×3 input encodes one of a handful of adjacency motifs (diagonal corners, full X, solid cross). The output is a single cell that reports which motif appeared, independent of the actual color used in the input.
- **Hypothesis**: Classify the 3×3 pattern by counting which neighbors of the center share the same color, then map the resulting signature to the label color (`1`, `2`, `3`, or `6`).
- **Next Steps**: Build the signature→label lookup from training, ensure color is ignored (normalize to binary mask), and test the classifier against rotations/reflections to catch equivalent motifs.

## Puzzle 29623171 (Medium)
- **Observation**: Columns of `5` form vertical rails that separate three lanes. Inputs sprinkle hints of colors (`1`, `2`, `3`, `4`) near the rail endings; outputs flood each lane with the hinted color while keeping the `5` rails intact. Bottom rows often set the target lane color explicitly.
- **Hypothesis**: For each lane between the `5` columns, scan for the first non-zero color aside from `5` and repaint the entire lane with that color (top-to-bottom). Treat the bottom indicator rows as authoritative if earlier rows are blank.
- **Next Steps**: Validate that every lane always exposes its intended color somewhere in the input, and ensure we keep any explicit digits already present on the final rows when they differ from the lane fill.

## Puzzle 29c11459 (Medium)
- **Observation**: Only the outermost columns carry color—left and right anchors differ per row. The output stretches each anchor across its half of the row, inserting a column of `5`s as the divider.
- **Hypothesis**: For each row, detect the first non-zero entry from the left and the last from the right, paint columns up to the midpoint with the left color, columns past the midpoint with the right color, and set the midpoint column to `5`.
- **Next Steps**: Confirm grids always have an odd width with a well-defined center, and watch for rows that are entirely zero (should stay zero).

## Puzzle 29ec7d0e (Medium)
- **Observation**: Inputs are partially erased Latin strips—long cycles like `1..9` with stretches of zeros. Outputs reconstruct the missing digits, restoring the full periodic sequence row by row.
- **Hypothesis**: For each row, infer the smallest repeating cycle from the non-zero prefix and tile that cycle across the full width, plugging gaps where zeros appeared. Leave rows that are already complete untouched.
- **Next Steps**: Add safeguards for rows with multiple candidate cycles (fallback to the longest seen in training) and double-check that columns never impose conflicting constraints.

## Puzzle 2c608aff (Medium)
- **Observation**: Rectangular islands of one color sit in a sea of another; whenever a lone accent pixel touches a face of that island, the entire exposed face (row or column) is repainted with the accent color in the output.
- **Hypothesis**: Segment each solid block, detect which colors abut its north/east/south/west faces, and overwrite the touched face with the accent color while leaving untouched faces alone.
- **Next Steps**: Catalogue the face→accent relationships from the training set and ensure the sweep respects block bounds so the accent does not leak past the component.

## Puzzle 2dc579da (Medium)
- **Observation**: A plus-shaped corridor in a single color splits the board into four quadrants, and exactly one quadrant hosts a “goal” color distinct from the cross. The solution crops that quadrant and discards the rest.
- **Hypothesis**: Locate the continuous row/column forming the cross, partition the grid into quadrants relative to that pivot, find the quadrant containing any non-cross color, and output that submatrix as-is.
- **Next Steps**: Formalize detection of the cross axes (e.g., longest uniform row/column) and make sure the quadrant extraction handles edge cases where the target lies on the border.

## Puzzle 2dee498d (Medium)
- **Observation**: Each grid is a horizontal tiling of a smaller motif; the output collapses the repetition and keeps a single period while preserving every row of the motif.
- **Hypothesis**: Determine the minimal horizontal period shared by all rows, slice out that many columns from the left, and return the cropped patch.
- **Next Steps**: Implement per-row period detection (use the gcd of repeating offsets) and guard against rows that are already aperiodic so the lookup table can catch them.

## Puzzle 321b1fc6 (Medium)
- **Observation**: A small emblem (typically a 2×2 block of mixed digits) sits in one corner while several 2×2 patches of `8`s appear elsewhere. The outputs transplant the emblem into each former `8` patch and clear the original location.
- **Hypothesis**: Capture the first non-zero 2×2 block as the prototype, locate every disjoint 2×2 block filled with `8`, replace each with the prototype values, and zero out the source block.
- **Next Steps**: Generalize the block detector to tolerate other prototype locations and ensure overlapping `8` areas aren’t double-stamped.

## Puzzle 32597951 (Medium)
- **Observation**: Binary wallpapers of `0`/`1` include rectangular carpets of `8`. The outputs recolor the `1`s that sit in the same tile as the `8` into `3`, turning each carpet into a decorated motif while leaving distant `1`s untouched.
- **Hypothesis**: For every connected component of `8`, recolor any adjacent-in-tile `1` (sharing either a row/column within that block) to `3`, keeping the rest of the grid unchanged.
- **Next Steps**: Nail down the exact notion of adjacency used in the training data and ensure overlapping carpets don’t compete when they are separated by only a single column of zeros.

## Puzzle 3345333e (Medium)
- **Observation**: Thick hulls of a dominant color (like `6` or `2`) surround interior stripes of a different color. The outputs flood those interior stripes so the hull color fills the entire wedge, erasing the embedded streaks.
- **Hypothesis**: Detect connected components whose boundary neighbors are a single dominant color and repaint the whole component with that color, while leaving the true background zero.
- **Next Steps**: Implement component labeling that records the neighboring halo color and skip any component that touches the outer boundary (to avoid recoloring the background).

## Puzzle 363442ee (Medium)
- **Observation**: A vertical spine of `5`s splits the grid, and the northwest 3×3 patch is the only region with non-zero data. The output replicates that 3×3 motif to the east of the spine and again into the bands flagged by solitary `1`s farther south, creating mirrored copies while keeping the `5` column fixed.
- **Hypothesis**: Capture the 3×3 block in rows 1–3, cols 1–3, then stamp it into every target window whose top-left is signaled by a `1` in the input (including the slot immediately right of the spine).
- **Next Steps**: Write a tiler that identifies all anchor `1`s, copies the learned 3×3 patch at those anchors, and ensures we never overwrite the `5` spine or the original source block.

## Puzzle 3aa6fb7a (Medium)
- **Observation**: The inputs consist of thin `8` L-shapes. Outputs add a single `1` at the exposed elbow of each L—specifically, the first zero cell immediately clockwise from the shorter leg—while leaving the rest of the shape untouched.
- **Hypothesis**: For every connected `8` component, detect its two orthogonal legs, locate the zero cell diagonally adjacent to the joint, and paint it `1`.
- **Next Steps**: Write a light-weight component analyzer for size-3 or size-4 Ls, confirm the elbow detection handles mirrored orientations, and guard against overlapping elbows.

## Puzzle 3ac3eb23 (Medium)
- **Observation**: Each puzzle contains a handful of non-zero pixels on the first row (and occasionally at positions separated by zeros). The solution turns that sparse motif into a 2-row repeating wallpaper: the original row alternates with its one-cell right shift across all remaining rows, producing a checkerboard of the same colors with zeros in between.
- **Hypothesis**: Read the seed row, create a two-row pattern consisting of the seed and its right shift, and tile that pair vertically until the grid is filled.
- **Next Steps**: Confirm the right-shift wraps or pads with zeros exactly as in training (they pad), and ensure future variants with multiple seed colors continue to alternate without collision.

## Puzzle 3af2c5a8 (Medium)
- **Observation**: Every output is a 2× enlargement of the input where the original tile sits in the northwest quadrant, the northeast quadrant is a horizontal mirror, the southwest quadrant is a vertical mirror, and the southeast quadrant is the double mirror. Rows are duplicated in that order so seams remain perfectly symmetric.
- **Hypothesis**: Construct a canvas with doubled height/width, copy the source grid into the top-left corner, then fill the other three quadrants by reflecting the source horizontally, vertically, and both. Because the reflections are exact, no blending logic is needed.
- **Next Steps**: Implement the quadrant mirroring, making sure it works for rectangular inputs, and add tests that the copied quadrants reproduce the training examples verbatim.

## Puzzle b94a9452 (Medium)
- **Observation**: Each input contains a single axis-aligned rectangle of non-zero cells sitting in a sea of zeros. The rectangle’s outer border is one color and its interior (which can shrink to a single cell) is a second color. The output crops to that rectangle and swaps the roles: the former interior color paints the border, while the previous border color fills the interior.
- **Hypothesis**: Detect the minimal bounding box of non-zero pixels, read the two colors present inside it, determine which color sits on the border versus the interior, then emit the cropped rectangle with those colors swapped. The surrounding zeros never appear in the output.
- **Next Steps**: Double-check edge cases where the interior is only one cell thick or the two colors appear multiple times on the border, and add defensive logic in case future puzzles introduce thicker borders or unexpected third colors inside the rectangle.

## Puzzle b9b7f026 (Medium)
- **Observation**: Each scene is tiled by several solid color rectangles, but exactly one rectangle is a hollow “frame” whose perimeter is colored while its interior is zero. The solution ignores layout and simply outputs the color of that framed component as a 1×1 grid.
- **Hypothesis**: Label connected components, flag the one whose bounding box encloses at least one zero cell (i.e., it is not filled solid), and return its color as the single-cell answer. All other solid blocks are irrelevant noise.
- **Next Steps**: Confirm the hollow component is unique in every case, and tighten the detector to tolerate thicker frames so long as a zero hole remains enclosed.

## Puzzle bb43febb (Medium)
- **Observation**: Large `5` rectangles act as canvases. The transformation carves out their interior by writing a centered 3×3 patch of `2`s (or, for bigger rectangles, a solid block of `2`s inset one cell from every 5-border). Regions of `5` that are only one cell thick stay untouched, and zeros elsewhere remain zero.
- **Hypothesis**: For each connected `5` component with both height and width ≥3, fill the sub-rectangle bounded by shaving one layer off every side with `2`, leaving the outer ring at `5`. Skip components that are too skinny to host an inset.
- **Next Steps**: Generalize the inset filler to handle non-square rectangles and verify overlapping components do not accidentally double-paint when two `5` blobs sit adjacent.

## Puzzle bbc9ae5d (Medium)
- **Observation**: A single horizontal run of a non-zero color is expanded downward into a right triangle (or staircase) of the same color whose height equals the run length. Each subsequent row extends the painted prefix by one cell, producing a lower-left justified triangular ramp.
- **Hypothesis**: Measure the length `k` of the leading non-zero run. Emit `k` rows where row `i` (0-indexed) copies the first `k` cells of the base color and fills the rest with zero, effectively building the triangle row by row.
- **Next Steps**: Guard against runs that start with zeros or contain gaps, and confirm whether right-justified variants ever appear (so far everything builds from the left edge).

## Puzzle bc1d5164 (Medium)
- **Observation**: Each input is a sparse 5×7 glyph drawn with a single non-zero color. The output shrinks that glyph to a 3×3 signature that preserves which corners, edges, and center were occupied. Effectively it downsamples the bounding box while keeping relative adjacency (e.g., plus signs stay pluses, diagonals remain on the same side).
- **Hypothesis**: Crop to the tight bounding box of the color, partition it into a 3×3 grid, and mark each coarse cell if any source pixel in that bucket carried the glyph color. Return that 3×3 presence map using the original color.
- **Next Steps**: Validate the bucket mapping on all training cases, especially ones whose bounding box is not a multiple of three, and ensure ties (multiple colors per bucket) cannot occur.

## Puzzle be94b721 (Medium)
- **Observation**: Several small color components appear in otherwise empty canvases, but the answer keeps only one component—typically the most complex or largest—and returns its tight bounding box, optionally including internal zeros. The chosen component keeps its original orientation and colors while all other structure is discarded.
- **Hypothesis**: Compute connected components per color, rank them (e.g., by area or by having mixed colors inside), select the top-ranked component, and output its bounding box exactly as it appeared in the input.
- **Next Steps**: Refine the selection heuristic (area vs. color variety) so it reproduces the training choices consistently, and confirm behaviour if two components tie under the chosen metric.

## Puzzle caa06a1f (Medium)
- **Observation**: Inputs show a short cyclic stripe followed by a slab of filler `3`s. The outputs extend the true stripe everywhere, effectively shifting the pattern left by one step and tiling it across the full board while ignoring the filler.
- **Hypothesis**: Detect the fundamental horizontal period before the `3` plateau, perform a one-step left rotation of that cycle, and tile the rotated motif across the full width/height. Treat the filler color as pure padding.
- **Next Steps**: Automate the period finder (e.g., via prefix-function or brute force) and confirm both the horizontal and vertical repetitions obey the same cycle before generating the tiled canvas.

## Puzzle cbded52d (Medium)
- **Observation**: Non-zero rows come in triplets (two data rows plus a blank spacer) and follow the motif `A B 0 C D 0 E F`. The target enforces symmetry: columns 3 and 4 mirror the edge accents, and rows in the same cycle inherit the accent colors from the first row of that cycle.
- **Hypothesis**: Process the grid in 3-row cycles. For each cycle, copy the edge colors from the leading row into the subsequent row of that cycle and mirror them across the interior columns (set col3←col0 and col4←col7). Blank separators stay zero.
- **Next Steps**: Validate that this rule reproduces every training pair (especially the mixed 2/4 cases) and confirm there are no cycles shorter than three rows before locking in the implementation.

## Puzzle cdecee7f (Medium)
- **Observation**: Scanning the sparse 10×10 grids left-to-right produces a list of colored markers. The output is just that list packed into a 3×3 matrix in chunks of three, alternating direction per row (first chunk left→right, next chunk right→left, etc.). Remaining slots pad with zeros.
- **Hypothesis**: Collect all non-zero cells sorted by column (breaking ties by row). Fill the first output row with the first three values in order, reverse the next three for row two, switch back for row three, and so on while padding incomplete chunks with zeros.
- **Next Steps**: Ensure the sorter is stable for identical columns, and write tests for cases where the final chunk has fewer than three entries so padding stays deterministic.

## Puzzle ce9e57f2 (Medium)
- **Observation**: Columns of `2`s form stair-stepped ridges. The solver leaves the first few cells in each column as `2`, then recolors the remainder of each vertical run to `8`, creating a descending diagonal frontier across columns.
- **Hypothesis**: For every column containing `2`s, keep the first three occurrences as `2` and rewrite the rest as `8`, producing the same staggered boundary seen in training.
- **Next Steps**: Verify the “top-three” threshold applies uniformly across columns (especially shorter runs) and add a quick assertion that no other colors get touched.

## Puzzle cf98881b (Medium)
- **Observation**: Wide 4×14 mosaics collapse to 4×4 signatures whose columns report the dominant color inside successive vertical bands (left core, 9-block, gap, tail). Each row in the output reproduces the majority palette of its corresponding band, so recurring `9/4/1/0` stripes remain visible even after compression.
- **Hypothesis**: Partition the input columns into four fixed groups (e.g., `[0..2]`, `[3..6]`, `[7..9]`, `[10..13]`) and, row by row, emit the modal non-zero color per group while falling back to `0` when a band is blank. The resulting 4×4 matrix matches all training pairs when ties prefer the higher-value color.
- **Next Steps**: Confirm the band boundaries by recomputing majority colors programmatically, especially on the test puzzle, and check whether ties ever occur so the tie-break rule is well defined.

## Puzzle d2abd087 (Medium)
- **Observation**: Fabrics of `5`s are recolored into `2`s, with any segments touching the left edge upgraded to `1`. Every connected component keeps its footprint; only the palette changes to distinguish edge-adjacent blobs from interior ones.
- **Hypothesis**: Extract each connected component of `5`. If any cell in the component touches the left border, repaint the component with `1`; otherwise recolor it with `2`. Zeros remain zeros.
- **Next Steps**: Confirm border detection only checks the true outer boundary (not internal holes) and ensure components touching both left and right edges still resolve to `1` under the current rule.

## Puzzle beb8660c (Medium)
- **Observation**: Each input row either contains a single contiguous non-zero run or is all zeros. The output keeps the same height but right-aligns those runs so that the thinnest stripe (length 1) sits highest and each longer stripe appears one row lower, forming a descending staircase of blocks on the eastern edge.
- **Hypothesis**: Extract every non-zero run, record its length, sort the runs by length ascending (stable for ties), and write them back from top to bottom while right-aligning each run within the row. All-zero rows remain zero at the top.
- **Next Steps**: Check the tie cases (equal-length runs) to confirm the training data preserves their original order, and add guards to keep an output row zero when the source row was empty.

## Puzzle c909285e (Medium)
- **Observation**: The large grids are built from repeated stripes; outputs condense them into a 7×7 motif that captures a single fundamental period of both the horizontal and vertical repetition, including the leading and trailing border rows of solid color.
- **Hypothesis**: Compute the minimal repeating period along rows and columns (by finding where sequences start repeating), crop the input to that fundamental tile, and return it as the answer.
- **Next Steps**: Confirm the period truly factors both dimensions for all examples, and add safeguards in case noise breaks perfect periodicity (e.g., fall back to the smallest period that still satisfies most rows).

## Puzzle 9dfd6313 (Medium)
- **Observation**: Every matrix has color `5` locked on the main diagonal, with any other colors living strictly below it. The outputs are upper-triangular: the diagonal `5`s stay put, all entries below the diagonal are zeroed out, and the lower-triangular colors are mirrored to the symmetric positions above the diagonal.
- **Hypothesis**: Iterate over cells `(r,c)` where `r>c`, copy their color to `(c,r)` when non-zero, then blank the original location. Leave diagonal `5`s untouched so the triangular frame persists.
- **Next Steps**: Confirm there are never non-zero entries above the diagonal in the input (so we do not accidentally overwrite valid data), and ensure repeated mirroring of the same color behaves when multiple distinct hues appear in the lower triangle.

## Puzzle 9f236235 (Medium)
- **Observation**: The boards consist of large toroidal tilings—blocks of a dominant color bordered by a secondary ring. Outputs shrink them to coarse maps whose cells reuse the block colors, effectively reporting which motifs sit in each macro quadrant.
- **Hypothesis**: Infer the tile period by scanning for repeating rows/columns (training shows 5-cell motifs), partition the grid into those macro tiles, take the majority color per tile, and arrange those colors into the reduced matrix.
- **Next Steps**: Validate the inferred period on all examples, handle edge tiles that may be truncated, and ensure the downsample preserves the original orientation (no rotation or reflection).

## Puzzle a1570a43 (Medium)
- **Observation**: Color `2` forms an L-shaped arm anchored near one corner while `3`s sit at opposite corners. The transformation rotates the `2` arm by 90° around the grid center, swapping its vertical column with a horizontal bar (and vice versa) while the `3`s stay fixed.
- **Hypothesis**: Extract the bounding box of the `2` component, rotate its mask clockwise, and paste the rotated mask back into the same bounding box. Because the component is axis-aligned, the rotated rows/columns land neatly without overlap.
- **Next Steps**: Confirm the shape is always a simple rectilinear L (no branching), decide tie-breaking if rotation would leave the bounding box, and check whether counter-clockwise rotation ever appears in alternate variants.

## Puzzle a3325580 (Medium)
- **Observation**: Non-zero colors appear as disjoint blobs clustered by hue. The output is a color palette: one column per hue (ordered by the blobs’ left-to-right position), with each column filled uniformly by that color and repeated for as many rows as the combined blob stack spans.
- **Hypothesis**: Segment connected components, sort them by the minimum column index, and collect their colors. Compute the vertical span of the union of all components and emit a rectangle of that height whose columns are constant-color stripes matching the sorted list.
- **Next Steps**: Validate that components never overlap in column order (to keep the ordering unambiguous), and adjust the palette height rule if a future example introduces taller stacks that extend beyond the shared span.

## Puzzle a3df8b1e (Medium)
- **Observation**: Inputs are almost empty except for a single `1` in the bottom-left corner. Outputs animate that `1` across the row width: each successive row advances the lit column one step to the right, bouncing off the far edge and reversing direction to produce a repeating sawtooth.
- **Hypothesis**: Initialize the “cursor” at the column containing the original `1`, move it by `+1` each row, and flip the direction when the cursor hits either end (0 or `width-1`). Stamp a `1` at the cursor column in every row, clearing other cells to `0`.
- **Next Steps**: Confirm the starting direction (rightward) holds for all cases and ensure the edge bounce logic handles widths down to two columns without skipping positions.

## Puzzle 9af7a82c (Medium)
- **Observation**: Inputs are compact rectangles with no zero background; the outputs turn the palette into a vertical histogram. Colors are sorted by descending frequency to form the top row, the tallest column height equals the maximum count, and each column keeps its color for as many rows as that color appeared in the input before trailing zeros pad the rest.
- **Hypothesis**: Ignore color `0`, tally occurrences for every remaining color, sort `(color, count)` pairs by count (break ties by first-seen order), allocate an output grid of size `max_count × num_colors`, then fill each column top-down with its color for `count` cells and `0` below.
- **Next Steps**: Confirm tie-handling on any samples with equal counts, ensure accidental zeros in the input remain excluded from the histogram, and double-check the test case produces the 6-row height predicted by the maximum frequency.

## Puzzle 3bdb4ada (Medium)
- **Observation**: Each non-zero color appears in a stripe at least three rows tall separated by all-zero rows. Outputs leave the stripe’s outer rows untouched but transform the middle row into an alternating sequence of color/zero, starting with the color wherever the stripe originally had color.
- **Hypothesis**: Segment the grid into color stripes using connected row ranges. For stripes of height ≥3, keep the top and bottom rows as-is and rewrite each middle row so occupied columns alternate between the stripe color and zero. Stripes of height two or less remain unchanged.
- **Next Steps**: Generalize the alternation to any stripe width, ensure we only toggle columns that were originally non-zero, and add a guard for odd-width stripes so the pattern always ends on the stripe color.

## Puzzle 3de23699 (Medium)
- **Observation**: Inputs feature a framed color wrapped around a central motif composed of a second color. The outputs isolate the motif: they crop the minimal bounding box that covers the interior color and recolor its cells with the framing color, yielding a compact emblem.
- **Hypothesis**: Detect the color that never touches the border, take its bounding box, and emit that submatrix after swapping its color to the frame color observed nearby. All zeros inside the box remain zeros so the motif’s negative space is preserved.
- **Next Steps**: Confirm only one qualifying interior color exists, record the correct frame color from the original grid, and keep an eye out for variants where the motif spans multiple disjoint components.

## Puzzle 3eda0437 (Medium)
- **Observation**: Rows composed of `1`s with a single internal gap gain a bridge of `6`s across that gap in the output. The inserted `6`s occupy the same column span across every affected row and only appear when the row has `1`s on both sides of the gap.
- **Hypothesis**: Scan for the longest column interval where at least one row has zeros bracketed by `1`s. Use that interval as the shared gap and fill it with `6` on each row that also has `1` immediately to the left and right. Leave all other cells untouched.
- **Next Steps**: Codify the gap finder, ensure we do not paint rows whose flanks are missing, and verify multiple qualifying gaps do not occur in the same puzzle (fallback to the widest if they do).

## Puzzle 4093f84a (Medium)
- **Observation**: A solid mid-band of `5`s sits in the center while stray markers of another color (`2`, `3`, `4`) hover above or below. The solution erases the markers themselves and instead plants `5`s directly above or below the band in the same columns, so every marker becomes a support peg on the buffer rows bracketing the slab.
- **Hypothesis**: Identify the contiguous band of `5`s, clear all non-`5` cells elsewhere, and for each removed marker drop a `5` one row outside the band on the closest side (above for markers above, below for markers below). Leave everything else unchanged so the slab and its new posts match the outputs.
- **Next Steps**: Derive the band limits automatically (first/last row containing `5`), double-check behavior when a marker sits exactly at band level, and guard against collisions if two markers project onto the same buffer cell.

## Puzzle 41e4d17e (Medium)
- **Observation**: The input is almost entirely `8`, with crosses of `1`s embedded in different quadrants. The outputs wrap those crosses in a halo of `6`s: every row or column intersecting a `1` gets `6` on the exterior, creating fat orthogonal bars while keeping the original `1` skeleton intact.
- **Hypothesis**: Compute the row and column spans of each connected `1` cluster, fill the bounding rows/columns (excluding the actual `1` cells) with `6`, and leave all other `8`s untouched. Where the cross splits across quadrants, ensure the surrounding halo remains continuous.
- **Next Steps**: Handle overlapping spans so `6`s do not overwrite `1`s, confirm the same logic works when the cluster is rotated or mirrored, and test a case where two crosses share a row to confirm the halos merge cleanly.

## Puzzle 4347f46a (Medium)
- **Observation**: Wide solid rectangles of a single color become hollow frames: border pixels remain, interior pixels on both axes are cleared to `0`, and only the perimeters plus any shared seams with adjacent blocks survive.
- **Hypothesis**: For each color component, compute its bounding box and reset every interior cell (strictly inside the box) to `0`, leaving the outline intact. When two boxes share an edge, keep that edge filled so adjoining frames still touch.
- **Next Steps**: Confirm the hollows do not delete single-column components (degenerate boxes), ensure shared borders are detected before zeroing, and test the routine on stacked frames like the mixed 8/6/4/3 example.

## Puzzle 444801d8 (Medium)
- **Observation**: Each plus-shaped figure of `1`s with a distinct center color is “inflated” into a rounded badge: the arm endpoints and the diagonal gaps become the center color, yielding a 5×5 neighborhood with the original `1` outline and a solid block of the special color inside. Separate figures (with different center colors) are treated independently.
- **Hypothesis**: For every connected component that contains `1`s and a unique core color `c`, fill the component’s bounding box with `c` except for the perimeter cells already holding `1`, which are left untouched.
- **Next Steps**: Work out how to locate the core color programmatically (the non-`1` inside the component), ensure overlapping boxes don’t smear colors together, and add test cases where the component is rotated or shifted.

## Puzzle 447fd412 (Medium)
- **Observation**: Sparse clusters of `1`s and pairs of `2`s get upgraded into tidy lozenges: the existing `1`s remain, but rows and columns spanning each `2` cluster are backfilled with `1` so the `2`s sit inside a solid rectangular band. Additional `1` strips connect adjacent clusters so the bottom half turns into a filled bar while the top motif stays as-is.
- **Hypothesis**: For every row (or column) containing two separated `2` blocks, fill the run between them with `1`s, and likewise cap the run vertically so each pair forms a rectangular patch of `1`s enclosing the `2`s. Preserve all pre-existing non-zero entries elsewhere.
- **Next Steps**: Detect paired `2`s reliably (width, spacing), keep fills from bleeding into unrelated `2`s, and verify the algorithm leaves untouched regions (like single crosses of `1`s) unchanged.

## Puzzle 44d8ac46 (Medium)
- **Observation**: Large `5` polyominoes often contain interior cavities of `0`s. The transformation recolors every fully enclosed `0` to `2` while leaving the surrounding `5`s alone, effectively highlighting the holes without altering the exterior silhouette.
- **Hypothesis**: Flood-fill from the border to mark “outside” zeros, then traverse the remaining unmarked zeros (the cavities) and repaint them as `2`.
- **Next Steps**: Implement the border flood fill so touching-the-edge voids stay zero, confirm multiple disjoint cavities are handled, and test a case where a cavity is only one cell wide.

## Puzzle 4612dd53 (Medium)
- **Observation**: Thin blue `1` paths snake through a large grid; the solution interleaves green `2`s between neighbouring `1`s, creating checkerboard strips along straight runs and sprinkling `2`s at turns while preserving the original `1`s.
- **Hypothesis**: Traverse every row and column containing `1`s, filling each zero that lies between successive `1`s in that line with `2`, and treat L-shaped junctions as two overlapping runs so the corner gets both colours.
- **Next Steps**: Guard against gaps longer than one cell, prevent double-filling from producing stray colours, and confirm isolated single `1`s stay untouched.

## Puzzle 46f33fce (Medium)
- **Observation**: Sparse coloured pixels in a 10×10 grid turn into disjoint 4×4 monochrome blocks in a 20×20 canvas; the blocks align on a 5×5 coarse grid whose indices reflect the input pixel’s quadrant.
- **Hypothesis**: Partition the output into 4×4 tiles; for every non-zero input cell, compute `tile = (row // 2, col // 2)` (since 10/2=5) and flood that tile with the cell’s colour, leaving all other tiles black.
- **Next Steps**: Confirm multiple pixels mapping to the same tile agree on colour, decide which pixel wins if colours differ, and verify edge coordinates (rows or columns 9) still land in the intended tile.

## Puzzle 4938f0c2 (Medium)
- **Observation**: Inputs feature isolated bars of `2`s plus a small `3×3` patch of `3`s. The output duplicates the `2` pattern into opposite quadrants so the bars appear on both the top-left and bottom-right blocks while mirroring the `3`s into a central belt, yielding fourfold symmetry.
- **Hypothesis**: Treat the canvas as a 2×2 grid of regions: replicate the northern `2` structure into both top and bottom halves, mirror it horizontally for the right side, and leave the `3` patch fixed in the middle columns.
- **Next Steps**: Pin down the exact region boundaries, confirm longer `2` chains wrap correctly, and ensure the mirroring step does not overwrite the `3` block.

## Puzzle 4c5c2cf0 (Medium)
- **Observation**: Sparse colour blobs (2s, 4s, etc.) get replicated across the cardinal axes, yielding a design that is symmetric under horizontal and vertical reflection while preserving the original components.
- **Hypothesis**: For every coloured cell, stamp its value at all reflections across the horizontal and vertical midlines (and both) to achieve fourfold symmetry.
- **Next Steps**: Nail down the exact centre definition for odd/even dimensions, guard against double-writing different colours, and confirm overlapping reflections do not introduce unintended mixing.

## Puzzle 50846271 (Medium)
- **Observation**: The grids teem with `5`s punctuated by `2` markers; whenever a row or column contains two or more `2`s, the intervening `5`s flip to `8`, forming highlighted corridors that bridge the markers while leaving other `5`s untouched.
- **Hypothesis**: Scan each row and column, identify stretches of `5`s bounded by `2`s at both ends, and recolour those stretches to `8` without bleeding past the bounding markers.
- **Next Steps**: Decide how to treat L-shaped runs where rows and columns interact, clarify behaviour when more than two `2`s share a line, and ensure isolated `2` cells do not spawn stray `8`s.

## Puzzle 508bd3b6 (Medium)
- **Observation**: With vertical bands of `2`s and offsets of `8`s, the solution paints a diagonal ribbon of `3`s stepping one column right (or left) per row to connect the first coloured anchor to the opposite band.
- **Hypothesis**: Trace a straight-line path from the lone `8` cluster to the nearest `2` column and lay down `3`s along the discrete diagonal while preserving any existing colours encountered.
- **Next Steps**: Formalise how the diagonal chooses its start row, verify behaviour when multiple `8`s or `2` stripes exist, and confirm the path respects grid bounds without overshooting.

## Puzzle 54d9e175 (Medium)
- **Observation**: Two vertical rails of `5`s sandwich digits that act as selectors; the output turns each digit family into a solid three-column slab recoloured to `value + 5`, cloning that slab across all rows of its stripe while keeping the `5` pillars intact.
- **Hypothesis**: For every non-zero entry between the rails, map its value through a fixed lookup `{1→6, 2→7, 3→8, 4→9}`, flood the corresponding three-column band with that colour, and leave untouched rows of pure `5`s as separators.
- **Next Steps**: Confirm the palette mapping covers every digit that can appear, decide how to treat simultaneous different digits within the same stripe, and ensure blank slots remain the original background colour.

## Puzzle 5521c0d9 (Medium)
- **Observation**: Disjoint rectangular carpets (typically `1`, `2`, and `4`) get vertically compacted: each block slides into its own contiguous band, preserving its width and pattern but stripping out the zero-only rows that separated the colours in the input.
- **Hypothesis**: Extract the bounding box for each colour component, sort the boxes by their original top row, and reassemble the grid by stacking those slices in order with optional blank buffers so they no longer overlap.
- **Next Steps**: Validate the sorting key when multiple components share a top row, ensure horizontally overlapping boxes are still moved as a unit, and watch for edge cases where two colours interleave within the same rows.

## Puzzle 5c0a986e (Medium)
- **Observation**: Each input contains one or more 2×2 squares of a colour. The output extends every square along a 45° path toward the nearest board corner, ejecting a single-cell trail of that colour while leaving the original 2×2 footprint intact.
- **Hypothesis**: Detect 2×2 blocks, choose their travel direction (up-left for the upper block, down-right for the lower block in training), and write a one-cell-wide diagonal of the same colour until reaching the border or another coloured cell.
- **Next Steps**: Formalise how the direction is selected (seems based on whether the block sits in the top/bottom half), ensure new strokes do not overwrite other colours, and clarify whether both diagonals should be drawn when a block sits near the centre.

## Puzzle 60b61512 (Medium)
- **Observation**: Clusters of `4`s gain a `7` halo on the side where the cluster thins out: the north-west corner of each block turns into a descending staircase of `7`s while the opposite corner remains pure `4`.
- **Hypothesis**: For every `4` component, identify exposed edges (cells whose orthogonal neighbour is zero) and recolour those frontier cells to `7`, keeping interior `4`s untouched so the original silhouette remains.
- **Next Steps**: Validate which frontier orientations flip to `7` (diagonals vs orthogonal), confirm the rule is applied independently to separated components, and check that components touching the boundary still receive the correct edging.

## Puzzle 6455b5f5 (Medium)
- **Observation**: The layouts feature a rigid frame of `2`s enclosing empty corridors plus small accent colours. Outputs keep the `2` frame intact but (a) fill the rectangular interior cavity with `1`s and (b) place `8`s on the two exposed corners of the frame so the border becomes fully closed.
- **Hypothesis**: Detect the minimal rectangle spanned by the `2` scaffold; repaint every zero inside that box with `1`, then scan the frame for corner cells that currently hold `0` and replace them with `8`. Other colours remain untouched.
- **Next Steps**: Validate the bounding-box filler on all training boards, ensure we only overwrite zeros (never the original `7`/`8` markers), and check that the test grid’s interior cavity matches the same rectangular footprint.

## Puzzle 673ef223 (Medium)
- **Observation**: Enormous blank grids show a vertical `5` spine with a handful of `8` seeds dotted near it and `2`s acting as blockers. The outputs inflate each `8` seed into a rectangular bar of `8`s that stretches horizontally until the first non-zero, and they stamp a `4` at the boundary cell where the propagation collides with a `5`.
- **Hypothesis**: For every `8`, extend left and right through zeros, painting them `8` until meeting a non-zero; if the blocker is `5`, overwrite it with `4` to mark the junction. Leave the rest of the grid untouched.
- **Next Steps**: Code the bidirectional sweep, verify the collision handling (especially when two expansions meet), and ensure vertical propagation is unnecessary (training never extends vertically).

## Puzzle 6773b310 (Medium)
- **Observation**: Two solid rows of `8` partition each 11×11 board into three horizontal bands. The 3×3 output encodes which of the left/mid/right columns within each band contain at least one `6`: row 0 of the output summarises the upper band, row 1 the middle band, row 2 the lower band.
- **Hypothesis**: Split the grid around the `8` rows, bin every non-`8` cell within each band into three coarse columns (left third, middle third, right third), and set the corresponding output cell to `1` if that bin hosts a `6` anywhere.
- **Next Steps**: Work out the exact column ranges (the examples suggest groups of 3,5,3 columns), confirm the binning reproduces all four training outputs, and double-check the mapping on the test puzzle.

## Puzzle 67a423a3 (Medium)
- **Observation**: A single vertical spine (colour `3`, `6`, or `5`) sits in otherwise empty grids. The outputs add a horizontal band of `4`s centred on the row where the non-zero “platform” lives, creating a little plus-shape while leaving the bands above/below unchanged.
- **Hypothesis**: Locate the unique row that contains additional structure (the row of `2`s, `8`s, or `3`s) and paint a 3-cell run of `4`s symmetric around the spine within that row and its immediate neighbours, respecting any existing colours at the centre.
- **Next Steps**: Confirm the band width is always three cells, ensure we do not overwrite the spine colour, and check the test case’s platform row to place the `4`s correctly.

## Puzzle 694f12f3 (Medium)
- **Observation**: Each rectangular field of `4`s gains a coloured inlay. The algorithm leaves the `4` border intact but rewrites the maximal interior rectangle with a secondary colour (`1` for the upper block, `2` for the lower/ right block), effectively carving a framed plaque.
- **Hypothesis**: Detect every solid `4` rectangle, shave one cell off each side to get its interior, and flood that interior with the learnt highlight colour tied to the block’s location (top block→`1`, bottom block→`2`).
- **Next Steps**: Parameterise block detection so rotated cases (wider top, narrower bottom) still map to the same highlight, and confirm there are never more than the two rectangles seen in training.

## Puzzle 6c434453 (Medium)
- **Observation**: Inputs are drawn in `1`s; outputs highlight the spines of each plus/T junction with `2`s while keeping stray `1`s elsewhere. Wherever a `1` has orthogonal neighbours forming a cross, its row/column arms turn to `2`, leaving the diagonals and solitary pixels unchanged.
- **Hypothesis**: For every `1` cell whose von Neumann degree ≥2, recolour that cell and its orthogonal neighbours in the same run to `2`, otherwise leave it as `1`. Apply the rule independently to each junction so multiple crosses can coexist.
- **Next Steps**: Verify the arm lengths (mostly three-cell runs) before recolouring, prevent neighboring crosses from overwriting each other, and confirm that isolated `1`s truly remain unmodified.

## Puzzle 6cdd2623 (Medium)
- **Observation**: Despite the clutter, only one colour matters—the one that touches the border most prominently. The output clears everything else and draws a bold cross of that colour: a full-width horizontal bar plus a full-height column through the cross’s centre.
- **Hypothesis**: Identify the boundary-dominant colour (seen hugging the outer rim), choose a central row/column (from the colour’s median coordinates), fill that row and column with the colour, and zero every other cell.
- **Next Steps**: Formalise the boundary-selection heuristic, ensure the chosen row/column align with the training placements, and document how to break ties if two colours share the border in future cases.

## Puzzle 6e19193c (Medium)
- **Observation**: Small L-shaped clusters of a color (`7`, `9`, `8`) keep their original footprint, and the output adds a matching trail that walks back toward the opposite corner along the long diagonal, creating a zig-zag echo of the cluster.
- **Hypothesis**: After copying the input, propagate each connected component diagonally toward the northwest (wrapping around the grid edges) until it hits the boundary, writing the same color along that path.
- **Next Steps**: Validate the propagation direction in all samples (it appears to march toward the top-left), ensure we don’t duplicate cells already filled, and test the idea on the held-out board.

## Puzzle 6ecd11f4 (Medium)
- **Observation**: Large canvases hide a small multicolour patch near the bottom. The solution crops that patch (3×3 or 4×4) and then suppresses the plus-shaped cross inside it, leaving only corners and a few diagonals while keeping the centre color.
- **Hypothesis**: Locate the minimal bounding box containing all non-zero cells, copy it to the output, and mask out the four orthogonal neighbours of the centre (set them to `0`).
- **Next Steps**: Verify the mask size adapts between 3×3 and 4×4, and ensure we don’t erase legitimate duplicates when the box contains repeated colours on the axes we zero out.

## Puzzle 73251a56 (Medium)
- **Observation**: The inputs resemble multiplication tables with zero “holes.” Outputs fill every zero gap by extending the nearest run so that each row/column becomes a contiguous monotone ramp of the existing palette—no new colors appear, only the missing entries are backfilled.
- **Hypothesis**: For each row, replace interior zero runs with the nearest non-zero value (prefer the left neighbor, fall back to the right). Repeat column-wise to mop up any residual zeros so the lattice is fully populated.
- **Next Steps**: Encode a two-pass fill (row then column) and double-check that it reproduces the training transformations exactly, especially in bands where zeros border different colors.

## Puzzle 746b3537 (Medium)
- **Observation**: Every example consists of repeated identical rows or columns. The solution collapses those redundancies, leaving one representative per distinct stripe (vertical or horizontal), so the dimensionality shrinks to the true number of unique stripes.
- **Hypothesis**: Check whether rows or columns are duplicates; if rows repeat, drop duplicates and keep a single copy per unique row. Otherwise, transpose first (or operate column-wise) to achieve the same effect.
- **Next Steps**: Codify a de-duplication pass that preserves the order of first occurrence and verify the column-oriented samples are handled by switching perspective as needed.

## Puzzle 760b3cac (Medium)
- **Observation**: The non-zero mass already forms a compact blob; the outputs realign its columns so the `2`s slide leftward into a consistent diagonal while the `8`s fill the remaining slots. Essentially each row of the blob is rotated until the `2`s stack at the earliest columns without disturbing row counts.
- **Hypothesis**: Crop the `8/2` region then, row by row, rotate the cells so that the `2` cluster starts at the leftmost position observed anywhere in that row, keeping the `8`s in order. Finally paste the adjusted block back (or just return it cropped, since zeros stay zero outside).
- **Next Steps**: Verify this “left-align the twos within each row” rule on all training cases and ensure the injected shifts still place the block correctly for the test example.

## Puzzle 780d0b14 (Medium)
- **Observation**: Inputs are stacked horizontal bands separated by blank rows. Within each band only a handful of colors appear, arranged in wide vertical stripes. The outputs collapse each band to a single row whose entries list the distinct non-zero colors encountered from left to right, so a two-band input becomes a two-row palette matrix, and a three-band layout yields three rows, etc.
- **Hypothesis**: Split the grid on all-zero rows to identify bands, strip zeros from each band, read the remaining colors in column order (coalescing consecutive repeats), and emit that color sequence as one row of the answer. Stack the per-band sequences in top-to-bottom order to form the final matrix.
- **Next Steps**: Confirm that a simple run-length reduction within each band matches all training outputs, decide how to treat bands where a color reappears later (drop duplicates or keep them), and ensure the method tolerates bands of differing heights.

## Puzzle 794b24be (Medium)
- **Observation**: Sparse 3×3 masks of `1`s shrink to an abstract bounding-box signature: the top row of the output is filled with `2`s across the horizontal span covered by any `1`, and when the occupied rows span both the top and bottom, a single `2` appears in the center column of the middle row to mark the vertical extent. All other cells stay zero.
- **Hypothesis**: Compute the min/max columns containing `1`s and paint that range on the first row with `2`. If the set of occupied rows has height greater than one, also drop a `2` at the midpoint `(1, (minCol+maxCol)/2)` to memorialize the vertical reach.
- **Next Steps**: Double-check edge cases with a single column or row of `1`s (no middle-row marker), confirm the center-column choice for asymmetric spans, and verify duplicated `1`s do not alter the rule.

## Puzzle 7b7f7511 (Medium)
- **Observation**: Each board is built by repeating a short sequence of rows (or columns) two or more times—sometimes as a doubled block, sometimes as a simple cycle. The outputs keep exactly one period of that sequence, removing duplicate repetitions.
- **Hypothesis**: Detect the smallest vertical period by scanning for the first row where the pattern restarts, slice out that many rows as the canonical block, and return it (transposing first if the repetition is horizontal).
- **Next Steps**: Add a routine to compare successive row blocks efficiently, handle square vs rectangular periods, and confirm the transpose trick covers the example where columns repeat instead of rows.

## Puzzle 7ddcd7ec (Medium)
- **Observation**: Each input has a small 2×2 nugget of color (`3`, `4`, or `7`) with one face attached to the main diagonal. The outputs extend that nugget by planting single pixels of the same color along the southeast diagonal, creating a staircase that runs to the edge while leaving the rest of the grid untouched.
- **Hypothesis**: Locate the 2×2 block, copy it verbatim, and then iteratively step one cell down-right from its far corner, writing the block’s color onto each new diagonal location until the border is reached, skipping cells that already host that color.
- **Next Steps**: Work out whether the extension should start from the nugget’s bottom-right or top-left corner, guard against multiple nuggets, and confirm the iteration stops exactly at the grid boundary without overshooting.

## Puzzle 80af3007 (Medium)
- **Observation**: Giant boards contain only `0` and `5`, with the `5`s forming disjoint 3×3 bricks on a coarse grid. The outputs crop to the brick lattice and replace each solid 3×3 with a five-point “star” (corners plus centre) while leaving gaps and background at `0`; touching bricks simply overlay their stars.
- **Hypothesis**: Locate every 3×3 block filled with `5`, keep a canonical `5` template for the star pattern, and stamp it into the cropped output while ignoring empty cells.
- **Next Steps**: Verify that partially filled bricks never appear, guard against star overlaps introducing extra `5`s, and confirm we really do crop to the minimal bounding box before drawing.

## Puzzle 855e0971 (Medium)
- **Observation**: Inputs are broad horizontal stripes of a single color with isolated `0`s punched into them. In the outputs those `0`s “spread” orthogonally—entire rows or columns inside the affected stripe flip to `0`, carving clean rectangular gaps while the untouched stripes remain solid.
- **Hypothesis**: Within each constant-color stripe, detect any row or column containing a `0` and repaint that whole cross-section of the stripe with `0`, leaving the other stripes unchanged.
- **Next Steps**: Formalize whether holes always propagate along rows, columns, or both (the training set exhibits both behaviours), and ensure the detection respects stripe boundaries so zeros never leak into neighbouring colors.

## Puzzle 85c4e7cd (Medium)
- **Observation**: Every grid is a set of concentric rings. The output keeps the geometry identical but reverses the color order: the outer band adopts the innermost color, the next band inherits the second-to-last color, and so on toward the center.
- **Hypothesis**: Compute the layer index (distance from the nearest border) for each cell, collect the sequence of colors by layer, reverse that sequence, and repaint each layer with its new color while preserving shape.
- **Next Steps**: Confirm the layer detector handles odd-sized centers (single cells vs 2×2 cores) and extend the reversal logic to rectangular grids in case a variant appears.

## Puzzle 88a10436 (Medium)
- **Observation**: Apart from a single `5`, all non-zero pixels form one tight motif. In the output that motif is cloned and translated so that it sits on top of the `5`, overwriting the marker while leaving the original copy in place; everything else remains zero.
- **Hypothesis**: Extract the bounding box of all non-zero cells except the lone `5`, calculate the translation vector from the motif’s anchor to the `5`, and stamp a duplicate of the motif at the translated position (clipped to the grid), overwriting the `5` in the process.
- **Next Steps**: Confirm the translation is always a pure shift (no rotation), decide how to handle overlaps when the translated motif would extend outside the grid, and ensure no puzzle contains more than one marker.

## Puzzle 88a62173 (Medium)
- **Observation**: Inputs are 5×5 crosses with an all-zero middle row and column. The outputs shrink to 2×2 by sampling the colors nearest the center along each diagonal: the northwest and northeast cells report the color at `(row 2, col 2/4)`, while the southwest cell chooses the first non-zero encountered moving downward from `(4,2)` when the immediate neighbor is zero.
- **Hypothesis**: Read the four cells adjacent to the central cross ((2,2), (2,4), (4,2), (4,4)), falling back to the next cell in the same quadrant if the immediate neighbor is zero, and place those colors into the corresponding slots of the 2×2 output.
- **Next Steps**: Verify the fallback rule for the southwest (and potentially southeast) quadrant across all samples, and ensure rotations or mirrored layouts would still map correctly.

## Puzzle 890034e9 (Medium)
- **Observation**: Huge boards contain dense carpets punctured by rectangular pockets of zero. The outputs keep the surrounding texture intact but fill each pocket with the dominant color already bordering it (`2`, `4`, or `8`), eliminating the voids while respecting the original block boundaries.
- **Hypothesis**: Detect the axis-aligned bounding boxes of non-zero color clusters, and for any box whose interior contains zeros, flood that interior with the cluster’s color while leaving exterior regions unchanged.
- **Next Steps**: Work out a reliable way to pair each zero pocket with its owning color cluster (especially when multiple colors overlap) and double-check that no new color introduction is required beyond reusing the existing block color.

## Puzzle 8efcae92 (Medium)
- **Observation**: Each grid is mostly blank except for several solid rectangles made of color `1` with a few embedded `2`s. The answer always reproduces exactly one of those rectangles—the one whose interior contains the largest number of `2` pixels.
- **Hypothesis**: Label connected non-zero components, count how many `2`s each component holds, choose the component with the maximal `2` count (breaking ties by e.g. earliest component index), and crop its bounding box as the output.
- **Next Steps**: Implement component extraction plus color counting, add a deterministic tie-breaker, and verify the test scene where the chosen block is the only one with ten `2`s concentrated in the center band.

## Puzzle 8d5021e8 (Medium)
- **Observation**: Each 3×2 seed expands into a 9×4 quilt: rows are widened by tacking the reversed row in front of the original, and the three resulting rows are stacked in the order reverse→original→reverse to make a 3-period that repeats vertically.
- **Hypothesis**: For every input row `r`, form `rev(r)+r`; build the output by concatenating that list with its reverse and the original again (i.e., `[rev, orig, rev]`).
- **Next Steps**: Codify the row transformer, assemble the vertical stack, and add a sanity check that the pattern always repeats exactly three times.

## Puzzle 8d510a79 (Medium)
- **Observation**: A solid row of `5`s splits the board into upper and lower chambers. Sparse markers of `1` and `2` extend into full vertical bands within their half: above the `5` strip the columns fill downward to the barrier, below it they fill upward to the barrier and downward to the floor, yielding solid columns per color.
- **Hypothesis**: Treat the regions above and below the `5` row separately; for each column that contains `1` or `2` in a region, paint every cell between that region’s extremal occurrence and its boundary (either the `5` row or the edge) with the same color.
- **Next Steps**: Implement per-column propagation constrained by the `5` row, resolve conflicts when both colors share a column (training never overlaps, but add precedence), and verify the behaviour on the bottom-half columns that require filling both directions.

## Puzzle 8e5a5113 (Medium)
- **Observation**: The leftmost 3×3 patch carries the interesting data; the rest is scaffolding of zeros and `5`s. Outputs keep the original patch, then append its 90° clockwise rotation before the right `5` column and its 90° counter-clockwise rotation after, creating three orientations of the same block separated by `5`s.
- **Hypothesis**: Cut out the 3×3 block in columns 0–2, compute its rotations, and assemble `original + [rotCW] + 5 + [rotCCW]` to rebuild each row.
- **Next Steps**: Double-check row ordering of the counter-clockwise section (needs a flipped row order to match training) and make sure rotations respect the row/column indices when pasted back.

## Puzzle 8eb1be9a (Medium)
- **Observation**: Each example hides a compact 3-row motif of `8`s and zeros. The answer tiles that motif repeatedly (row-wise and column-wise) to cover the entire canvas, yielding a periodic wallpaper that matches the learned fundamental period.
- **Hypothesis**: Extract the minimal repeating tile (here 3×19 or 3×12 depending on the sample) and tile it vertically until the grid height is filled.
- **Next Steps**: Automate motif detection via finding the first repeated row triplet, then implement repetition; confirm columns also follow the same period so horizontal tiling is unnecessary.

## Puzzle 8f2ea7aa (Medium)
- **Observation**: Non-zero cells occupy a single tight 3×3 bounding box near the top-left. The output stamps that box along the main diagonal in steps of three rows and columns, cloning the shape into a staircase of copies until the board is filled.
- **Hypothesis**: Isolate the bounding box of non-zero cells, then iterate over offsets `(k*3, k*3)` while the box fits, copying the block each time.
- **Next Steps**: Generalise the step size (deduced from the box height/width), clip when the shifted box would overflow, and ensure overlapping copies do not double-write conflicting colors.

## Puzzle 90c28cc7 (Medium)
- **Observation**: Huge grids split cleanly into rectangular macro-tiles separated by all-zero gutters. The output shrinks those tiles to a coarse mosaic where each cell reports the solid color of the corresponding tile.
- **Hypothesis**: Partition the grid by zero rows/columns to find tile boundaries, compute the dominant (only) color per tile, and render a reduced matrix with those colors in tile order.
- **Next Steps**: Handle variable tile counts in each dimension, make sure zero-only tiles stay zero, and add validation that every tile is monochrome before sampling.

## Puzzle 91714a58 (Medium)
- **Observation**: Despite the clutter, every training scene hides a wide horizontal slab where a single colour repeats with consistent width and height (e.g., a 2×? band of `2`s or a 2×? band of `6`s). The outputs zero everything except that slab, returning a clean rectangle painted uniformly with the stripe’s colour.
- **Hypothesis**: Scan for colours that occupy the same contiguous columns across several adjacent rows, choose the largest such rectangle, and retain only that patch while blanking the remainder of the grid.
- **Next Steps**: Formalise the stripe detector (area-based tie-breaks, prefer the earliest/top-most band), ensure we tolerate noisy surroundings, and verify the selection scheme on the held-out board.

## Puzzle 928ad970 (Medium)
- **Observation**: A single “plus” glyph (colours `1`, `3`, `4`, or `8`) sits inside a field of zeros with a few `5` sentinels on the perimeter. The solution thickens that glyph into a hollow rectangle: the minimal box that encloses the plus turns into a one-cell-wide ring of the glyph colour, while the handful of `5`s remain pinned to their original sites outside the ring.
- **Hypothesis**: Extract the bounding box of the non-zero colour (ignoring the scattered `5`s), then rewrite just the border of that box with the glyph colour and keep the interior mostly zero. Leave any pre-existing `5`s untouched so they still sit mid-edge.
- **Next Steps**: Verify the ring builder holds when the plus is off-centre or touches the bounding wall, and double-check that multiple glyphs never coexist before coding.

## Puzzle 93b581b8 (Medium)
- **Observation**: Each scene contains a lone 2×2 motif; the answer copies its rows and columns to the surrounding quadrants, yielding four coloured “frames” that mirror the motif while the original stays in the middle. Essentially the motif’s rows become the west/east ribbons and its columns become the north/south ribbons.
- **Hypothesis**: Read the 2×2 patch, then tile its first row into the top band and its second row into the bottom band, while simultaneously tiling the first column into the left band and the second column into the right band. Keep the central 2×2 untouched.
- **Next Steps**: Implement the band copier with proper mirroring, and confirm the orientation matches what the training outputs show (no accidental rotations).

## Puzzle 9565186b (Medium)
- **Observation**: Dominant stripes (values `1`, `2`, `3`, or `4`) hold their ground, but all minority colours—including `8`s and lone digits inside the stripe—get homogenised to `5`, turning the mixed patches into two-tone slabs.
- **Hypothesis**: Detect the majority colour per row/column band and replace every non-majority, non-zero entry in that band with `5`, leaving the dominant colour and zeros alone.
- **Next Steps**: Validate the majority detector on the training set (especially the case with a `3`/`4` split) and check whether diagonally adjacent minority colours should also flip or stay as-is.

## Puzzle 95990924 (Medium)
- **Observation**: Each `5` appears as part of a 2×2 block. The solver annotates the four orthogonal neighbours of that block with direction codes—`1` for the northwest corner, `2` northeast, `3` southwest, `4` southeast—leaving everything else unchanged. When multiple 2×2 blocks exist, each gets its own quartet of numbers.
- **Hypothesis**: For every maximal 2×2 cluster of `5`s, paint the four surrounding positions with the fixed `[1,2;3,4]` stencil (clipped at borders) while avoiding overwriting existing non-zero colours.
- **Next Steps**: Implement a 2×2 block finder, add border checks, and make sure overlapping stencils never conflict in the training grids.

## Puzzle a5f85a15 (Medium)
- **Observation**: Identical colours march down-right along long diagonals. The outputs keep the diagonal but recolour every second node (starting with the second) to `4`, producing a dashed brace that alternates between the original colour and `4`.
- **Hypothesis**: For each NW→SE diagonal consisting of the same non-zero colour, traverse in order and swap the colour at odd indices (1, 3, …) to `4` while leaving even indices untouched. Other pixels – including isolated copies of the colour – remain unchanged.
- **Next Steps**: Confirm no other diagonal orientation needs handling, guard against diagonals that break mid-way (ensure index resets after gaps), and add tests where diagonals intersect so we only recolour the intended chain.

## Puzzle a61ba2ce (Medium)
- **Observation**: Sparse coloured clusters sit in the four quadrants separated by blank rows/columns. The 4×4 output encodes each quadrant as a 2×2 block whose filled cells count the number of pixels in that quadrant (painted with the quadrant’s colour) in reading order; unfilled slots stay `0`.
- **Hypothesis**: Split the canvas by the blank cross, tally how many cells of each colour fall into the NW/NE/SW/SE quadrants, and for each quadrant fill that many slots (top-left to bottom-right) inside the corresponding 2×2 patch of the output using the quadrant’s colour.
- **Next Steps**: Validate the counting order on all trainings, confirm that quadrants never mix colours, and check how to behave if a quadrant contains more than four cells (extend to multiple passes or clamp?).

## Puzzle a64e4611 (Medium)
- **Observation**: Huge canvases of `8`s and `0`s contain a wide empty corridor between two busy regions. The outputs infill that corridor with a solid belt of `3`s, creating a vertical passage that spans every row where the gap existed, while leaving the original `8` scaffolding untouched.
- **Hypothesis**: Detect the maximal zero-only column band lying between the left/right `8` structures, then flood that band with `3` from the first row that touches either structure down to the last such row. If the void widens near the bottom, the belt grows with it as seen in training.
- **Next Steps**: Precisely measure the gap (start & end columns), ensure the painted belt does not overwrite any existing non-zero colours, and confirm behaviour when multiple disjoint corridors are present (likely choose the widest).

## Puzzle a65b410d (Medium)
- **Observation**: Inputs show a single row of contiguous `2`s inside an otherwise blank canvas. The output decorates above the row with a descending triangle of `3`s and below it with an ascending triangle of `1`s, both anchored to the left edge of the `2` run; triangle widths grow with the distance from the `2` band.
- **Hypothesis**: Let `n` be the length of the `2` run and `r` its row index. For the `r` rows above, fill row `r-k` columns `0..n+k-1` with `3` (k starting at 1), yielding the widening wedge; for rows below, write decreasing runs of `1`s so row `r+1` has length `n-1`, row `r+2` length `n-2`, etc.
- **Next Steps**: Handle grids where the `2` row is close to the border (clip triangles), and verify the arithmetic when `n` is 1 (wedge degenerates to empty bottom triangle).

## Puzzle a85d4709 (Medium)
- **Observation**: The 3×3 inputs contain a few `5`s arranged along one of four canonical shapes, and the output replaces the entire board with horizontal stripes of a label colour (`2`, `3`, or `4`) that encodes which shape appeared.
- **Hypothesis**: Classify the input by sampling the row/column layout of the `5`s (e.g., which column the topmost `5` occupies, whether it forms a column or diagonal), then emit the corresponding constant-row palette for that class.
- **Next Steps**: Catalogue all distinct `5` motifs observed so far, derive a deterministic mapping to the stripe colours, and add a guard for unexpected motifs (fallback to identity).

## Puzzle a87f7484 (Medium)
- **Observation**: Inputs concatenate several 3×3 motifs either vertically or horizontally. The solution picks the single motif with the largest count of non-zero cells and outputs it alone.
- **Hypothesis**: Slide a 3×3 window across the grid on the appropriate stride, tally the number of coloured cells in each window, and return the densest one (breaking ties in favour of the earliest occurrence).
- **Next Steps**: Verify that motifs never overlap awkwardly (so a simple grid partition suffices), and add tie-breaking tests in case two motifs share the same population.

## Puzzle a8d7556c (Medium)
- **Observation**: The boards are dense with `5`s and pockets of `0`. The outputs keep the `5` fabric intact but recolour specific zero corridors—particularly wide runs near the south-west—to `2`, turning those gaps into highlighted channels while leaving isolated zeros untouched.
- **Hypothesis**: Extract the connected zero component touching the south-west edge, then repaint any sub-run within that component whose width is at least two (horizontally or vertically) with `2`, skipping singletons and zeros that remain exposed to multiple non-`5` colours.
- **Next Steps**: Validate the component-selection heuristic on every training pair, refine the width test so only the intended corridors flip to `2`, and add coverage for cases where multiple zero components satisfy the criteria.

## Puzzle ac0a08a4 (Medium)
- **Observation**: Each non-zero pixel in the 3×3 source explodes into a solid square block in the output. The block size equals the count of non-zero pixels in the input, and the blocks are arranged in a grid that preserves the relative positions of the original cells.
- **Hypothesis**: Count the non-zero entries to get the scale `k`, allocate an output canvas `(3·k)×(3·k)`, and for every coloured input cell fill the corresponding `k×k` block in the output with that colour.
- **Next Steps**: Verify that the scaling handles repeated colours gracefully (colour per cell, not per unique value), and add safeguards for the degenerate case where the input is all zero (should return an empty canvas).

## Puzzle ae4f1146 (Medium)
- **Observation**: The 9×9 carpets collapse to 3×3 signatures by analysing each 3×3 macro-block. Blocks dominated by `8` stay `8`, while those driven by the sparse `1` strokes (or mostly blank zeros) become `1`, yielding a compact legend of where the fine detail lives.
- **Hypothesis**: Partition the grid into nine 3×3 blocks, tally non-zero counts per block, and emit `1` when the block has more `1` than `8` (or no `8`s at all); otherwise emit `8`. Zeros only sway the decision when both colours are absent, in which case fall back to `1` as seen in training.
- **Next Steps**: Script the block counter to validate the tie-breaking on every training/test pair and adjust the zero handling if any counterexample appears.

## Puzzle af902bf9 (Medium)
- **Observation**: Pairs of `4`s act as rectangle corners. The solution fills the axis-aligned rectangle framed by each quartet of `4`s with a solid block of `2`s while leaving the `4` frame untouched.
- **Hypothesis**: Detect connected sets of four `4`s that occupy opposite corners of a rectangle, then flood the interior (exclusive of the border) with `2`. Multiple rectangles coexist without overlap in training.
- **Next Steps**: Catalogue all rectangles in the examples, generalise the corner matcher for larger canvases, and guard against accidental pairing of diagonally separated `4`s from different rectangles.

## Puzzle b190f7f5 (Medium)
- **Observation**: The small mosaics upscale by factor three, but each coloured pixel expands into a 3×3 plus glyph (centre and four arms) rather than a solid block. Zeros expand to blank 3×3 tiles, so the glyphs float in the larger canvas without merging.
- **Hypothesis**: Perform a Kronecker-style expansion where each input cell maps to a 3×3 stencil chosen solely by its colour (cross for non-zero, blank for zero). Place those stencils on a 3× grid that preserves the original layout.
- **Next Steps**: Derive the per-colour stencil dictionary from training, confirm overlapping glyphs never contradict, and add tests for wider inputs where glyphs might touch diagonally.

## Puzzle b230c067 (Medium)
- **Observation**: Each connected island of `8`s is recoloured either `1` or `2`, preserving shape. Chunkier blobs (near-square footprints) map to `1`, while skinnier corridor-like islands become `2`.
- **Hypothesis**: Label `8` components, compute simple shape features (e.g., aspect ratio or width/height thresholds), and repaint each component with `1` or `2` depending on that feature.
- **Next Steps**: Measure the feature thresholds across training, verify the rule predicts the provided outputs, and ensure overlapping or touching components remain separable.

## Puzzle b2862040 (Medium)
- **Observation**: Background `9`s host filigrees of `1`s. The outputs thicken each `1` stroke by recolouring its interior pixels (those with multiple neighbours) to `8`, leaving the filament endpoints at `1` so the silhouettes stay readable.
- **Hypothesis**: For each connected `1` component, classify pixels by degree within the component; rewrite degree≥2 pixels to `8` and keep degree≤1 pixels as `1`.
- **Next Steps**: Implement the degree-based recolourer, check it against all training scenes, and confirm it behaves sensibly on thin single-pixel chains.

## Puzzle d4469b4b (Medium)
- **Observation**: The busy 5×5 inputs collapse to one of three 3×3 icons drawn in colour `5`: a top-heavy `T`, a centred plus, or a right-hand `L`, depending solely on which colour dominates the input (`2`, `1`, or `3`).
- **Hypothesis**: Detect the majority non-zero colour and return the matching template from a small lookup table.
- **Next Steps**: Verify no other colours occur in the dataset; if a new one appears, extend the dictionary with its template before falling back to a default.

## Puzzle d4f3cd78 (Medium)
- **Observation**: Hollow `5` frames get flood-filled with `8`, and an `8` spine drops through the opening to the canvas border, producing a filled interior plus a dangling column of `8`s beneath.
- **Hypothesis**: Identify the enclosed zero region bounded by `5`s, fill it with `8`, then extend the central column of `8` downward (and upward when present) until the grid edge.
- **Next Steps**: Generalise the spine position for asymmetric frames and confirm multiple openings, if ever present, are treated independently.

## Puzzle d687bc17 (Medium)
- **Observation**: The ornamental border stays put, but every interior marker slides to the frame: `2`s pile up along the left edge, `3`s migrate to the right edge, a single `4` copies the top beacon down the column, and the lone `8` relocates just above the bottom band. The interior is otherwise cleared.
- **Hypothesis**: For each interior colour, project its cells straight to the designated border column/row, drop them there, and erase the original locations.
- **Next Steps**: Confirm that only `{2,3,4,8}` ever need relocation and decide how to treat unexpected colours (either ignore or extend the mapping).

## Puzzle d6ad076f (Medium)
- **Observation**: Two solid colour slabs sit apart with a gap of zeros; the output drops a rectangular plug of `8`s exactly in the overlap of their horizontal/vertical spans, effectively sealing the space between the opposing faces.
- **Hypothesis**: Detect large rectangular components, compute the axis-aligned overlap of every pair separated by zeros, and fill that overlap in the empty rows/columns with `8` while leaving the source shapes untouched.
- **Next Steps**: Clarify how to pick the component pairs when more than two slabs appear and verify behaviour when the overlap degenerates to a single row or column.

## Puzzle d89b689b (Medium)
- **Observation**: A central 2×2 block of `8`s is surrounded by four distant colour beacons. The solution replaces the `8` block with those beacon colours arranged in a 2×2 matrix ordered by their compass direction (NW, NE, SW, SE) relative to the centre.
- **Hypothesis**: Locate the nearest non-zero cell in each quadrant around the `8` hub and write its colour into the corresponding slot of the 2×2 output block, defaulting to zero if a quadrant lacks a beacon.
- **Next Steps**: Add guards for cases with multiple candidates in a quadrant (choose the closest) and ensure we do not disturb any non-zero cells outside the central window.

## Puzzle d90796e8 (Medium)
- **Observation**: Whenever a `3` sits orthogonally adjacent to a `2`, the pair is resolved into an `8` (at the former `3` position) and a `0` (where the `2` lived). Other numbers (`5`, isolated `2`s/`3`s`) stay intact.
- **Hypothesis**: Scan for `3`–`2` neighbours, prioritise the `3` cell, repaint it `8`, and clear the matching `2`, skipping any pair that has already been consumed by a previous rewrite.
- **Next Steps**: Decide how to handle chains like `3-2-3` (process both sides or leave the middle `2` for a second pass) and ensure the routine is order-independent.

## Puzzle dae9d2b5 (Medium)
- **Observation**: Mini boards of `4`s and `3`s shrink to 3×3 signatures that sketch a Manhattan path of `6`s connecting the centroids of the `4` region (upper-left) and the `3` region (lower-right), with zeros elsewhere.
- **Hypothesis**: Compute the bounding boxes of the two colours, map their centres onto a 3×3 lattice, and draw the shortest axis-aligned route between them, marking each visited cell with `6`.
- **Next Steps**: Confirm the 3×3 lattice indexing matches all training outputs and extend the path drawer to handle cases where the boxes overlap (which should yield a solid block of `6`s).

## Puzzle db3e9e38 (Medium)
- **Observation**: A lone vertical column of `7`s is dressed with alternating `8`s that cascade diagonally to the left, creating a symmetric zig-zag flourish while the original column remains untouched.
- **Hypothesis**: Starting at the topmost `7`, march downward; for each row, paint `8`s along a diagonal fan whose length depends on the distance from the top, alternating between adding and skipping offsets to replicate the observed staircase.
- **Next Steps**: Formalise the diagonal pattern (number of `8`s per row) so it generalises to taller columns and verify behaviour when the `7` column is not centred.

## Puzzle ddf7fa4f (Medium)
- **Observation**: Large carpets of `5`s sit beneath sparse “header” digits (e.g., `2`, `6`, `7`, `8`, `3`). In the outputs, each vertical run of `5`s is recoloured to match the nearest non-`5` in its column, effectively flooding the column with the header colour.
- **Hypothesis**: For every column, scan upward (and, if needed, downward) to find the first non-zero that is not `5`, and repaint all `5`s in that column with that colour while keeping other cells untouched.
- **Next Steps**: Confirm the search direction on every training grid, especially where headers appear below a `5` band, and ensure columns without a header remain zero.

## Puzzle de1cd16c (Medium)
- **Observation**: The canvases are stacked horizontal bands of solid colour with a few stray anomalies embedded inside one band. The answer collapses to a single cell whose colour matches the band hosting the greatest number of anomalous pixels.
- **Hypothesis**: Segment the grid into maximal horizontal runs of constant colour, count off-colour cells inside each run, and output the base colour of the run with the highest anomaly tally (breaking ties in favour of the lower band as seen in training).
- **Next Steps**: Implement the anomaly counter to verify the tallies really are unique and confirm the tie-break rule is never actually exercised.

## Puzzle e179c5f4 (Medium)
- **Observation**: A single `1` on the bottom row animates into a bouncing light: the output grid is packed with `8`s except for one `1` per row whose column steps one cell left or right each row and reflects when it hits an edge.
- **Hypothesis**: Starting from the original `1` position, iterate row by row upward, advancing the column index by a direction flag that flips whenever the index would leave the board, and place a `1` at each position while filling the rest with `8`.
- **Next Steps**: Generalise the bounce logic to arbitrary widths and verify longer grids preserve the perfect sawtooth seen in training.

## Puzzle e21d9049 (Medium)
- **Observation**: A tiny cluster of colours (e.g., `8`, `3`, `2`, `4`, `1`) lives near a central column. The solution stretches that cluster into a cross: the central column cycles through the observed colours vertically, and the central row tiles the same sequence horizontally, leaving the rest zero.
- **Hypothesis**: Extract the ordered list of colours encountered in the seed column, use it to fill the entire column, and tile the same sequence across the row containing the seeds (wrapping as needed).
- **Next Steps**: Record the exact colour order per puzzle before coding to ensure the wrap-around matches each training sample, and confirm the test board just repeats the same cycle across its wider span.

## Puzzle e40b9e2f (Medium)
- **Observation**: Each training pair takes a lopsided cross built from two colours and returns the same footprint but with perfect horizontal and vertical symmetry. Right-hand arms and lower spokes are cloned to the missing quadrants so the component becomes a four-way mirror image around the unique centre cell.
- **Hypothesis**: Locate the centre of the plus (the only cell with both row- and column-neighbours). Reflect every non-zero pixel across that centre’s row and column, superimposing the reflections on the grid. Colours are preserved during the reflections.
- **Next Steps**: Work out how to detect the pivot row/column robustly (odd vs even spans) and ensure that repeated reflections do not double-count or overwrite existing pixels.

## Puzzle e48d4e1a (Medium)
- **Observation**: The inputs all contain a cross of colour `c` plus a short stack of `5`s sitting on the far-right border. The output is identical to the input except that the cross shifts diagonally down-left, and the amount of the shift equals the number of sentinel `5`s.
- **Hypothesis**: Count how many rows contain a `5` in the rightmost column; translate every `c` cell by `(+count, −count)`, dropping any pixels that would move off-grid. All other colours remain untouched.
- **Next Steps**: Confirm the sentinel column is always unique, guard against collisions when the shift would overlap existing `c` pixels, and check behaviour when the translation would leave the grid.

## Puzzle e509e548 (Medium)
- **Observation**: The source grids are pure `3`s on black, split into multiple disconnected motifs (vertical bars, horizontal rails, compact blocks). Outputs recolour each connected component with one of `{1,2,6}` while keeping geometry unchanged—vertical rods become `6`, horizontal slabs near the top map to `1`, and lower/squarer masses take `2`.
- **Hypothesis**: Label every connected component of `3`. Classify each by orientation (height vs width) and relative position, then replace the component with its assigned colour (`vertical→6`, upper horizontal→1, everything else→2`).
- **Next Steps**: Harden the classifier so ambiguous cases (perfect squares or mixed orientations) still map consistently, and verify none of the components overlap after recolouring.

## Puzzle e8593010 (Medium)
- **Observation**: Background `5`s dominate, but scattered zeros get recoloured in the outputs: zeros bordering the western edge of a gap turn into `1`, those bordering the east become `2`, and cells touching both sides become `3`. The rest of the `5` lattice stays intact.
- **Hypothesis**: For each zero, inspect its row/column neighbours. Paint it `1` if there is a `5` to its west but not east, `2` if there is a `5` to its east but not west, and `3` if both directions are blocked by `5`s (i.e., the zero is in a fully enclosed hole).
- **Next Steps**: Confirm diagonals are irrelevant, ensure edge zeros (lacking neighbours on one side) are handled consistently, and guard against overwriting the `5` frame.

## Puzzle e8dc4411 (Medium)
- **Observation**: The inputs place a single colour inside a sea of `8`s and sprinkle a few zeros along diagonals. Outputs propagate the inner colour along both diagonals, producing a staircase of alternating coloured cells that extends until it hits the border.
- **Hypothesis**: Start from each non-zero seed and march south-east and south-west, colouring zeros with the seed’s hue until blocked by non-zero cells or edges. Leave existing non-zero values untouched.
- **Next Steps**: Validate the march in both diagonal directions, clarify whether multiple seeds interact, and ensure propagation stops cleanly at the canvas boundary.

## Puzzle e98196ab (Medium)
- **Observation**: A solid row of `5`s splits each grid into upper and lower slabs. The outputs keep only five rows where each row is the overlay of a pair equidistant from that `5` row—effectively folding the grid in half and OR-ing the colours.
- **Hypothesis**: Remove the separator row and pair row `i` above with row `mirrored_i` below, superimposing their non-zero cells. The resulting composite rows become the output.
- **Next Steps**: Verify the folding works for both even and odd counts above the divider, and ensure colour conflicts resolve by simple overwrite since palettes do not overlap in the samples.

## Puzzle ea32f347 (Medium)
- **Observation**: The only non-zero colour is `5`, appearing in vertical runs. Outputs recolour those runs into a fixed palette by position: the leftmost `5` column becomes `1`, the next distinct run becomes `4`, and the third maps to `2`, with zeros left untouched.
- **Hypothesis**: Scan columns left-to-right, assign colours `{1,4,2}` cyclically to each connected `5` column run, and paint the entire run uniformly with that assigned colour.
- **Next Steps**: Confirm there are never more than three distinct `5` runs, and decide how to treat cases where runs touch diagonally (likely keep the run ordering by minimum column index).

## Puzzle ea786f4a (Medium)
- **Observation**: Dense monochrome blocks contain a single `0` seed. The outputs carve orthogonal and diagonal streaks of `0` radiating from that seed, leaving the original colour elsewhere so the hole becomes a symmetric star.
- **Hypothesis**: Starting from the `0`, flood equal-length spokes (N/E/S/W and diagonals) until reaching the boundary, always overwriting with `0` while keeping the base colour on untouched cells.
- **Next Steps**: Measure spoke lengths per example to see whether they depend on the seed’s offset from the border, and ensure multiple seeds never appear.

## Puzzle ec883f72 (Medium)
- **Observation**: After copying the input canvas, the outputs add a diagonal “tail” of the featured colour into the previously blank lower-right quadrant. The diagonal length mirrors the height of the original motif, effectively extending the shape toward the bottom-right corner.
- **Hypothesis**: Find the bounding box of the non-zero region and project its dominant colour along the main diagonal from the box’s south-east corner until the grid edge, filling those cells while keeping the original content.
- **Next Steps**: Verify whether each puzzle uses a single dominant colour per extension, and check for variants where multiple colours should spawn independent tails.

## Puzzle ecdecbb3 (Medium)
- **Observation**: A horizontal rail of `8`s with a few `2` markers blossoms into a chunky glyph: the rail thickens into a 3-row plaque of `8`s while each `2` sprouts into a short column reaching toward that plaque.
- **Hypothesis**: Expand the `8` run into a 3×(width) block with an `8` ring and place `2`s at the positions indicated by the seeds, extending them vertically to meet the ring. Remaining rows stay zero.
- **Next Steps**: Confirm seed heights always dictate the same column positions, and ensure multiple rails (if ever present) can be processed independently.

## Puzzle ed36ccf7 (Medium)
- **Observation**: Every 3×3 input contains an L-shaped cluster of a single colour plus trailing zeros. The output reorients that L so the long segment hugs the grid’s right edge while maintaining colour counts.
- **Hypothesis**: Detect the maximal connected component, identify whether it is horizontally or vertically biased, and rotate/reflect it so that its longer leg aligns with the east side; then rewrite the grid with zeros filling the remaining corner.
- **Next Steps**: Formalise the orientation test (e.g., compare width vs height of the component) and add safeguards so reflections do not swap colours when the shape is already flush with the edge.

## Puzzle f2829549 (Medium)
- **Observation**: Every row has the same structure—`7`s on the left, a single column of `1`s, then `5`s (or zeros) on the right. The 4×7 grids collapse to 4×3 outputs of `3`s/`0`s that appear to summarise, per row, which of the three horizontal zones (left of the `1`, the column containing the `1`, right of the `1`) contain live colour versus trailing zeros at their far edge.
- **Hypothesis**: For each row, inspect the three zones separated by the `1` column; mark a `3` in the compressed output when the zone contains the target colour but its outermost cell is zero (indicating the colour retracts before the boundary), otherwise leave `0`. This matches the observed toggling of the middle/right bins when the `5` run reaches the edge.
- **Next Steps**: Verify the “trailing zero” interpretation across all training rows, especially the cases where the rightmost `5` is missing, and consider whether an explicit left/right flag table (presence vs edge-bound) would be more robust.

## Puzzle f76d97a5 (Medium)
- **Observation**: The only interesting colour in each training grid is `5`; it forms the foreground motif (plus, diagonal, or bent streak). The solution keeps the exact footprint of those `5`s but repaints them with the companion colour (`4`, `6`, or `9`) and clears the original carrier colour.
- **Hypothesis**: Locate all cells whose value is `5`, replace them with “the other” non-zero colour present in the grid, and zero everything else. Because every sample uses exactly two colours, the replacement colour is unambiguous.
- **Next Steps**: Confirm there are never more than two distinct colours in unseen cases, and add a guard that skips the transform if the grid lacks `5`s (otherwise we would accidentally wipe the board).

## Puzzle f8a8fe49 (Medium)
- **Observation**: Each scene is a nested pair of rectangles: a wide belt of `2`s framing a smaller block of `5`s. The target slides the `5` block to the nearest border (top row or left column depending on the sample) while keeping the `2` frame intact, effectively “peeling” the core patch off its cavity and parking it against the boundary.
- **Hypothesis**: Detect the `5` component’s bounding box, blank it inside the frame, then translate that box to the first available empty strip adjacent to the frame (favouring north, then west). Leave the `2` rectangle untouched and restore zeros elsewhere.
- **Next Steps**: Work out a deterministic tie-break for choosing between top vs left placement (the training hints at preferring the smaller translation distance), and verify that the block move never collides with existing `2`s.

## Puzzle 1fad071e (Medium)
- **Observation**: Training boards always contain five candidate anchor slots where 2×2 monochrome blocks of colors `1` or `2` can appear. The 1×5 output vector mirrors those slots in reading order, with a `1` marking every slot that hosted a complete block in the input.
- **Hypothesis**: Scan the grid for homogeneous 2×2 blocks, bucket them into the five fixed column bands observed in training, and emit a binary mask ordered left→right. When multiple blocks land in the same band the mask still records a single `1`.
- **Next Steps**: Write a helper that enumerates 2×2 components, verify the slot→index mapping against all known samples, then confirm the test case only activates the three bands reflected by its output signature.

## Puzzle 995c5fa3 (Medium)
- **Observation**: Four-wide input strips of `5`s contain characteristic zero gaps that act like bar-code signatures per row. The 3×3 output encodes those row types by mapping each distinct gap pattern to a specific solid colour and stacking the colours in the same top→bottom order.
- **Hypothesis**: Derive a dictionary from training rows: normalise each input row by the indices of its zero bands, and assign the learned palette `{2,3,4,8}` to those templates. For a new board, classify each row with that template and emit the corresponding colour across a full output row.
- **Next Steps**: Serialize the learned mapping, add assertions that unseen templates trigger a fallback, and verify the test case’s three unique row patterns map to `[4,3,8]` as shown by the target grid.

## Puzzle b527c5c6 (Medium)
- **Observation**: Rows that already contain colour `3` are horizontally back-filled so the leftmost non-zero value extends all the way to column 0, turning the scatter of pixels into solid left-aligned bars. Any column that holds `3` or `2` in the source is also pulled straight down to the canvas floor, preserving the colour seen at the top of that column, so the original blob becomes a stepped stack of uniform stripes.
- **Hypothesis**: Implement two deterministic passes: (1) for every row, locate the first non-zero entry and flood every cell to its left with that same colour; (2) for every column touched by a non-zero, replicate that column’s highest colour downward until the bottom edge. This reproduces both the horizontal padding and the vertical tails in the training grids.
- **Next Steps**: Double-check that the order of operations (left-fill before vertical fill) matches the training outputs and add guards so blank rows/columns stay blank even after the passes.

## Puzzle b548a754 (Medium)
- **Observation**: Each example contains a compact framed glyph (border colour surrounding an inner fill) that is simply extruded vertically; the outer ring colour repeats at the new top and bottom rows, while the interior rows are copied verbatim to create a tall column with identical façades.
- **Hypothesis**: Crop the tight bounding box around the non-zero patch, then tile its rows downward and upward until the target height is reached, keeping the original row order. Because the training shapes are perfect rectangles, a trivial repeat of the captured motif recreates the answers.
- **Next Steps**: Verify that no future puzzle introduces gaps inside the bounding box and parameterise the repeater so it gracefully handles taller canvases than those seen in training.

## Puzzle b60334d2 (Medium)
- **Observation**: Isolated `5` pixels act as anchors for a fixed 3×3 ornament: the four orthogonal neighbours become `1`, the four diagonals turn into `5`, and the original centre is cleared back to `0`. Overlapping anchors simply superimpose copies of the same stencil.
- **Hypothesis**: Iterate over every `5` in the input, stamping the pattern
	```
	5 1 5
	1 0 1
	5 1 5
	```
	with the centre aligned to the anchor and clipping at borders, letting later stamps overwrite zeros but leaving existing coloured cells intact when they agree with the template.
- **Next Steps**: Confirm overlapping stencils never demand conflicting colours and add a safeguard so anchors on the border are clipped rather than causing index errors.

## Puzzle b6afb2da (Medium)
- **Observation**: Solid rectangles of colour `5` are replaced by a decorative badge: corners switch to `1`, the perimeter becomes `4`, and the interior turns into uniform `2`. Disjoint `5` blocks transform independently, yielding multiple framed patches in a single scene.
- **Hypothesis**: Detect each connected component of `5`s, compute its bounding box, and repaint that box with the template (corners→`1`, edges→`4`, interior→`2`). Background zeros outside the component remain untouched, so a simple component-wise redraw matches the targets.
- **Next Steps**: Ensure the component labelling handles touching rectangles separated by a one-cell gap and add a fast path for degenerate cases such as 1×k strips (where the concept of “interior” collapses).

## Puzzle b8cdaf2b (Medium)
- **Observation**: A single decorated baseline (the last row) determines the entire drawing: the outermost colour becomes diagonals rising toward the top corners, while the inner colour(s) form a shrinking diamond nested above the base. Each example expands the bottom motif into a symmetric hourglass without altering the baseline itself.
- **Hypothesis**: Extract the indices of the non-zero cells in the final row, then march upward placing the same colours on diagonals that step one column inward per row (mirroring left/right). Continue until the diagonals converge or the colour set is exhausted; leave any remaining cells zero.
- **Next Steps**: Guard against cases where the base motif is wider than twice the grid height (diagonals would cross) and add unit tests to ensure overlapping diagonals favour the inner colour.

## Puzzle b91ae062 (Medium)
- **Observation**: The 3×3 inputs specify three colour bands (top row, middle row, bottom row). Outputs upscale each band into a block of doubled width and height: the top row colour becomes a 2×(2·n) rectangle, the middle row gets the central band (optionally wider), and the bottom row colour fills the final block. Within each band the colour that occupied the input corners expands into full 2×2 tiles, producing the striped carpets shown in training.
- **Hypothesis**: Treat the input as a 3×3 macro-pixel image; expand each source cell into a 2×2 tile, but merge adjacent tiles of the same row so they form the longer rectangles observed (e.g., duplicate the first row twice, append the second row twice, etc.). This deterministic Kronecker-style upscale captures both the band ordering and the exact run lengths.
- **Next Steps**: Reproduce all training outputs with the tile-upscale logic and check how to handle cases where the input uses zeros inside a band (should upscale to blank strips rather than coloured ones).

## Puzzle 045e512c (Hard)
- **Observation**: Multiple motifs (3×3 blobs, cross shapes, small markers) are expanded into decorative mosaics that repeat each motif along both axes using secondary colors. The transformation depends on each motif’s color pairing (e.g., 8→(8,3), 2→(2,0), 4→(4,1)).
- **Hypothesis**: Segment the input into connected components, derive a template per color from training, then stamp that template around the component’s bounding box. There appears to be color-specific tiling rules (horizontal vs vertical striping) that need cataloging.
- **Next Steps**: Catalogue every distinct input component and the corresponding output pattern to reverse engineer the tiling schema. Consider automating a component-to-pattern dictionary similar to 007bbfb7 but with larger kernels.

## Puzzle 06df4c85 (Hard)
- **Observation**: Large striped wallpapers repeat basic 4×? motifs; small color highlights (2,1,3,9,8,4) expand into longer stripes triggered by matching markers inside the pattern. Essentially each marker column toggles extra bands of that color across the wallpaper.
- **Hypothesis**: Treat the wallpaper as repeating 3-column tiles containing a base column plus optional accent columns duplicated whenever the input segment contains the accent. Extract motif definitions and repeat them horizontally when a marker is present.
- **Next Steps**: Build a motif library keyed by (base color, accent color) and have the generation step iterate columns while injecting accent stripes whenever the input row pattern matches.

## Puzzle 0b148d64 (Hard)
- **Observation**: Inputs contain two stacked regions: a high-entropy top half that collapses into a pure `2` field, and a lower cluster that collapses into `3`s. Essentially it abstracts 3×3 patches into class labels (`2` vs `3`) producing smaller classification grids.
- **Hypothesis**: For each 3×3 patch (aligned blocks), detect whether it originated from an `8`-dominant or `2`-dominant texture and output `2` or `3` accordingly. Treat empty patches as zeros.
- **Next Steps**: Implement 3×3 pooling with heuristics (e.g., count of `8`s vs `2`s) to assign the class label, and confirm strides/offsets match exactly.

## Puzzle 0e206a2e (Hard)
- **Observation**: Sparse markers of colors `{1,2,3,4,5,8}` are scattered far apart in the inputs, yet every output condenses them into a tight glyph: a horizontal bar whose ends keep the endpoint colors, a short vertical stem of `8`s capped by the high-valued color, and small satellites for any additional hues. The relative order of colors along the condensed glyph matches their ordering along the input’s primary diagonal.
- **Hypothesis**: Collect the non-zero coordinates, sort them by (row+col) to recover the diagonal order, and stamp them onto a learned template that fixes anchor slots (left end, right end, top cap, etc.). Fill any interior slots with `8` to maintain continuity.
- **Next Steps**: Extract the exact template from the training pairs (row/column offsets for each ordinal position), confirm that the ordering heuristic is stable, and double-check that no extra colors appear in the test grid.

## Puzzle 137eaa0f (Hard)
- **Observation**: Each grid hides exactly three distinct color clusters scattered around. The solution reduces the scene to a 3×3 summary where each row corresponds to one cluster (sorted top-to-bottom) and carries either a duplicated pair or a singleton depending on how many pixels the cluster contained.
- **Hypothesis**: Locate connected components, order them by centroid row, and project each onto a canonical row template that preserves the multiset of colors while compressing the layout to adjacent cells.
- **Next Steps**: Write a component extractor, capture per-cluster templates from the training data, and verify the test case still produces three clusters so the mapping stays well-defined.

## Puzzle 1f85a75f (Hard)
- **Observation**: Enormous 30×30 fields collapse to tiny signatures (5×3 or 4×4) that simply encode whether each coarse quadrant contains certain colors—`3` for the first family of puzzles, `4` for the second. It’s effectively a presence map across big tiles.
- **Hypothesis**: Partition the input into a uniform grid (likely 6×10 chunks), flag a tile if it hosts any member of the target color set, and write that flag color into the corresponding cell of the compressed output.
- **Next Steps**: Reverse-engineer the exact tiling (tile width/height) so the training examples reproduce precisely, and verify that color families are disjoint (no tiles with both colors).

## Puzzle 228f6490 (Hard)
- **Observation**: Large carpets of `5` act as static backdrops, while the smaller non-`5` islands (`8`, `6`, `3`, `9`, `2`) swap places between quadrants from input to output. The training pairs all implement the same rotation: the bottom cluster moves upward, the top cluster drops to the floor, and lateral companions slide horizontally to the cavities vacated by their partners, without altering their shapes.
- **Hypothesis**: Extract all connected components whose color ≠ `5`, order them by their centroid angles around the grid center, and remap them in a cyclic rotation (e.g., advance each component one slot clockwise) while leaving the `5` background untouched. Repaint each component at its new anchor by translating its relative offsets.
- **Next Steps**: Catalog the centroid ordering explicitly, check whether the rotation is always a single-step cycle, and add overlap handling in case multiple components target the same slot in unseen puzzles.

## Puzzle 264363fd (Hard)
- **Observation**: A large `8` wallpaper contains a rectangular meadow of `1`s punctuated by a few `2`/`3` markers. The outputs redraw that meadow with a fixed ornamental cross: `2`s carve a vertical stripe through the center, `3`s flank the cross, and the surrounding `1`s remain elsewhere. The pattern repeats identically in the upper and lower halves.
- **Hypothesis**: Treat the non-`8` region as a single tile, learn the 2-column motif (`3,2,3`) around the central axis from training, and stamp that motif anywhere the input shows `1`s. Preserve the bounding `8`s and any existing `2` markers at the perimeter.
- **Next Steps**: Verify no alternative tile shapes appear in hidden cases, and confirm that the learned motif mirrors correctly if the meadow is transposed or offset.

## Puzzle 272f95fa (Hard)
- **Observation**: Two vertical rails of `8` divide the canvas into left, middle, and right corridors. Between the horizontal `8` stripes, each corridor is recolored uniformly—top bands become `2`, middle bands `6`, and bottom bands `1` on the interior, while the side gutters receive matching shades (`0/4/0` etc.). The result is a three-zone palette repeated every block of rows.
- **Hypothesis**: Segment the grid into row bands delimited by all-`8` rows, then fill the cells between the rails with a band-specific color triple learned from training (`left`, `mid`, `right`). Leave the `8` rails untouched.
- **Next Steps**: Confirm the band ordering always follows the same palette cycle, and guard against bands that are only a single row tall (copy colors without leaking into neighboring rails).

## Puzzle 28bf18c6 (Hard)
- **Observation**: Sparse clusters collapse to a canonical 3×6 stencil whose non-zero layout depends only on the cluster’s shape; the actual color from the input fills that stencil. Zeros elsewhere remain blank.
- **Hypothesis**: Extract the minimal bounding box of non-zero cells, match it (up to translation) against the few seen cluster shapes, and emit the corresponding template with the cluster’s color.
- **Next Steps**: Catalog every template from training, confirm no rotations occur, and add a fallback in case a novel cluster shows up (e.g., default to copying the bounding box itself).

## Puzzle 2bee17df (Hard)
- **Observation**: Large chambers of zeros sit between rigid `8`/`2` walls; the outputs repaint the fully enclosed floor area with `3` while leaving the small vestibules that touch the opening near the top as bare `0`. Door jambs next to the `2` rails get a single column of `3` to mark the threshold.
- **Hypothesis**: Identify all zero cells inside the bounding frame, keep the subset that is *not* connected to the outside via a zero path, and recolor that interior pocket to `3` (including the doorway column). Preserve the walls and any zero corridor still connected to the entrance.
- **Next Steps**: Implement a flood-fill from the boundary to classify reachable zeros, convert the complement to `3`, and double-check clipping around the doorway so we do not seal it accidentally.

## Puzzle 2dd70a9a (Hard)
- **Observation**: Sparse mazes of `0`/`8` already contain a few `3` markers and pairs of `2`s. The outputs extend `3`s in long horizontal and vertical runs so that each `2` becomes connected to the existing `3` network, effectively carving a corridor through the void.
- **Hypothesis**: From every seed of `3`, grow straight segments through zero cells until hitting another non-zero, making sure to pass through the columns containing the `2`s so they become linked.
- **Next Steps**: Decode the exact growth limits (stop before `8`, leave `2`s intact), and confirm whether both horizontal and vertical sweeps are required or if the training data implies an ordered pass.

## Puzzle 3428a4f5 (Hard)
- **Observation**: The rows above the `4` separator encode a 6×5 binary glyph in `2`s. The outputs map that glyph to a stylized 3/0 version—each unique input mask has a fixed output mask of the same size with `2→3` plus some structural adjustments.
- **Hypothesis**: Treat the top slice as a binary pattern, normalize it, and look up the corresponding 3/0 stencil from a dictionary learned over the training set.
- **Next Steps**: Record the binary→stencil mappings, and consider lightweight invariants (rotation, reflection) in case an unseen glyph appears in future samples.

## Puzzle 3631a71a (Hard)
- **Observation**: The canvases are 30×30 fabrics partitioned into nine large tiles by walls of `9`s. Wherever a tile was entirely `9`s, the output copies the closest non-`9` textile from the same row or column so the wallpaper pattern continues seamlessly across the void. Tiles that already contained patterning remain untouched.
- **Hypothesis**: Treat the grid as a 3×3 block matrix separated by `9` gutters; for each all-`9` block, clone the nearest non-empty neighbor (prefer row-wise, fall back to column-wise) and paste it in place.
- **Next Steps**: Formalize tile extraction (boundaries defined by solid `9` rows/cols), add a neighbor-selection rule for interior tiles (e.g., copy from the left then top), and confirm the copying is literal with no rotations.

## Puzzle 36d67576 (Hard)
- **Observation**: Each scene contains one detailed quadrant—a mix of `4` carpets, `3` struts, and occasional `1`/`2` markers—while the other quadrants are mostly blank. The solution mirrors the decorated quadrant across both axes, filling in the missing struts and adding the same `1` markers at the mirrored endpoints so the frame becomes symmetric.
- **Hypothesis**: Isolate the dense quadrant (top-left in training), reflect its pattern horizontally and vertically into the other quadrants while respecting the existing `4`/`3`/`2` layout, and inject the `1`s wherever the source quadrant had them.
- **Next Steps**: Implement quadrant detection via bounding boxes of `4`s, build horizontal/vertical reflections, and double-check overlaps so that mirrored data does not erase the original scaffold.

## Puzzle 39e1d7f9 (Hard)
- **Observation**: Huge tapestries are partitioned by solid `8` borders into a grid of macro-tiles. Each border-adjacent tile already contains a patterned fabric (with colors `3`, `6`, `4`, etc.), while interior tiles are entirely `8`. The output propagates each patterned tile across its row and column, replacing the interior `8` tiles with clones so the motif repeats through the whole stripe network.
- **Hypothesis**: Decompose the board into tiles via the `8` separators, record every non-empty tile, and copy it into any all-`8` tile aligned with it in the same row or column.
- **Next Steps**: Implement tile extraction, define precedence when both a row and column offer donors (e.g., prefer row-wise), and ensure clones preserve orientation (no rotations or flips).

## Puzzle ba97ae07 (Hard)
- **Observation**: A horizontal stripe of color `H` intersects a vertical stripe of color `V`. The output only flips the overlap cells so that one of the stripes becomes completely uniform through the crossing while the other is “cut”. Which stripe wins is consistent within each example (e.g., the thicker band keeps its color), but tie cases suggest we still need a deterministic tie-break rule.
- **Hypothesis**: Measure each stripe’s thickness (number of rows for the horizontal band, number of columns for the vertical). Let the thicker stripe repaint the intersection with its own color; when widths match, fall back to comparing stripe lengths or another invariant derived from the training data.
- **Next Steps**: Catalogue more statistics (lengths, proximity to borders) across all examples to lock down the tie-break so the solver can decide unambiguously which color should occupy the overlap.

## Puzzle bda2d7a6 (Hard)
- **Observation**: Every picture features concentric rectangles with three distinct roles: background `C`, border `A`, and interior fill `B`. The solution cyclically permutes these roles outward—`A` becomes the new exterior (matching `C`), `B` moves to the border, and `C` fills the innermost cavity—while leaving the geometry unchanged.
- **Hypothesis**: Isolate the minimal bounding box containing the non-background cells. Within that box, map colors via `A→C`, `B→A`, `C→B`, applying the swap only inside the box so exterior padding remains as-is. This reproduces the observed color rotation across all provided samples.
- **Next Steps**: Verify detection of the three layers when there are multiple nested cavities, and ensure the color remapping does not break if additional decorative colors appear between the standard layers.

## Puzzle ce602527 (Hard)
- **Observation**: Huge wallpapers feature large uniform backgrounds punctuated by repeating accent stripes. The answers are compact emblems whose cells record the dominant (majority) color of each macro-tile in that stripe lattice (e.g., 5×5 or 5×3 layouts mirroring the motif locations).
- **Hypothesis**: Detect the horizontal and vertical stripe periods (distance between repeated accent bands), partition the canvas into those macro tiles, and emit a downsampled grid using the mode color inside each tile.
- **Next Steps**: Work out stripe spacing programmatically—perhaps via autocorrelation—and verify each training example reproduces its emblem before trusting the method on the held-out puzzle.

## Puzzle d07ae81c (Hard)
- **Observation**: Large striped canvases of `2/3/6` gain ornate overlays of `1`, `4`, and `8`. The outputs preserve the base stripes but insert color-specific accents (e.g., crossbars of `4`, corner markers of `1`) at regular intervals tied to the underlying grid rhythm.
- **Hypothesis**: Treat the input as tiled stripes: identify the repeating period horizontally and vertically, then replace each tile with a learned motif drawn from the training data (spanning base color plus its decorative companion colors). The motif depends on the tile’s role (edge, interior, corner) within the repeat lattice.
- **Next Steps**: Catalogue the unique tile motifs by slicing the training boards, verify their placements via period detection, and ensure the same lookup reproduces the composite pattern on the test puzzle.

## Puzzle d13f3404 (Hard)
- **Observation**: The 3×3 seed expands into a 6×6 Toeplitz-like banded matrix: each superdiagonal repeats one input row while the subdiagonal below carries the previous row, forming a cascading staircase of the original colors.
- **Hypothesis**: Interpret the 3×3 tile as the first three anti-diagonals and iteratively shift them one column to the right and down to populate the 6×6 canvas. Equivalently, place the input in the top-left, then repeat rows/columns along succeeding diagonals.
- **Next Steps**: Formalize the diagonal-shift generator and confirm it handles zero rows (all-zero diagonals) without introducing stray colors.

## Puzzle d22278a0 (Hard)
- **Observation**: A handful of seed pixels (e.g., `1` at the west edge, `2` or `3` at the east, `8` in a corner) blossom into striped combs: their rows become alternating sequences of the seed color and zero, while columns beneath matching hues solidify into blocks of the same color.
- **Hypothesis**: For each non-zero seed, broadcast its color along its row using the repeating template `color,0` until blocked by another seed, and similarly flood its supporting column with solid color. Superimposing these runs yields the intricate checker/stripe outputs seen in training.
- **Next Steps**: Derive the precedence rules when multiple seeds share a row or column (the examples suggest leftmost or bottommost colors win) and regression-test on the dense test board to ensure overlaps reconcile correctly.

## Puzzle c0f76784 (Hard)
- **Observation**: Thick walls of color `5` enclose rectangular “rooms” whose interiors were zero in the input. The output carpets each room with a solid accent (`8`, `7`, or `6`) depending on the room’s footprint, while leaving the surrounding `5` hulls untouched. Narrow corridors inherit the same accent color as their parent room.
- **Hypothesis**: Flood-fill each zero region fully surrounded by `5`s, classify the room by its shape (square, plus-shaped, corridor), and recolor all cells in that region with the learned accent color for that class. Preserve the `5` boundary exactly as in the input.
- **Next Steps**: Catalogue the room-shape → accent mapping from every training sample so we generalise beyond the current sizes, and ensure partially open regions (touching the exterior) are skipped.

## Puzzle c3f564a4 (Hard)
- **Observation**: Inputs are partially-erased cyclic Latin strips—the rows already follow a fixed modular sequence but contain gaps of `0`. The outputs restore the full toroidal pattern so every row is a perfect rotation of the base cycle with no zeros.
- **Hypothesis**: Infer the minimal repeating sequence for the grid (read the first non-zero run in row 0), then regenerate each row by rotating that sequence to the proper phase, filling any zeros encountered. Apply the same logic column-wise only if necessary to reconcile conflicting hints.
- **Next Steps**: Add validation that the inferred cycle matches all non-zero evidence before writing, and fall back to a brute-force search over candidate periods if the first row is too sparse.

## Puzzle c8cbb738 (Hard)
- **Observation**: Huge monochrome fields contain sparse markers of a few distinct colors. The solution compresses the scene into a small symmetric stencil (3×3 or 5×5) that places each marker color at fixed template positions while the dominant background fills the remaining slots.
- **Hypothesis**: Detect the set of non-background colors and map them onto the learned template for that color set (e.g., `{2,4,1,8}` → 5×5 outer ring, `{8,3,1}` → 3×3 cross). Emit the template using the same colors, ignoring their absolute positions in the original grid.
- **Next Steps**: Build the color-set → stencil dictionary from all training cases and add a fallback (perhaps return the densest component) if a previously unseen combination appears.

## Puzzle 9d9215db (Hard)
- **Observation**: A handful of colored beacons sit on the axial rows/columns of an otherwise blank 19×19 canvas. The solution echoes each beacon along its axis at the observed even spacing, yielding alternating picket-fence stripes that stretch from one border to the other while the untouched rows/columns remain zero.
- **Hypothesis**: Detect the non-zero cells nearest the center on each cardinal axis, measure the step (always two cells in training), then march outward in both directions stamping the same color on every second cell of that row or column. Treat opposing beacons (e.g., west/east) independently so their stripes interleave without conflict.
- **Next Steps**: Verify the stride truly stays fixed at two, ensure mirrored partners always exist on both sides, and guard against future samples that might introduce diagonal beacons or missing counterparts.

## Puzzle 9ecd008a (Hard)
- **Observation**: Each huge wallpaper hides a hollow square of zeros surrounded by a colored ring. The 3×3 outputs capture that ring: the center reports the color immediately inside the gap, the four edges record the colors due north/east/south/west of the hole, and the corners log the diagonal neighbors.
- **Hypothesis**: Locate the maximal all-zero rectangle, probe the eight surrounding cells at Manhattan/Chebyshev distance one, and map them into a 3×3 legend (NW, N, NE on the top row, etc.). Emit that legend as the target grid.
- **Next Steps**: Double-check that the zero cavity is always rectangular and at least 1 cell thick, and verify no future sample exposes multiple disjoint cavities requiring a different selection rule.

## Puzzle 9edfc990 (Hard)
- **Observation**: Sparse cityscapes receive a flood-fill of `1`s that wraps every existing non-zero building, turning jagged clusters into blocks while leaving distant voids untouched. Some corridors intentionally remain `0`, indicating the fill respects the original zero “streets”.
- **Hypothesis**: Starting from each non-zero cell, iteratively color any orthogonally adjacent `0` with `1`, but stop the expansion when a cell would lie outside the original row/column span of that building (preserving long zero avenues). Repeat until no new `1`s appear.
- **Next Steps**: Formalize which zero cells are considered “outside the span” so we reproduce the held-out corridors, and confirm whether multiple iterations are required or if a single pass over the neighborhood suffices.

## Puzzle 9aec4887 (Hard)
- **Observation**: Each scene contains exactly five disjoint rectilinear components: a northern horizontal bar, a southern bar, western and eastern columns, and a central clump. The output collapses the wide spacing into a compact framed glyph where the top row uses the north bar’s color, the bottom row the south bar’s color, the left/right columns take the vertical bars’ colors, and the central cross retains the middle clump’s color while leaving corner cells as background `0`.
- **Hypothesis**: Label connected components, order them by centroid row/column to assign the north/south/east/west/center roles, then synthesize a minimal canvas with a zero border. Paint the frame rows/columns with their assigned colors and fill the interior with a fixed cross template rooted at the center color so the arms touch the corresponding frame segments. Derive the interior width/height from the observed spacing so thicker gaps expand to larger crosses (e.g., 3×3, 4×4, 5×5 in training).
- **Next Steps**: Formalize the size-selection rule from the training offsets, confirm the cross template covers all tested dimensions, and validate that the role assignment remains stable if multiple components share similar centroids.

## Puzzle 3e980e27 (Hard)
- **Observation**: Certain colors (e.g., `2`, `4`, `8`) appear twice: once as a fully decorated component with helper colors around it and once as a bare seed. Outputs clone the decorated neighborhood from the exemplar onto every other seed of the same color, aligning orientations exactly.
- **Hypothesis**: For each color, gather the relative offsets of surrounding non-zero pixels from the most detailed instance, then stamp that offset pattern around every occurrence of the color that lacks its entourage. Ignore positions already non-zero to avoid overwriting unrelated structure.
- **Next Steps**: Build a template extractor that picks the richest component per color, add collision checks when stamping near borders, and ensure multiple seeds of the same color all receive the same decoration.

## Puzzle 40853293 (Hard)
- **Observation**: Each color appears in symmetric pairs along a row or column. Outputs draw thick axis-aligned bars connecting the paired markers: duplicated colors in the same row become horizontal strips, those in the same column yield vertical columns, and shared intersections inherit the connector color (`2` or `6`).
- **Hypothesis**: For every color, find the min/max rows and columns it occupies. If the spread is primarily horizontal, fill that row interval inclusive; if vertical, fill the column. When both axes span, draw the rectangle’s perimeter while letting existing connector colors populate the shared column.
- **Next Steps**: Formalize the axis-selection rule (horizontal vs vertical), define overlay precedence so connectors (`2`, `6`) persist, and confirm the rectangles replicate the training mosaics without introducing extra colors.

## Puzzle 4290ef0e (Hard)
- **Observation**: Huge boards composed of rectangular color regions shrink to a canonical 11×11 or 7×7 emblem that preserves the ordering of those regions: the outer border color becomes the frame, intermediate bands map to the next ring, and interior glyphs land in the center with their relative orientation maintained.
- **Hypothesis**: Segment the input into concentric layers (outer frame, middle annulus, inner core). Record the dominant color per layer and paint a fixed-size emblem with those colors assigned to the corresponding ring or cross positions.
- **Next Steps**: Automate layer detection via distance-to-border, validate the color extraction when multiple layers share the same hue, and confirm the emblem size choice matches every training pair.

## Puzzle 4522001f (Hard)
- **Observation**: A 3×3 board with a central `2` and an L-shaped arm of `3`s becomes a 9×9 canvas made of two 4×4 turquoise squares arranged on a coarse 3×3 lattice of blocks; the activated block rows and columns line up with the rows/columns that contained `3`s in the source.
- **Hypothesis**: Detect which of the three input rows and which columns hold any `3`; sort those indices and pair them to place equally many 4×4 blocks of `3`s in the enlarged lattice while leaving all other blocks zero.
- **Next Steps**: Tabulate the exact index→block-offset mapping, clarify what happens when only one row (or column) is active, and confirm diagonally adjacent `3`s never demand extra blocks.

## Puzzle 469497ad (Hard)
- **Observation**: Each 5×5 scene contains a coloured blob and a boundary colour; the output doubles both dimensions, turning every original cell into a 2×2 tile while inserting diagonal ribbons of `2`s that trace the borders between interior, background, and perimeter colours.
- **Hypothesis**: Perform a 2× upscaling (each cell → 2×2 block) and, for any edge where a non-zero meets zero or the frame colour, overlay a diagonal of `2`s across the four corresponding upscaled cells to create the cross braces seen in the examples.
- **Next Steps**: Work out exactly which adjacency pairs spawn the `2` diagonals, confirm corners get both arms, and ensure purely uniform inputs remain unchanged aside from the scaling.

## Puzzle 47c1f68c (Hard)
- **Observation**: A slanted ramp of one colour edges up against a solid column of another; the answer distils that relationship into a smaller square ring of the column’s colour, mirrored so the ramp’s footprint appears in all four quadrants while the ramp colour disappears.
- **Hypothesis**: Measure the horizontal extent of the ramp for each row, reflect those spans about the centre, and redraw them using the column colour to form a symmetric outline that honours the ramp’s profile.
- **Next Steps**: Verify how to treat gaps in the ramp, handle cases where the ramp reaches the column, and ensure trailing zeros do not produce unintended stripes.

## Puzzle 48d8fb45 (Hard)
- **Observation**: A marked `5` sits near a cluster of another colour; the solution crops the minimal bounding box around that cluster and rescales it to a canonical 3×3 signature that keeps only the relative arrangement of the non-zero cells.
- **Hypothesis**: Locate the connected component of the non-`0`/`5` colour nearest the marker, crop its bounding box, normalise it to 3×3 (pad or shrink as needed), and copy the component’s shape into that miniature.
- **Next Steps**: Define the scaling rule when the bounding box isn’t 3×3 already, decide what happens if several colours appear, and verify the marker always lies adjacent to the chosen blob.

## Puzzle 4be741c5 (Hard)
- **Observation**: Huge mosaics collapse into slim signatures listing block colours in the dominant sweep direction—horizontal stripes yield a 1×N row, vertical stratification yields an N×1 column.
- **Hypothesis**: Determine whether colour changes occur primarily across rows or columns (e.g., by counting transitions) and then emit the sequence of distinct block colours in that direction.
- **Next Steps**: Formalise the transition heuristic for noisy borders, decide how to treat single-pixel anomalies, and verify the summary preserves the intended ordering when both directions vary.

## Puzzle 5117e062 (Hard)
- **Observation**: Multiple motifs surround a lone `8`; the answer extracts the colour owning that `8` (the block in which it sits) and emits a tight 3×3 emblem that matches the source block’s arrangement.
- **Hypothesis**: Locate the connected component containing the `8`, crop its minimal bounding box, normalise it to 3×3 by dropping empty rows/columns, and repaint everything with the component’s dominant colour.
- **Next Steps**: Clarify what happens if the component is larger than 3×3, document tie-breaking when `8` touches multiple colours, and ensure the scaling step preserves the cross/diamond structure seen in training.

## Puzzle 5168d44c (Hard)
- **Observation**: Blocks of `2`s align beneath columns of alternating `3`s; the output recentres the `2` bars so they straddle the same columns as the adjacent `3`s, effectively sliding the bricks into a symmetric cross while blanking the original offset cells.
- **Hypothesis**: For each row containing a contiguous `2` span, horizontally shift that span so its midpoint matches the midpoint of the nearest `3` in the same row or column, overwriting old positions with zeros.
- **Next Steps**: Determine the anchor column when multiple `3`s appear, ensure shifting never runs off-grid, and confirm rows that already align remain unchanged.

## Puzzle 539a4f51 (Hard)
- **Observation**: Each 5×5 scene inflates into a 10×10 grid where the cleaned source tile (zeros swapped to the northwest color) appears in the north-east, south-east, and north-west quadrants, while the south-west quadrant echoes the first-column palette as solid horizontal bands and the remaining gaps are backfilled with that same dominant hue.
- **Hypothesis**: Preprocess the input by replacing zeros with the top-left color, tile that 5×5 mask across a 2×2 lattice, then overwrite the south-west quadrant by copying the adjusted first column into rows to recreate the observed stripes before restoring the original non-zero values elsewhere.
- **Next Steps**: Verify that the first-column stripe really drives the south-west fill across all training cases, double-check that zero replacement happens prior to tiling, and confirm the routine always produces a 10×10 canvas.

## Puzzle 53b68214 (Hard)
- **Observation**: Polyominoes that already sketch a short monotonic path (vertical column, diagonal ramp, zig-zag) are extended straight downward in the output, repeating the final step pattern until the canvas fills out to ten rows.
- **Hypothesis**: Deduce the smallest vertical period from the existing strokes, then append translated copies of that motif row-by-row until the grid height reaches the fixed limit, keeping the existing rows untouched.
- **Next Steps**: Generalise the period detector so it handles both pure columns and mixed zig-zags, guard against drifting off the sides when the motif includes horizontal offsets, and ensure we stop exactly at the grid boundary.

## Puzzle 543a7ed5 (Hard)
- **Observation**: Islands of `6` embedded in an `8` ocean get replaced by a decorative “circuit” where `3`s form a rectangular conduit around the footprint and `4`s appear at interior junctions, with straight corridors and corners receiving different treatments but respecting the original bounding boxes.
- **Hypothesis**: Segment each `6` cluster, classify its local topology (straight run, elbow, junction), and draw a canned overlay that paints a `3` frame around the box, reinstates `6` along the spine, and drops `4`s wherever opposing corridors intersect.
- **Next Steps**: Catalogue the handful of cluster archetypes present in the training set, confirm the template placement for rotated versions, and ensure stray `5`s or other noise inside a cluster do not derail the topology detector.

## Puzzle 56dc2b01 (Hard)
- **Observation**: Inputs mix a horizontal bar of `2`s with one or more `3` polyominoes; outputs recast them into a standard layout where the `2` stripe, the `3` shape, and a new `8` header sit in prescribed rows/columns without altering their intrinsic footprints.
- **Hypothesis**: Separate the connected components per colour, then paste them into a canonical scaffold—first insert an `8` strip, align the `3` component beneath it, and relocate the `2` bar to the remaining slot—preserving their orientations while translating to the template coordinates.
- **Next Steps**: Nail down the exact target coordinates for each component, check whether multiple `3` pieces ever appear, and ensure translations do not clip the shapes at the canvas edges.

## Puzzle 56ff96f3 (Hard)
- **Observation**: Single-pixel seeds of a colour expand into thick rectangles: each hue spawns a contiguous band whose width spans the leftmost and rightmost occurrences of that colour and whose height becomes a fixed three-to-five-row slab, leaving blank rows untouched.
- **Hypothesis**: Group pixels by colour, compute the horizontal extent per group, then stamp a full-height band (three rows tall in the examples) filled with that colour across the inferred width at the appropriate vertical position derived from the highest seed.
- **Next Steps**: Determine how the band height is chosen per colour, resolve overlaps when two colours’ bands would collide, and confirm the placement in cases where only one seed exists.

## Puzzle 57aa92db (Hard)
- **Observation**: Each scene carries two disjoint motifs (e.g., a `3` cross with `1`s and a `4` slab with `1`s) suspended in a sea of zeros. The solution fattens each motif into a solid rectangular band aligned to the global axes, thickening the dominant colour while keeping secondary colours (`1`, `2`, `3`, `6`) along the perimeter slots that touched the seed in the input.
- **Hypothesis**: Segment connected components by colour, inflate each component’s bounding box to the nearest even-dimension rectangle, flood the interior with the component’s dominant colour, then repaint any secondary colours on the boundary cells that overlapped the original footprint.
- **Next Steps**: Verify the padding rule (seems to round to a 4×4 lattice), catalogue which boundary cells inherit the minority colour per motif, and ensure overlapping boxes stay disjoint when both components reside in the same quadrant.

## Puzzle 5ad4f10b (Hard)
- **Observation**: Vast carpets reduce to 3×3 emblems: the outer ring reflects the dominant background colour (e.g., `8`, `2`, `3`, `4`) while the centre cross reports which auxiliary colours (corridors or markers) appeared in the input stripes.
- **Hypothesis**: Partition the large board into a 3×3 grid of macro-cells, take the majority colour in each macro, and assemble a 3×3 output where the diagonal cells hold the background hue and the off-diagonal entries encode the presence of feature colours according to the macro bins they occupied.
- **Next Steps**: Confirm that each training pair’s majority calculation reproduces the given icon, document the colour→cell mapping for auxiliary hues, and check whether blank macros should emit zero or inherit a neighbouring colour in unseen cases.

## Puzzle 5c2c9af4 (Hard)
- **Observation**: Sparse seeds (either a few `8`s, `2`s, or `3`s) blossom into regimented lattice patterns: the output paints the entire canvas with evenly spaced rows and columns of the seed colour, producing checkerboarded corridors and solid rings that respect the axes passing through each original marker.
- **Hypothesis**: Treat the seed positions as control points, mirror them about the grid’s midlines to generate a full arithmetic progression of coordinates, and stamp continuous stripes along those rows/columns with the seed colour while leaving intervening cells at zero.
- **Next Steps**: Derive the exact spacing (appears to match seed offsets), record how overlapping stripes fuse into solid blocks, and test whether multiple seed colours can coexist or must be handled independently.

## Puzzle 63613498 (Hard)
- **Observation**: A horizontal bar and vertical column of `5`s partition each board into quadrants. In every training pair the only modification is that the component sitting diagonally opposite the densest non-5 cluster gets recoloured from its native hue (`6`, `9`, `1`, or `7`) to `5`, so the cross now dominates two quadrants while the other colours stay untouched.
- **Hypothesis**: Score the four quadrants by non-zero area; pick the smallest off-axis component (the one farthest from the large cluster) and repaint that entire component with `5`. This matches which region flips in the examples.
- **Next Steps**: Implement a quadrant/component analyser to confirm the “smallest opposite quadrant” heuristic and verify it continues to single out the `7` strip in the held-out test puzzle before coding.

## Puzzle 662c240a (Hard)
- **Observation**: Every input consists of three stacked 3×3 bands with disjoint colour palettes. The output is always a verbatim copy of one whole band; which band is chosen varies per example.
- **Hypothesis**: The selected band appears to be the one whose colour average lies between the other two (middle intensity), except when one band is the only one containing colour `8`, in which case that band wins. Need to verify this heuristic against the training quartet and the test strip.
- **Next Steps**: Compute per-band statistics (mean, min/max, presence of `8`) programmatically to confirm the tie-break logic, and revisit if the test case violates the pattern.

## Puzzle 681b3aeb (Hard)
- **Observation**: Every sparse board hides exactly two coloured components. The 3×3 target is a coarse map that assigns each component to the nearest corner (based on its centroid) and paints a triangular wedge of that colour toward the centre. The relative orientation of the wedges matches how the components appeared NW–SE in the source.
- **Hypothesis**: Segment the grid into connected components, order them by centroid, and rasterise each as a fixed triangular mask in the 3×3 canvas (e.g., NW and SE wedges). Preserve the colour IDs so long as only two components exist.
- **Next Steps**: Double-check centroids do not tie; add a fallback if a third component ever appears; verify that shrinking to triangles still matches all training examples before coding the stencil.

## Puzzle 6855a6e4 (Hard)
- **Observation**: The `2` rectangles already sit in their final positions; only the `5`s move. The solution slides every `5` cluster into the central voids framed by the `2`s, mirroring them across the horizontal axis so each pair of `2` bands gets a matching block of `5`s tucked inside.
- **Hypothesis**: Treat each `5` run as a component, translate it vertically until it sits flush against the nearest `2` belt (respecting symmetry), and leave the `2` scaffolds untouched. Horizontal offsets stay constant.
- **Next Steps**: Work out the translation distance from the training pairs, ensure multiple `5` clusters do not overlap after the shift, and confirm the move keeps counts identical to the source grids.

## Puzzle 6a1e5592 (Hard)
- **Observation**: The upper band is a hollow wall of `2`s; the lower band contains dispersed `5`s. The output erases every `5`, replicates its footprint one floor higher using colour `1`, and also patches the gaps in the `2` band with `1`s so the lifted silhouette stays connected.
- **Hypothesis**: For each `5` pixel, translate it vertically until it abuts the `2` ceiling, paint the new spot `1`, clear the original, and flood-fill any intervening voids in the `2` strip with `1` to keep the outline continuous.
- **Next Steps**: Confirm all `5`s share the same lift distance, guard against collisions when multiple `5`s stack, and ensure no untouched zeros remain inside the `2` frame after the move.

## Puzzle 6aa20dc0 (Hard)
- **Observation**: A monochrome background hosts several disjoint glyphs (pairs of `2`s, `3`s, `8`s, etc.). The transformation packs each glyph into a tight rectangular block anchored at the earliest row/column where that colour appeared, tessellating repeats into larger slabs while leaving the background untouched.
- **Hypothesis**: For every non-background colour, gather its pixels, derive the minimal aligned rectangle spanning them, snap that rectangle toward the top-left within its original quadrant, and fill it solid with the colour. Identical colours that started separated end up merged into the same packed slab.
- **Next Steps**: Validate that every colour’s bounding box stays disjoint after packing, catalogue the quadrant anchors from training, and add collision handling in case two colours vie for the same destination in future puzzles.

## Puzzle 6b9890af (Hard)
- **Observation**: Massive sparse shapes collapse into small summaries. Outputs always show a solid `2` frame around the perimeter with interior pixels recreating the coarse layout of the other colours (`8`, `1`, `4`, `3`), effectively a downsampled emblem of the original scene.
- **Hypothesis**: Compute the bounding box of all non-zero cells, rescale it to a canonical small size with a `2` border, and map each colour’s region into proportional zones inside that box (corner blobs → corners, central masses → centre block).
- **Next Steps**: Derive the exact mapping from training (e.g., distance thresholds for corners vs centre), ensure rescaling preserves adjacency order, and confirm colour counts remain consistent after the projection.

## Puzzle 6d0160f0 (Hard)
- **Observation**: The grids all have a rigid lattice of `5`s forming two full rows and two full columns that divide the scene into four corridors. The outputs keep only that lattice and, for each corridor, leave behind a single color taken from the closest pre-existing pixel along the inner edge while clearing everything else.
- **Hypothesis**: Detect the horizontal/vertical rails of `5`, zero out every other cell, and then repopulate at most one non-`5` per corridor using the color closest to the rail (likely the first non-zero encountered when scanning toward the rail).
- **Next Steps**: Instrument a scan that walks each corridor toward the rail to confirm which source pixel survives, and verify the rule holds on the asymmetric test board before coding anything.

## Puzzle 6d58a25d (Hard)
- **Observation**: Sparse constellations of `8`s (or `7`s/`2`s/`4`s in other cases) retain their outline, but interior voids that lie inside the bounding box of a cluster get filled with a secondary color (often `2` or `8`). Outputs look like the same shapes with their cavities highlighted.
- **Hypothesis**: For each connected component, identify zero cells that sit strictly inside its bounding box and repaint them with the component’s companion color (inferred from nearby non-zero entries such as the centre of the cross-like motif).
- **Next Steps**: Catalogue which companion color goes with each primary hue, and test by flood-filling interior zeros to ensure the fill stops before leaking to the background.

## Puzzle 6e02f1e3 (Hard)
- **Observation**: Each 3×3 tile collapses to a sparse mask of `5`s aligned along one diagonal or along the top row. Which diagonal activates depends on how the two dominant colors meet in the input—when colors swap across the main diagonal, the `5`s follow that diagonal; when the grid is uniform, the entire top row turns to `5`.
- **Hypothesis**: Compare rows and columns to determine the “frontier” where the majority color changes, then draw a line of `5`s along that frontier (main diagonal, anti-diagonal, or top row) while zeroing everything else.
- **Next Steps**: Formalize the frontier detector, maybe by looking at which corners disagree, and verify the rule against all training patterns to avoid misclassifying the uniform cases.

## Puzzle 72322fa7 (Hard)
- **Observation**: Disconnected motifs (small 1/3/4/7/8/9 widgets) reappear in the output as a cross-shaped constellation where each color sits at the intersections formed by its source row and column. The palette is unchanged; the transformation redistributes the markers along shared rows/columns to form symmetric plus signs and repeated triplets like `4 8 4`.
- **Hypothesis**: Treat each connected component in the input as a seed, record the rows and columns it occupies, and stamp the component’s imprint at every intersection of those indices in the output, keeping zeros elsewhere. This explains why single seeds spawn duplicated copies north/south and east/west of the original location.
- **Next Steps**: Build a quick prototype that maps seed coordinates to row/column sets and verify the reconstruction across all training grids before committing to the stamping rule.

## Puzzle 776ffc46 (Hard)
- **Observation**: Giant mosaics of `5`s coupled with smaller digit markers (1,2,3) emerge unchanged except that every marker is upgraded to match the numeric label encoded near it (e.g., `1` corridors become `2`s in the north cluster, `1`s turn into `3`s elsewhere). The surrounding `5` frame stays untouched.
- **Hypothesis**: For each labeled inset, replace the interior `1`s with the marker value (2 or 3) dictated by the neighboring guide strips, replicating the pattern symmetrically across all copies of that inset. Outside those guide zones, leave the grid as-is.
- **Next Steps**: Map each marker region explicitly (north/south/east/west) to nail down which color replaces the `1`s and confirm the same substitution table works on the dense test canvas.

## Puzzle 77fdfe62 (Hard)
- **Observation**: Every grid is a hollow square of `1`s whose four corners carry unique tokens (2/3/4/6/7/9) framing a blob of `8`s and zeros. The solution strips away the `1` frame and compresses the interior so that the corner tokens and the reachable `8` mass are summarized inside a much smaller matrix—corners expand into wedges whose size depends on how much of the interior their `1` corridors touch, while absent connections shrink to zero.
- **Hypothesis**: Excise the outer ring of `1`s, locate the minimal bounding box that still contains all non-zero colors, and downsample that box (eliminating duplicate rows/columns of zeros) so that each connected corner-to-interior region maps to a quadrant in the reduced grid. Populate each reduced cell by propagating the corner color across the pixels that collapse into it.
- **Next Steps**: Formalize the resampling factor (2× vs 3× compression), handle the case where a corner has no access to the interior (should become `0`), and verify the algorithm reproduces the asymmetric spreads seen in the first and third training examples.

## Puzzle 7837ac64 (Hard)
- **Observation**: Monumental 29×29 wallpapers repeat columns of `4` with periodic accent columns in colors like `1`, `2`, `3`, `6`, or `8`. The answers are compact 3×3 grids whose cells report which accent color appears in the corresponding third of the original canvas; tiles containing only `4`s become `0`.
- **Hypothesis**: Partition the input into a 3×3 grid of equal-sized macro tiles (roughly 9–10 cells per side), scan each tile for colors other than the dominant `4`, and write the first/only accent color found into the matching output cell (falling back to `0` when no accent exists).
- **Next Steps**: Verify the tiling boundaries for both square and rectangular cases, clarify how to choose a representative when multiple accent colors land in the same macro tile, and make sure the mapping handles the test case where `2` and `8` split a tile.

## Puzzle 7b6016b9 (Hard)
- **Observation**: Cavernous layouts built from `8` walls and vast `0` voids are transformed into heat maps where every previously empty region turns `3` and the narrow corridors within the `8` scaffolding become ribbons of `2`, while the structural `8`s remain untouched. The sample featuring `7`s simply inherits that color on the frame but the room/corridor split still follows the same recipe.
- **Hypothesis**: Treat `8` (and `7` when present) as solid walls, flood-fill each connected zero chamber, and recolor interior room cells with `3`. For floor tiles that sit immediately adjacent (Manhattan) to a wall, paint them `2` to emphasize the walkway while leaving the wall cells themselves unchanged.
- **Next Steps**: Implement region labeling that distinguishes interior rooms from hallway cells, decide whether corners count as adjacency for the `2` highlight, and test on the large example where multiple chambers share the same frame.

## Puzzle 7c008303 (Hard)
- **Observation**: A vertical spine of `8`s splits the canvas into two colored panels (left with colors like `2/1/6`, right with `4/6/5`). Each panel in the output morphs into a 3×3 icon—essentially a plus-shaped stamp using that panel’s colors—so the final 6×6 answer is just those two icons stacked vertically without the separating spine.
- **Hypothesis**: Crop the columns left and right of the `8` strip, capture the unique color (or pair) used in each panel, and redraw it as the corresponding 3×3 template learned from the training set before arranging the templates into a 2×1 stack.
- **Next Steps**: Catalogue the color→template dictionary (e.g., `2/4` block vs `1/6` block), ensure we reproduce the exact orientation of the pluses, and confirm the test puzzle’s palette matches one of the seen templates.

## Puzzle 7df24a62 (Hard)
- **Observation**: Huge schematics are partitioned by `4`-lined corridors into congruent rooms; only one room initially holds a detailed motif of `1`s (sometimes with embedded `4`s). The solution broadcasts that motif into every room sharing the same `4` frame, effectively stamping the seed pattern throughout the floor plan while preserving the original `4` walls and any existing corner accents.
- **Hypothesis**: Use the `4` lattice to segment the grid into rooms, record the offsets of all non-`4` colors inside the seed room, and clone those offsets into each sibling room (adding the pattern on top of existing data but keeping the walls intact).
- **Next Steps**: Implement flood-fill room detection keyed on `4` borders, decide how to pick the seed room when several contain signal, and handle edge rooms that only partially fit the template.

## Puzzle 83302e8f (Hard)
- **Observation**: An `8` lattice partitions the board into rectangular rooms filled with `0`. Outputs flood each room with either `3` or `4`: rooms whose surrounding `8` walls are intact stay `3`, while rooms adjacent to gaps in the lattice (missing `8`s along a wall) flip to `4`, matching the “doorway” positions seen in training.
- **Hypothesis**: Flood-fill the interior of every `8`-bounded room, decide its color based on whether any boundary segment contains a `0`, and paint the whole room with `3` if fully enclosed or `4` if the wall leaks.
- **Next Steps**: Reconfirm that the gap-detection heuristic matches every training room and make sure we treat lattice holes on both horizontal and vertical walls symmetrically before tackling the test grid.

## Puzzle 834ec97d (Hard)
- **Observation**: Each input has exactly one non-zero beacon in an otherwise blank field. The output drops that beacon one row downward (when space allows) and fills every row above it with a vertical barcode of `4`s: the `4`s land in all columns that share the beacon’s parity, while the alternate columns stay `0`.
- **Hypothesis**: Locate the unique colored cell, shift it down by one row unless it already sits on the bottom edge, then for every row strictly above the new position paint `4` into columns whose index has the same parity as the beacon’s column. Leave the beacon’s row and everything below untouched.
- **Next Steps**: Double-check how the rule behaves when the beacon already occupies the last row or column, and verify no hidden example introduces multiple non-zero seeds.

## Puzzle 8403a5d5 (Hard)
- **Observation**: A lone colored pixel near the bottom spawns a whole scaffold of vertical stripes: every column of the same parity to its right is filled with that color from top to bottom, the interleaving columns stay `0`, and the top/bottom rows sprinkle `5`s at the zero columns immediately to the right of certain stripes as decorative end caps.
- **Hypothesis**: Treat the seed’s column index as the starting parity, flood every second column (seed column onward) with the seed color, and keep the alternating columns at zero. Overlay `5`s on the top and bottom rows wherever a zero column sits directly to the right of a colored stripe—wrapping stops when the grid edge is reached.
- **Next Steps**: Validate the exact placement of the `5` markers (especially on the bottom edge) across all training layouts before coding, and confirm no example requires stripes to propagate left of the seed.

## Puzzle 846bdb03 (Hard)
- **Observation**: Large 13×13 canvases with sparse motifs collapse into compact badges. The outputs strip away zero-only rows/columns, yielding 6×8 or 4×6 icons whose corners are `4`s and whose interior faithfully records the relative placement of the original `1/2/3/4/8` structure without the surrounding emptiness.
- **Hypothesis**: Crop to the minimal bounding box of non-zero cells, compress away empty columns/rows inside that box, and map the surviving skeleton onto a fixed-size emblem with `4`s in the corners and the remaining colors copied into their condensed positions.
- **Next Steps**: Determine the precise compression schedule (which columns/rows are preserved vs merged) and codify the corner templating so the reconstructed badge matches every training example exactly.

## Puzzle 868de0fa (Hard)
- **Observation**: Components of `1`s form hollow shapes whose interior voids are colored in the outputs. Smaller cavities get filled with `2`, whereas larger or corridor-shaped holes are flooded with `7`, yielding two-tone fillings that respect each connected component independently.
- **Hypothesis**: For each `1` component, find enclosed zero regions via flood-fill from the outside, then recolor those holes—likely picking `7` when the pocket spans multiple cells or aligns with a long corridor, and `2` for tight single-cell cavities.
- **Next Steps**: Derive the exact selection rule distinguishing `2` vs `7` (size, aspect ratio, or proximity to the component boundary) so the fill color can be chosen deterministically during implementation.

## Puzzle 8731374e (Hard)
- **Observation**: Deep inside the noisy canvases lies a rectangular block dominated by a single color (e.g., `1`, `4`, or `8`). The outputs crop to that block and mark every row or column that contains an off-color intrusion with the anomaly color, turning the rectangle into a grid where entire rows or columns flip from the dominant color to the intruder.
- **Hypothesis**: Locate the densest monochrome rectangle, identify the majority color and the lone intruder color, then produce a matrix of the same size filled with the majority color except for whole rows and columns that hosted intruders, which get repainted with the anomaly color.
- **Next Steps**: Automate detection of the target rectangle and the anomaly palette, and verify behaviour when multiple intruder colors appear (pick the non-majority color seen in training).

## Puzzle 913fb3ed (Hard)
- **Observation**: Inputs contain a handful of single-color seeds (e.g., `3`, `8`, `2`). Outputs inflate each seed into a 3×3 emblem: a ring of `6`s around the `3`, a cross of `4`s around the `8`, and a `1/2/1` stripe around the `2`, all composed without overlap.
- **Hypothesis**: For every seed color, stamp a prelearned 3×3 template centred on the seed; templates depend on the seed value and combine the surrounding highlight colors accordingly.
- **Next Steps**: Catalogue the color→template mapping from training, ensure stamping is clipped at borders, and verify multiple seeds remain non-overlapping in the test grid.

## Puzzle 90f3ed37 (Hard)
- **Observation**: The `8` structures stay fixed while their horizontal tails get extended with `1`s. Rows that already host `8`s sprout a suffix of `1`s in the columns that match the spacing of the existing `8`s (solid slabs get solid `1` panels, alternating `8` columns yield every-other-column `1`s). Completely blank rows that sit immediately beneath a lone `8` inherit the same suffix pattern, turning the dead space to the right into a light-coloured runway.
- **Hypothesis**: For each row, gather the column offsets of any `8`s (and, if there are none, borrow the offsets from the nearest non-zero row above). Let `step` be the gcd of the gaps between those offsets (defaulting to 1 when only one `8` is present). Starting just right of the final `8`, colour every column whose offset shares that modulo class with `1`, leaving everything else untouched.
- **Next Steps**: Encode the “inherit-from-above” rule so rows like 8/12 in the first training pair pick up the correct pattern, guard against overwriting other colours, and regression-test the parity logic on the alternating examples.

## Puzzle 91413438 (Hard)
- **Observation**: Each 3×3 triangular motif gets broadcast into a much wider canvas by repeating its rows in 3-column stripes: the top band is a long run of identical stripes, while rows further down only keep the leftmost stripe (the original input). The number of stripes varies across puzzles (4, 5, 3, 6 so far, 7 in the test case) but the stripe ordering always mirrors the input rows.
- **Hypothesis**: Tile the input horizontally `k` times, with `k` driven by the geometry of the occupied cells (likely derived from cumulative non-zero counts or another monotone measure of the triangular fill). Optionally duplicate the block vertically for however many input rows still contain a leading colour, leaving all other rows zero.
- **Next Steps**: Reverse-engineer a deterministic formula for `k` (inspect row-prefix non-zero lengths vs. observed stripe counts), then implement the horizontal tiler and vertical truncation once the stripe multiplier is nailed down.

## Puzzle 941d9a10 (Hard)
- **Observation**: Massive rail grids of `5` gain coloured trim: the rows above the first solid `5` belt pick up a stripe of `1`s along the left gutter, the rows sandwiched between the two belts fill the interior corridor with `2`s, and the rows below the second belt add a stripe of `3`s at the right gutter. All other cells, including the `5` scaffolding, stay fixed.
- **Hypothesis**: Detect the horizontal belts of `5`s, divide the board into the north corridor, central corridor, and south corridor, and paint their available columns with the prescribed highlight colours (left edge → `1`, centre span between vertical rails → `2`, right edge → `3`).
- **Next Steps**: Generalise the corridor finder so it works when the belts move vertically, and guard against cases where a corridor has zero width (skip the paint in that band).

## Puzzle 952a094c (Hard)
- **Observation**: Each puzzle is an annulus of a dominant colour (8/7/1/3) punctuated by four accent colours sitting near the centre. The solution keeps the annulus intact but relocates each accent to the midpoint of a different edge, effectively labelling the north, south, east, and west spokes while zeroing the interior.
- **Hypothesis**: Identify the four non-annulus colours, determine which cardinal sector they belong to in the input, and stamp them onto the corresponding outer edge cells after clearing the interior. Leave the annulus itself untouched.
- **Next Steps**: Formalise the mapping from original coordinates to edge midpoints, and ensure cases with repeated accent colours still get assigned consistently.

## Puzzle 97a05b5b (Hard)
- **Observation**: Enormous carpets dominated by `2` get distilled into compact badges: the output is a much smaller grid where the sea of `2`s persists but the rare accent colours (`1`, `3`, `4`, `5`, `8`) are arranged into labelled stripes and blocks that mirror the layout of those accents in the source. It behaves like a downsampled legend for the larger map.
- **Hypothesis**: Partition the big board into coarse tiles, pick the tile majority, and emit a reduced matrix whose cells record either the background `2` or the dominant accent present in that tile. Special features (like the `8`/`5` combos) appear as short runs in the legend rows.
- **Next Steps**: Work out the exact tile size (rows and columns per macro cell), confirm the legend rows always appear in the same order, and double-check whether ties favour the accent or the background before coding.

## Puzzle a48eeaf7 (Hard)
- **Observation**: A lone 2×2 block of `2`s is surrounded by scattered `5` beacons. The target keeps the `2` core fixed but slides every `5` into specific guard slots hugging the block (north face, east face, and a trailing southeast tail), so the hooks form a consistent L-shaped brace in each example.
- **Hypothesis**: Locate the `2` block, compute its bounding box, and reposition each `5` onto a predetermined list of offsets around that box (e.g., above the western edge, due east, southeast). Training counts match the number of available guard slots, suggesting a one-to-one mapping after sorting beacons by quadrant.
- **Next Steps**: Formalise the offset ordering so the same beacon always claims the same slot, and verify on the test grid that no extra `5`s appear which would require extending the template.

## Puzzle a61f2674 (Hard)
- **Observation**: Forests of `5`s occupy a dominant column plus occasional side rails. The answer collapses the shape into a schematic: the column with the densest stack becomes a solid line of `1`s, and any secondary columns that still held `5`s are marked near the bottom with `2`s in the rows where those extras existed.
- **Hypothesis**: Count the number of `5`s per column, fill the maximal column with `1` top-to-bottom, then for every remaining `5` column paint `2` in the rows that referenced it—using a fixed output column so the schematic remains narrow.
- **Next Steps**: Verify the output column chosen for the `2`s (training hints it is the leftmost non-dominant column), ensure ties for the dominant column are impossible, and decide how to encode multiple auxiliary columns if they appear together.

## Puzzle a68b268e (Hard)
- **Observation**: Every 9×9 grid features a cross of `1`s splitting four 4×4 quadrants filled with colours like `7`, `4`, `6`, `8`. The 4×4 output rearranges those quadrant summaries but retains colour frequencies—each quadrant’s colours appear in a unique 2×2 patch, seemingly rotated relative to the original placement.
- **Hypothesis**: Map each quadrant to a dedicated 2×2 block in the output via a fixed permutation (training indicates SE→NW, SW→NE, etc.), filling slots according to quadrant colour counts in reading order.
- **Next Steps**: Derive the exact quadrant→block permutation and slot order; confirm whether zeros inside a quadrant translate to zeros or to another colour indicator; add a quick script to tally counts and verify the rotation theory.

## Puzzle a78176bb (Hard)
- **Observation**: A single colour runs down the main diagonal while a wedge of `5`s hugs its eastern side. The outputs duplicate each diagonal pixel a fixed number of columns to the right (the width of that wedge), wrapping back to the left edge once the offset exceeds the board, so the colour traces a paired diagonal track and the `5`s disappear.
- **Hypothesis**: Measure the maximum horizontal distance from any `5` to the diagonal to recover the offset, then clone every diagonal cell at `col+offset`, modulo the grid width when necessary. Preserve the original diagonal and clear the `5`s.
- **Next Steps**: Confirm the offset extraction holds across all training grids, especially horizontal wedges of different thickness, and codify the wrap-around logic so the second diagonal always stays within bounds.

## Puzzle a8c38be5 (Hard)
- **Observation**: Huge `5`-dominated tapestries shrink to 9×9 mosaics composed of 3×3 tiles. Each tile reports the majority colour from a corresponding macro-region of the source board, so accents like `6`, `2`, `8`, or `9` only survive in the tile representing their part of the canvas.
- **Hypothesis**: Partition the input into a 3×3 grid of equally sized blocks (guided by the regular `5` lattice), compute the modal colour inside each block, and write that colour into the matching 3×3 tile of the output.
- **Next Steps**: Nail down the exact block sizing by replaying the training examples, confirm the majority rule never ties, and ensure the tiler copes with inputs whose dimensions are not perfect multiples of three.

## Puzzle aba27056 (Hard)
- **Observation**: Thick shapes (rectangles or frames) gain an ornate `4` halo: the output overlays a cross-shaped network of `4`s around the existing figure—filling the moat, the diagonals out to the corners, and a small tail that extends to the border—while leaving the original colour untouched inside.
- **Hypothesis**: Compute the bounding box of the non-zero figure, expand it by one cell in all directions, and draw the resulting ring plus the centred cross in colour `4`, clipping to the grid but keeping the pre-existing shape.
- **Next Steps**: Reproduce the exact halo geometry from each training case to confirm where the diagonals and corner beacons appear, then generalise the stencil so differently sized shapes still receive the same treatment.

## Puzzle ae3edfdc (Hard)
- **Observation**: Sparse anchor colours (3, 7, etc.) form plus-sign templates: whenever the same anchor colour appears somewhere along both the row and column of a different pivot cell, the output stamps a 3×3 cross centred on the pivot. The pivot keeps its original colour (2, 1, …) while the four orthogonal neighbours take the anchor colour.
- **Hypothesis**: Index each colour’s row and column occurrences, find intersections where a pivot cell sits at the overlap, and stamp the corresponding 3×3 stencil without disturbing other cells. Overlapping crosses either coincide or remain disjoint in training, so a simple OR should suffice.
- **Next Steps**: Build the colour→rows/cols lookup, confirm that each pivot truly has at least one matching anchor horizontally and vertically, and add guards for potential overlapping stamps in future variants.

## Puzzle b0c4d837 (Hard)
- **Observation**: Tall temples of `5`s with a central `8` plateau shrink to a 3×3 code: the top row reports the plateau’s width (three, two, or one consecutive `8`s), and an extra `8` can appear in the second row when the plateau descends into a lower bay. All other cells stay zero.
- **Hypothesis**: Extract the bounding box of the `8` region, normalise its width/height classes, and map those classes to the observed 3×3 templates (full-width, right-notch, single-spire, etc.).
- **Next Steps**: Tabulate width/height → template mappings from the training set and ensure the selector copes with unseen combinations by defaulting to the closest known pattern.

## Puzzle b27ca6d3 (Hard)
- **Observation**: The grid promotes cross patterns: when a colour (`3`, `7`, …) appears somewhere along both the row and column of another coloured pivot (`2`, `1`, …), the output prints a 3×3 plus centred on the pivot, keeping the pivot’s colour and painting the arms with the anchor colour.
- **Hypothesis**: For every non-zero pivot, search for matching-colour anchors in its row and column; if both exist, stamp the associated cross stencil. Training shows separate crosses never clash, but a merge of identical colours would be harmless.
- **Next Steps**: Cache per-colour row/column positions for quick lookup, confirm that each stamped cross aligns with the training masks, and add collision handling just in case.

## Puzzle d43fd935 (Hard)
- **Observation**: A central `3` cluster acts as the hub; other colours (`1`, `6`, `7`, `8`, `2`) extend straight corridors until they meet the hub or the grid edge, turning isolated markers into full prongs anchored on the `3`s.
- **Hypothesis**: For each non-`3` colour, project its cells horizontally or vertically toward the nearest hub-aligned column/row, filling zeros along the way while keeping the original endpoints intact.
- **Next Steps**: Derive orientation rules per colour from the training pairs and ensure overlapping corridors either agree on colour or are processed in a stable order.

## Puzzle d5d6de2d (Hard)
- **Observation**: Rectangular loops of `2`s retain their borders, but the interior gets repainted to `3`, while any stray `2`s that are not part of a closed frame vanish.
- **Hypothesis**: Detect each closed `2` loop, fill its interior with `3`, and clear standalone `2`s that do not belong to a loop.
- **Next Steps**: Implement a flood-fill that distinguishes enclosed areas from the exterior and handle nested frames without overwriting the surrounding borders.

## Puzzle db93a21d (Hard)
- **Observation**: Sparse 2×k blocks of `9`s act as structural pillars. The output wraps each pillar with `3`-coloured walls, carves connected corridors of `1`s between nearby pillars, and clones those motifs across large tilings, producing a patterned floor plan while keeping the original `9`s intact.
- **Hypothesis**: Identify every rectangular `9` cluster, expand it with a `3` border, and lay down `1`-filled hallways along the axes that connect clusters sharing a row or column, repeating the learnt macro-pattern across tiles separated by all-zero gutters.
- **Next Steps**: Reverse-engineer the exact tiling dimensions so the hallways line up, and guard against overlapping borders when pillars sit closer together in unseen cases.

## Puzzle dbc1a6ce (Hard)
- **Observation**: Scattered `1`s become terminals of a metro map: `8`s fill thick orthogonal corridors linking `1`s that share a row or column, occasionally widening into 5-wide trunks when multiple terminals align. The original `1`s remain as junction markers.
- **Hypothesis**: Build adjacency lists of `1`s by row and column, lay `8` strips along the axis-aligned spans between each connected pair (merging overlaps), and leave other zeros untouched.
- **Next Steps**: Determine the pairing strategy (nearest neighbour vs spanning tree) from the training grids and ensure the corridor width stays consistent for long runs.

## Puzzle dc0a314f (Hard)
- **Observation**: Each 16×16 wallpaper hides a 5-column pillar of `3`s at its centre. The 5×5 outputs echo the colours that flank that pillar: every output column repeats the dominant non-`3` colour found in the corresponding input column once the `3`s are ignored, and the eastern flank consistently votes for colour `2`.
- **Hypothesis**: Locate the contiguous column block filled with `3`, gather the multiset of colours in each column outside that block, select the majority colour per column (falling back to `2` when the column borders the `2` stripe), and broadcast those five picks down the 5×5 canvas.
- **Next Steps**: Recompute the column-wise histograms explicitly to verify the majority rule matches every training pair and confirm the test puzzle’s asymmetry still yields the same five-colour signature.

## Puzzle e5062a87 (Hard)
- **Observation**: Zeros bordered by the wallpaper colour `5` are promoted to `2` so that every gap between parallel `5`s becomes a solid `2` seam. Zeros that lie between two (or more) `5`s turn into `2`s, and the newly created `2`s can in turn help convert additional cavities, yielding ornate pipework around the original grid.
- **Hypothesis**: Iteratively flood any zero cell that has at least two orthogonal neighbours equal to `5` (or one `5` plus one already-converted `2`) and paint it `2`. Repeat until no new cells qualify.
- **Next Steps**: Prove convergence on the training cases, decide whether diagonals should contribute, and test that the rule does not accidentally recolour exposed background zeros.

## Puzzle e6721834 (Hard)
- **Observation**: The giant canvases split into an upper carpet of `8` with embedded digits and a lower field of zeros with sparse markers. The output lifts the two patterned regions into separate, compact strips: the top cluster of `1/2/3` is copied into the middle rows of the answer, while the low-slung `3` markers are rendered as a trimmed patch near the bottom; everything else remains zero.
- **Hypothesis**: Extract tight bounding boxes around the non-`8` region in the top half and the non-zero region in the bottom half, then place those crops onto an empty canvas at fixed target positions (top crop near rows 1–3, bottom crop near rows 9–13 in training).
- **Next Steps**: Confirm the top and bottom boxes never overlap, codify their destination coordinates, and ensure the copy operation preserves the interior ordering of the digits.

## Puzzle e76a88a6 (Hard)
- **Observation**: Each canvas contains two disjoint glyphs: a left blob using colours `{1,4}` (or `{2,4}`) and a right blob of `5`s. The solution copies the colour structure of the left glyph onto the right glyph, reinterpreting the right blob with the same internal palette and leaving the left side unchanged.
- **Hypothesis**: Extract the minimal bounding box of the left motif, record the relative positions of its colours, and apply the same pattern to the right bounding box (replacing its `5`s with the mapped colours while preserving shape).
- **Next Steps**: Handle mismatched box sizes (right blob may be larger), decide how to tile or centre the source template, and verify colour assignments when the left glyph uses three colours.

## Puzzle eb5a1d5d (Hard)
- **Observation**: Massive wallpapers exhibit large uniform borders, interior rings, and a core motif. Outputs compress those structures into small icons that preserve the layer ordering: borders stay on the outside, intermediate bands collapse to ring cells, and the core colour (or motif) sits in the centre.
- **Hypothesis**: Segment the input into concentric regions (background, middle belt, core), read their dominant colours, and render a minimal representative matrix that recreates the same layering relationships.
- **Next Steps**: Automate layer detection via colour changes when moving inward, and confirm cases with extra sublayers (e.g., embedded digits) still map cleanly into the compressed icon.

## Puzzle f1cefba8 (Hard)
- **Observation**: Each training scene has three tiers—background zeros, a thick shell rectangle (8/1/2 depending on the example), and a tighter core patch (2/4/3). In the outputs the shell reclaims the hollowed interior while the core colour migrates to the periphery, reappearing as slim markers on the top/bottom rows and left/right columns aligned with the rows/columns where the core abutted the shell. The result is a crosshair of the core colour at those extremities.
- **Hypothesis**: Identify the core colour as the one confined inside the shell’s bounding box. Repaint all interior core cells with the shell colour, record the row/column indices where the core touched the shell, and project those indices to the outer border—colouring the corresponding top/bottom cells and left/right cells with the core hue to reproduce the observed markers.
- **Next Steps**: Nail down how to extract the row/column contact sets (e.g., track first/last core locations per axis), verify the projection rule against all training grids, and ensure the test case with multiple core streaks still yields the same crosshair pattern.

## Puzzle f25fbde4 (Hard)
- **Observation**: Sparse blobs of `4` in the 9×9 inputs expand into fat orthogonal ribbons: the outputs consist solely of 2-wide horizontal and vertical bars of `4`s arranged so that every source cluster turns into a rectilinear tile of doubled thickness while preserving the Manhattan footprint (straight arms stay straight, single pixels become 2×2 blocks).
- **Hypothesis**: Extract the minimal set of axis-aligned line segments that cover the `4` pixels, then inflate each segment by one cell in both perpendicular directions to obtain 2-cell-thick bars before stitching them back together into one canvas. Zeros become the gaps between these inflated streaks.
- **Next Steps**: Formalise the segment extractor (likely via projecting the component onto rows/columns), confirm that segment inflation faithfully recreates the three training targets, and double-check how overlapping bars should merge when the test layout has multiple crossing limbs.

## Puzzle f35d900a (Hard)
- **Observation**: Inputs carry exactly two beacon colours planted in symmetric pairs. Outputs redraw the board as ornate plaques built from those two hues plus `5`: one colour lays down a 3×3 medallion around each beacon pair, the partner colour mirrors it, and `5`s populate the spokes between them. The overall layout is a rigid template whose orientation depends on which colour started at which corner.
- **Hypothesis**: Identify the two non-zero colours, treat their positions as opposite corners of a mini palindrome, and stamp a prelearned motif (two coloured rings with `5` connectors) centred on the rectangle they span. Choose between the four stored templates by matching the colour ordering extracted from the training set.
- **Next Steps**: Catalogue the motif dictionary (each colour ordering → 17×18 stencil), confirm how the template scales when the seeds land farther apart, and ensure overlapping stencils blend without double-writing conflicting values.

## Puzzle f8c80d96 (Hard)
- **Observation**: Sources combine a solid block of colour with trailing rightward steps of the same hue embedded in zeros. The outputs flood the entire board with that colour and `5`, alternating in a checkerboard of rectangular strips that preserve the original leading edge of the hue while painting every gap with `5`.
- **Hypothesis**: Starting from the leftmost on-colour column, propagate to the right, copying the source colour when the original column was non-zero and writing `5` otherwise, always extending the choice across the whole column and toggling between the two as the original pattern steps downward.
- **Next Steps**: Formalise the column-wise propagator so it follows the seen step edges, test it against rows where the colour reappears after a gap, and ensure the alternation still holds when the starting colour is something other than `8`, `1`, or `2`.

## Puzzle 22168020 (Hard)
- **Observation**: Inputs hold sparse staircases that climb down the main diagonal for one or two colors. Outputs turn each staircase into a solid right triangle pointing toward the lower-left, effectively filling the convex hull of the diagonal hits with the same colour.
- **Hypothesis**: For every colour present, collect its coordinates, compute the minimum and maximum row indices, and paint the triangular envelope by filling all cells `(r,c)` with `r≤c` inside that range. Repeat independently per colour so overlapping triangles are layered in reading order.
- **Next Steps**: Formalise the triangle filler (row-normalised spans), double-check that colours never interleave, and test on the held-out board where orange and blue wedges must both be reconstructed.

## Puzzle b7249182 (Hard)
- **Observation**: Two colour seeds share a column; the output grows each into a plus-shaped emblem (arms length two) centred on its original row while a vertical spine connects the pair. The upper seed’s horizontal bar materialises above the midline, the lower seed’s bar appears below, and the vertical segment carries the respective colours down their portions of the column.
- **Hypothesis**: Locate all non-zero cells, bucket them by colour, and for each bucket draw a fixed cross template centred on the seed (extend two steps horizontally and vertically, clipping at the border). After stamping the crosses, fill the column between the extreme seeds with the colour of the nearest seed to produce the shared spine.
- **Next Steps**: Validate that no training sample ever contains more than two seeds; if a third appears, define how to segment the column to keep the crosses disjoint.

## Puzzle b775ac94 (Hard)
- **Observation**: Sparse markers of `{2,3,4,8,1}` blossom into blocky terraces: each horizontal run is widened into a rectangular stripe by filling the zeros immediately to its left/right, and the highlighted columns are dragged vertically to mirror the colour stack found above. The result is a set of interlocking Tetris-like plates whose edges align with the extremal non-zero coordinates from the input.
- **Hypothesis**: For every row, expand each contiguous non-zero segment to span between the segment’s minimum and maximum columns and optionally one extra cell toward the nearest border; then, for each populated column, propagate the topmost colour downwards until another coloured cell blocks the path. Executing those passes in sequence recreates the thickened rectangles present in the ground truth.
- **Next Steps**: Stress-test the pass ordering (horizontal before vertical) and add assertions so empty columns remain zero even if neighbouring stripes try to bleed sideways.

## Puzzle b782dc8a (Hard)
- **Observation**: Runs of zeros sandwiched between `8` walls are infilled with alternating accent colours (`3`/`2` in the first puzzle, `4`/`1` in the second, `4`/`3` in the test). The palette used for a corridor is exactly the pair of non-eight colours already present in that row or column, and the alternation continues across the entire gap, resetting to match the nearest seed so existing motifs stay aligned.
- **Hypothesis**: For each row, gather the distinct non-zero, non-`8` colours; when a zero span lies between two `8`s or between an `8` and the grid edge, fill it by cycling through the row’s accent pair starting with the colour that appears closest to the span’s left boundary. Columns that still contain zeros after the row sweep can be treated identically to catch vertical corridors.
- **Next Steps**: Confirm the training set never needs more than two accent colours per row/column and formalise the starting parity so overlapping spans keep the existing alternation intact.

## Puzzle b8825c91 (Hard)
- **Observation**: Colour `4` acts as placeholder filler: every 4×4 (or larger) patch of `4`s is replaced with the surrounding loop of thematic colours (`1`,`6`,`7`,`8`,`9`,`2`), extending the neighbouring stripes inward so the completed image has continuous belts and matching quadrants. Outside of those placeholder pockets the layout is copied verbatim.
- **Hypothesis**: Identify connected components of `4`, read the dominant colour on each side of the component (north, south, east, west), and flood the component by projecting those boundary colours inward along their respective axes—effectively painting each row/column of the hole with the majority colour touching that edge. That rule reproduces the seam-free mosaics in training.
- **Next Steps**: Prototype the edge-projection fill and verify it behaves correctly when a `4` cavity touches more than two distinct colours (should prefer the closest edge and only blend when edges agree).

## Puzzle f15e1fac (Hard)
- **Observation**: Columns of `8` behave like conveyor belts: each new row copies the previous set of columns, but when that row contains a `2` the whole pattern shifts one step away from the anchor (`2`s on the left push right, those on the right push left) before the copy continues downward.
- **Hypothesis**: Track the active `8` columns row by row. Start from the first row that already holds `8`s, then, whenever the current input row contains `2`s, offset the column list by `+1` if the anchors sit on the left half and by `-1` when they sit on the right. After the shift, reapply the `8`s and inject any literal `8`s already present in the input.
- **Next Steps**: Verify how to resolve ties when a row carries `2`s on both flanks (e.g. sum the signed shifts), and confirm that clipping prevents the column list from wandering off-grid during repeated pushes.

## Puzzle f9012d9b (Hard)
- **Observation**: The busy checkerboards compress into tiny signature tiles: each answer isolates the smallest submatrix that exhibits the full palette transitions (dividing lines between the dominant colours), then presents that motif in a canonical orientation.
- **Hypothesis**: Scan the board for the tightest bounding box that contains at least one instance of every non-zero colour plus their mutual adjacency; if multiple candidates exist, pick the one with minimal area and, when needed, rotate it so the colour order matches the training outputs. Emit that cropped patch as the entire prediction.
- **Next Steps**: Nail down deterministic tie-breaking when several boxes share the same area, and confirm that degenerate scenes with only one colour collapse to a 1×1 tile rather than leaving stray zeros.

## Puzzle fcb5c309 (Hard)
- **Observation**: Massive canvases feature a sparse highlight colour (4/3/2/8) sprinkled along the perimeter and inside corridors. The solution discards empty rows and columns, then presents the surviving footprint inside a compact frame whose border is fully filled with that highlight colour.
- **Hypothesis**: Identify the dominant non-background colour, collect the unique rows and columns where it appears, remap those indices into a dense grid, paint the outermost rows and columns with the colour, and copy the interior markers wherever the compressed mask still flags them.
- **Next Steps**: Double-check the selection rule for the highlight colour (it’s the tone that never participates in the thick background), and ensure the compression preserves ordering even when two highlight columns sit adjacent in the original.

## Puzzle feca6190 (Hard)
- **Observation**: A single input row unfurls into a square lattice whose anti-diagonals replay the source sequence—each higher row shifts the pattern one column to the left so the non-zero digits drift toward the top-left corner while zeros backfill the void.
- **Hypothesis**: Let `n` be the row length and `k` the count of non-zero entries; allocate an `(n·k)×(n·k)` canvas (falling back to `n×n` when `k=1`), place the original row at the bottom, then iteratively shift the row left by one for each step upward, padding the newly exposed rightmost column with zeros.
- **Next Steps**: Prove the size formula still holds when non-zero tokens sit at the ends (no wrap-around required), and guard against underflow when repeated shifts would push every non-zero off the grid.

## Puzzle ff805c23 (Hard)
- **Observation**: Huge 24×24 wallpapers mix a dominant colour with partner bands; the answer crops a representative 5×5 tile containing the densest patch of that dominant colour, while preserving internal holes wherever companion colours cut through the motif.
- **Hypothesis**: Search the canvas for the tightest 5×5 window with the highest count of the headline colour (3/6/5 in training), lift that mask verbatim, and leave any non-dominant cells as zeros so their absence cues the secondary palette in reconstruction.
- **Next Steps**: Formalise how to break ties between equally dense windows (prefer central placements), and confirm that rotations aren’t required—every training tile already appears axis-aligned.
