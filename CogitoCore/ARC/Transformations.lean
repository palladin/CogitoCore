import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Transformations

def mapGridCellsTransform (f : Cell → Cell) : Transform Grid Grid :=
  { name := "map-grid-cells"
  , apply := fun grid => pure <| grid.map fun row => row.map f }

def gridIdentityTransform : Transform Grid Grid :=
  { name := "grid-id"
  , apply := fun input => pure input }

private def shiftRowRight (row : Array Cell) : Array Cell :=
  let width := row.size
  let rec loop (indices : List Nat) (acc : Array Cell) : Array Cell :=
    match indices with
    | [] => acc
    | idx :: rest =>
        let acc :=
          match row[idx]? with
          | none => acc
          | some cell =>
              if cell == Cell.C0 then
                acc
              else
                let target := idx + 1
                if target < width then
                  acc.set! target cell
                else
                  acc
        loop rest acc
  loop (List.range width) (Array.replicate width Cell.C0)

/-- Shift all non-zero cells one step to the right, ignoring any pixels that would fall off the edge. -/
def shiftNonZeroRightTransform : Transform Grid Grid :=
  { name := "shift-nonzero-right"
  , apply := fun grid => pure <| grid.map shiftRowRight }

instance : Inhabited Cell := ⟨Cell.C0⟩

instance : Inhabited (Array Cell) := ⟨#[]⟩

private def enumerateList {α} : List α → List (Nat × α)
  | xs =>
      let rec loop : Nat → List α → List (Nat × α)
        | _, [] => []
        | idx, x :: rest => (idx, x) :: loop (idx + 1) rest
      loop 0 xs

private def enumerateArray {α} (arr : Array α) : List (Nat × α) :=
  enumerateList arr.toList

private def concatMap {α β} : List α → (α → List β) → List β
  | [], _ => []
  | x :: xs, f => f x ++ concatMap xs f

private def gridHeight (grid : Grid) : Nat :=
  grid.size

private def gridWidth (grid : Grid) : Nat :=
  match grid[0]? with
  | none => 0
  | some row => row.size

private def cellAt (grid : Grid) (rowIdx colIdx : Nat) : Cell :=
  match grid[rowIdx]? with
  | none => Cell.C0
  | some row =>
      match row[colIdx]? with
      | none => Cell.C0
      | some cell => cell

private def incrementCount (counts : List (Cell × Nat)) (color : Cell) : List (Cell × Nat) :=
  let rec go
    | [] => [(color, 1)]
    | (c, n) :: rest =>
        if c == color then
          (c, n + 1) :: rest
        else
          (c, n) :: go rest
  go counts

private def maxCount (counts : List (Cell × Nat)) : Option (Cell × Nat) :=
  match counts with
  | [] => none
  | first :: rest =>
      some <|
        rest.foldl
          (fun (best : Cell × Nat) entry =>
            let (_, bestCount) := best
            let (_, entryCount) := entry
            if entryCount > bestCount then
              entry
            else
              best)
          first

private def majorityNonZeroColor (row : Array Cell) : Option Cell :=
  let counts :=
    row.toList.foldl
      (fun acc cell =>
        if cell == Cell.C0 then
          acc
        else
          incrementCount acc cell)
      []
  match maxCount counts with
  | none => none
  | some (color, _) => some color

private def containsCoord (coords : List (Nat × Nat)) (row col : Nat) : Bool :=
  coords.any fun
    | (r, c) => (r == row) && (c == col)

private def neighbors4 (height width row col : Nat) : List (Nat × Nat) :=
  let up :=
    match row with
    | 0 => []
    | Nat.succ rPred => [(rPred, col)]
  let down := if row + 1 < height then [(row + 1, col)] else []
  let left :=
    match col with
    | 0 => []
    | Nat.succ cPred => [(row, cPred)]
  let right := if col + 1 < width then [(row, col + 1)] else []
  up ++ down ++ left ++ right

private def exploreComponent (grid : Grid) (target : Cell) (height width : Nat)
    (frontier : List (Nat × Nat)) (visited : List (Nat × Nat)) : List (Nat × Nat) :=
  let maxSteps := height * width
  let rec loop (frontier : List (Nat × Nat)) (visited : List (Nat × Nat)) : Nat → List (Nat × Nat)
    | 0 => visited
    | Nat.succ fuel =>
        match frontier with
        | [] => visited
        | (row, col) :: rest =>
            if containsCoord visited row col then
              loop rest visited fuel
            else
              let current := cellAt grid row col
              if current == target then
                let visited := (row, col) :: visited
                let newNeighbors :=
                  (neighbors4 height width row col).filter fun
                    | (nr, nc) =>
                        (cellAt grid nr nc == target) && (!containsCoord visited nr nc)
                loop (newNeighbors ++ rest) visited fuel
              else
                loop rest visited fuel
  loop frontier visited maxSteps

private def countComponents (grid : Grid) (target : Cell) : Nat :=
  let height := gridHeight grid
  let width := gridWidth grid
  let rec rowLoop (rowIdx : Nat) (visited : List (Nat × Nat)) (count : Nat) : Nat :=
    if rowIdx ≥ height then
      count
    else
      let rec colLoop (colIdx : Nat) (visited : List (Nat × Nat)) (count : Nat) : (List (Nat × Nat)) × Nat :=
        if colIdx ≥ width then
          (visited, count)
        else
          let hasTarget := cellAt grid rowIdx colIdx == target
          let already := containsCoord visited rowIdx colIdx
          if hasTarget && !already then
            let visited := exploreComponent grid target height width [(rowIdx, colIdx)] visited
            colLoop (colIdx + 1) visited (count + 1)
          else
            colLoop (colIdx + 1) visited count
      let (visited, count) := colLoop 0 visited count
      rowLoop (rowIdx + 1) visited count
  rowLoop 0 [] 0

private def diagonalGrid (size : Nat) (color : Cell) : Grid :=
  Array.mk <|
    (List.range size).map fun rowIdx =>
      Array.mk <|
        (List.range size).map fun colIdx =>
          if colIdx == rowIdx then color else Cell.C0

private def componentsToDiagonal (grid : Grid) (target : Cell) : Grid :=
  diagonalGrid (countComponents grid target) target

private def rowUniformColor (row : Array Cell) : Option Cell :=
  match row[0]? with
  | none => none
  | some color =>
      if row.all (fun cell => cell == color) then
        if color == Cell.C0 then
          none
        else
          some color
      else
        none

private def findSeparatorColor (grid : Grid) : Option Cell :=
  let rec loop : List (Array Cell) → Option Cell
    | [] => none
    | row :: rest =>
        match rowUniformColor row with
        | some color => some color
        | none => loop rest
  loop grid.toList

private def columnDominantColors (grid : Grid) : List (Nat × Cell) :=
  match grid[0]? with
  | none => []
  | some firstRow =>
      let width := firstRow.size
      let height := grid.size
      let columns := List.range width
      let collected :=
        columns.foldl
          (fun acc colIdx =>
            let counts :=
              grid.toList.foldl
                (fun tally row =>
                  match row[colIdx]? with
                  | some cell =>
                      if cell == Cell.C0 then
                        tally
                      else
                        incrementCount tally cell
                  | none => tally)
                []
            match maxCount counts with
            | some (color, occurrences) =>
                if occurrences * 2 > height then
                  (colIdx, color) :: acc
                else
                  acc
            | none => acc)
          []
      collected.reverse

private def gridToLists (grid : Grid) : List (List Cell) :=
  grid.toList.map fun row => row.toList

private def listsToGrid (rows : List (List Cell)) : Grid :=
  Array.mk <| rows.map fun cells => Array.mk cells

private def dedupeConsecutiveLists : List (List Cell) → List (List Cell)
  | [] => []
  | x :: xs =>
      let rec aux (prev : List Cell) (acc : List (List Cell)) : List (List Cell) → List (List Cell)
        | [] => (prev :: acc).reverse
        | y :: ys =>
            if y == prev then
              aux prev acc ys
            else
              aux y (prev :: acc) ys
      aux x [] xs

private def removeConsecutiveDuplicateRows (grid : Grid) : Grid :=
  listsToGrid <| dedupeConsecutiveLists <| gridToLists grid

private def transposeGrid (grid : Grid) : Grid :=
  match grid.toList with
  | [] => #[]
  | firstRow :: _ =>
      let width := firstRow.size
      let height := grid.size
      let cols :=
        (List.range width).map fun colIdx =>
          Array.mk <|
            (List.range height).map fun rowIdx => cellAt grid rowIdx colIdx
      Array.mk cols

private def removeConsecutiveDuplicateColumns (grid : Grid) : Grid :=
  transposeGrid <| removeConsecutiveDuplicateRows <| transposeGrid grid

private def applyBorderColor (color : Cell) (grid : Grid) : Grid :=
  let height := grid.size
  let rowList :=
    (enumerateArray grid).map fun rowInfo =>
      match rowInfo with
      | (rowIdx, row) =>
          let width := row.size
          let cellList :=
            (enumerateArray row).map fun cellInfo =>
              match cellInfo with
              | (colIdx, cell) =>
                  let onBorder :=
                    (rowIdx == 0) ||
                    (rowIdx + 1 == height) ||
                    (colIdx == 0) ||
                    (colIdx + 1 == width)
                  if onBorder then color else cell
          Array.mk cellList
  Array.mk rowList

/-- Replace the outer border of a grid with the provided color, keeping interior cells intact. -/
def frameBorderTransform (color : Cell) : Transform Grid Grid :=
  { name := "frame-border"
  , apply := fun grid => pure <| applyBorderColor color grid }

/-- Remove rows that are identical to their immediate predecessor. -/
def removeConsecutiveDuplicateRowsTransform : Transform Grid Grid :=
  { name := "dedupe-rows"
  , apply := fun grid => pure <| removeConsecutiveDuplicateRows grid }

/-- Remove columns that are identical to their immediate predecessor. -/
def removeConsecutiveDuplicateColumnsTransform : Transform Grid Grid :=
  { name := "dedupe-cols"
  , apply := fun grid => pure <| removeConsecutiveDuplicateColumns grid }

private def isSeparatorRow (row : Array Cell) (separator : Cell) : Bool :=
  row.all (fun cell => cell == separator)

private def isSeparatorColumn (grid : Grid) (colIdx : Nat) (separator : Cell) : Bool :=
  grid.toList.all fun row =>
    match row[colIdx]? with
    | some cell => cell == separator
    | none => True

private def countSegments (flags : List Bool) : Nat :=
  let rec loop : Bool → Nat → List Bool → Nat
    | _, count, [] => count
    | inSeg, count, flag :: rest =>
        if flag then
          if inSeg then
            loop True count rest
          else
            loop True (count + 1) rest
        else
          loop False count rest
  loop False 0 flags

private def findFirstNonSeparatorColor (grid : Grid) (separator : Cell) : Option Cell :=
  let rec rowLoop : List (Array Cell) → Option Cell
    | [] => none
    | row :: rest =>
        let rec cellLoop : List Cell → Option Cell
          | [] => none
          | cell :: tail =>
              if cell == separator then
                cellLoop tail
              else
                some cell
        match cellLoop row.toList with
        | some cell => some cell
        | none => rowLoop rest
  rowLoop grid.toList

private def compressBySeparators (grid : Grid) : Except String Grid :=
  match findSeparatorColor grid with
  | none => .error "no uniform separator row"
  | some separator =>
      let rowFlags := grid.toList.map fun row => !isSeparatorRow row separator
      let rowSegments := countSegments rowFlags
      let width :=
        match grid[0]? with
        | none => 0
        | some row => row.size
      let colFlags := (List.range width).map fun colIdx => !isSeparatorColumn grid colIdx separator
      let colSegments := countSegments colFlags
      match findFirstNonSeparatorColor grid separator with
      | none => .error "no fill color"
      | some fill =>
          if rowSegments == 0 || colSegments == 0 then
            .error "no non-separator segments"
          else
            pure <| Array.replicate rowSegments (Array.replicate colSegments fill)

/-- Collapse a grid made of repeated blocks separated by uniform rows and columns down to the block count, filled with the primary color. -/
def compressSeparatorsTransform : Transform Grid Grid :=
  { name := "compress-separators"
  , apply := compressBySeparators }

private def boundingBox (grid : Grid) : Option (Nat × Nat × Nat × Nat) :=
  let updateForCell
      (acc : Option (Nat × Nat × Nat × Nat))
      (rowIdx : Nat)
      (colIdx : Nat)
      (cell : Cell) : Option (Nat × Nat × Nat × Nat) :=
    if cell == Cell.C0 then
      acc
    else
      match acc with
      | none => some (rowIdx, rowIdx, colIdx, colIdx)
      | some (minRow, maxRow, minCol, maxCol) =>
          some
            (Nat.min minRow rowIdx,
             Nat.max maxRow rowIdx,
             Nat.min minCol colIdx,
             Nat.max maxCol colIdx)
  let updateForRow
      (acc : Option (Nat × Nat × Nat × Nat))
      (rowInfo : Nat × Array Cell)
      : Option (Nat × Nat × Nat × Nat) :=
    match rowInfo with
    | (rowIdx, row) =>
        List.foldl
          (fun innerAcc cellInfo =>
            match cellInfo with
            | (colIdx, cell) => updateForCell innerAcc rowIdx colIdx cell)
          acc
          (enumerateArray row)
  List.foldl updateForRow none (enumerateArray grid)

private def setCell (grid : Grid) (rowIdx colIdx : Nat) (color : Cell) : Grid :=
  match grid[rowIdx]? with
  | none => grid
  | some row =>
      match row[colIdx]? with
      | none => grid
      | some _ =>
          let newRow := row.set! colIdx color
          grid.set! rowIdx newRow

private def listContainsNat (xs : List Nat) (value : Nat) : Bool :=
  xs.any fun entry => entry == value

private def pushNatIfNew (xs : List Nat) (value : Nat) : List Nat :=
  if listContainsNat xs value then xs else xs ++ [value]

private def collectSeparatorRows (grid : Grid) (separator : Cell) : List Nat :=
  (enumerateArray grid).foldl
    (fun acc entry =>
      match entry with
      | (rowIdx, row) =>
          if isSeparatorRow row separator then
            pushNatIfNew acc rowIdx
          else
            acc)
    []

private def collectSeparatorColumns (grid : Grid) (separator : Cell) : List Nat :=
  let width := gridWidth grid
  (List.range width).foldl
    (fun acc colIdx =>
      if isSeparatorColumn grid colIdx separator then
        pushNatIfNew acc colIdx
      else
        acc)
    []

private def consecutiveDiffs (values : List Int) : List Nat :=
  let rec loop : Int → List Int → List Nat
    | _, [] => []
    | previous, current :: rest =>
        let tail := loop current rest
        let diff := current - previous
        if diff > 0 then
          let diffNat : Nat := Int.toNat diff
          pushNatIfNew tail diffNat
        else
          tail
  match values with
  | [] => []
  | first :: rest => loop first rest

private def translationSteps (size : Nat) (axes : List Nat) : List Nat :=
  if axes.isEmpty then
    []
  else
    let sorted := axes.map Int.ofNat
    let separators := (-1 : Int) :: sorted ++ [Int.ofNat size]
    consecutiveDiffs separators

private def propagateIndices (start : Nat) (steps : List Nat)
    (limit : Nat) (blocked : List Nat) : List Nat :=
  if listContainsNat blocked start then
    []
  else
    let maxSteps := (limit + 1) * (steps.length + 1)
    let rec loop (frontier visited : List Nat) : Nat → List Nat
      | 0 => visited
      | Nat.succ fuel =>
          match frontier with
          | [] => visited
          | idx :: rest =>
              if listContainsNat visited idx then
                loop rest visited fuel
              else if listContainsNat blocked idx then
                loop rest visited fuel
              else
                let visited := idx :: visited
                let neighbors :=
                  steps.foldl
                    (fun acc step =>
                      let acc :=
                        if idx + step < limit && !listContainsNat blocked (idx + step) then
                          (idx + step) :: acc
                        else
                          acc
                      let acc :=
                        if idx ≥ step && !listContainsNat blocked (idx - step) then
                          (idx - step) :: acc
                        else
                          acc
                      acc)
                    []
                loop (neighbors ++ rest) visited fuel
    (loop [start] [] maxSteps).reverse

private def propagateAcrossSeparatorsCore (grid : Grid) (separator : Cell) : Grid :=
  let height := gridHeight grid
  let width := gridWidth grid
  let axisRows := collectSeparatorRows grid separator
  let axisCols := collectSeparatorColumns grid separator
  let rowSteps := translationSteps height axisRows
  let colSteps := translationSteps width axisCols
  if rowSteps.isEmpty && colSteps.isEmpty then
    grid
  else
    let blockedRows := axisRows
    let blockedCols := axisCols
    let rec processRows (entries : List (Nat × Array Cell)) (acc : Grid) : Grid :=
      match entries with
      | [] => acc
      | (rowIdx, row) :: rest =>
          let rec processCells (cells : List (Nat × Cell)) (acc : Grid) : Grid :=
            match cells with
            | [] => acc
            | (colIdx, cell) :: tail =>
                if (cell == Cell.C0) || (cell == separator) then
                  processCells tail acc
                else
                  let targetRows := propagateIndices rowIdx rowSteps height blockedRows
                  let targetCols := propagateIndices colIdx colSteps width blockedCols
                  let acc :=
                    targetRows.foldl
                      (fun inner rowTarget =>
                        targetCols.foldl
                          (fun innerAcc colTarget => setCell innerAcc rowTarget colTarget cell)
                          inner)
                      acc
                  processCells tail acc
          processRows rest (processCells (enumerateArray row) acc)
    processRows (enumerateArray grid) grid

private def propagateAcrossSeparators (grid : Grid) : Grid :=
  match findSeparatorColor grid with
  | none => grid
  | some separator => propagateAcrossSeparatorsCore grid separator

/-- Repeat each non-separator cell across bands divided by uniform separator rows and columns. -/
def propagateAcrossSeparatorsTransform : Transform Grid Grid :=
  { name := "propagate-across-separators"
  , apply := fun grid => pure <| propagateAcrossSeparators grid }

private def enforceBoundingBoxSymmetry (grid : Grid) : Grid :=
  match boundingBox grid with
  | none => grid
  | some (minRow, maxRow, minCol, maxCol) =>
      let centerRow := (minRow + maxRow) / 2
      let centerCol := (minCol + maxCol) / 2
      let centerRowInt : Int := Int.ofNat centerRow
      let centerColInt : Int := Int.ofNat centerCol
      let heightInt : Int := Int.ofNat grid.size
      let symmetryPositions (rowIdx colIdx : Nat) : List (Nat × Nat) :=
        let dr := Int.ofNat rowIdx - centerRowInt
        let dc := Int.ofNat colIdx - centerColInt
        let deltas : List (Int × Int) :=
          [ (dr, dc)
          , (dr, -dc)
          , (-dr, dc)
          , (-dr, -dc)
          , (dc, dr)
          , (dc, -dr)
          , (-dc, dr)
          , (-dc, -dr)
          ]
        concatMap deltas fun delta =>
          match delta with
          | (dRow, dCol) =>
              let targetRow := centerRowInt + dRow
              let targetCol := centerColInt + dCol
              if (targetRow ≥ 0) && (targetRow < heightInt) && (targetCol ≥ 0) then
                let rNat := Int.toNat targetRow
                let cNat := Int.toNat targetCol
                [(rNat, cNat)]
              else
                []
      let coords :=
        concatMap (enumerateArray grid) fun rowInfo =>
          match rowInfo with
          | (rowIdx, row) =>
              concatMap (enumerateArray row) fun cellInfo =>
                match cellInfo with
                | (colIdx, cell) =>
                    if cell == Cell.C0 then
                      []
                    else
                      (symmetryPositions rowIdx colIdx).map fun pos =>
                        match pos with
                        | (r, c) => (r, c, cell)
      List.foldl (fun acc coord =>
        match coord with
        | (r, c, cell) => setCell acc r c cell) grid coords

/-- Reflect every non-zero cell across both the vertical and horizontal midlines of its bounding box. -/
def mirrorBoundingBoxSymmetryTransform : Transform Grid Grid :=
  { name := "mirror-bbox-symmetry"
  , apply := fun grid => pure <| enforceBoundingBoxSymmetry grid }

private def findCellInRow (row : Array Cell) (target : Cell) : Option Nat :=
  let rec loop : List (Nat × Cell) → Option Nat
    | [] => none
    | (colIdx, cell) :: rest =>
        if cell == target then
          some colIdx
        else
          loop rest
  loop (enumerateArray row)

private def findCellPosition (grid : Grid) (target : Cell) : Option (Nat × Nat) :=
  let rec loop : List (Nat × Array Cell) → Option (Nat × Nat)
    | [] => none
    | (rowIdx, row) :: rest =>
        match findCellInRow row target with
        | some colIdx => some (rowIdx, colIdx)
        | none => loop rest
  loop (enumerateArray grid)

private def fillHorizontalPath (grid : Grid) (rowIdx colA colB : Nat)
    (skip : List (Nat × Nat)) (color : Cell) : Grid :=
  let lo := Nat.min colA colB
  let hi := Nat.max colA colB
  let diff := hi - lo
  let indices := List.range (Nat.succ diff)
  indices.foldl
    (fun acc offset =>
      let colIdx := lo + offset
      if containsCoord skip rowIdx colIdx then
        acc
      else
        setCell acc rowIdx colIdx color)
    grid

private def fillVerticalPath (grid : Grid) (colIdx rowA rowB : Nat)
    (skip : List (Nat × Nat)) (color : Cell) : Grid :=
  let lo := Nat.min rowA rowB
  let hi := Nat.max rowA rowB
  let diff := hi - lo
  let indices := List.range (Nat.succ diff)
  indices.foldl
    (fun acc offset =>
      let rowIdx := lo + offset
      if containsCoord skip rowIdx colIdx then
        acc
      else
        setCell acc rowIdx colIdx color)
    grid

private def connectEightToTwoPath (grid : Grid) : Grid :=
  match findCellPosition grid Cell.C8, findCellPosition grid Cell.C2 with
  | some (rowEight, colEight), some (rowTwo, colTwo) =>
      let skip := [(rowEight, colEight), (rowTwo, colTwo)]
      let grid := fillHorizontalPath grid rowTwo colTwo colEight skip Cell.C4
      let grid := fillVerticalPath grid colEight rowEight rowTwo skip Cell.C4
      grid
  | _, _ => grid

/-- Connect the unique 8 and the unique 2 with a 4-colored orthogonal path that first follows the row of the 2 and then the column of the 8. -/
def connectEightToTwoPathTransform : Transform Grid Grid :=
  { name := "connect-eight-two-path"
  , apply := fun grid => pure <| connectEightToTwoPath grid }

private def alignColumnUsingBase (base : Grid) (grid : Grid) (colIdx : Nat) (colColor : Cell) : Grid :=
  let height := base.size
  let rec loop (rowIdx : Nat) (acc : Grid) : Grid :=
    if rowIdx ≥ height then
      acc
    else
      match base[rowIdx]? with
      | none => acc
      | some baseRow =>
          if colIdx ≥ baseRow.size then
            loop (rowIdx + 1) acc
          else
            let newColor? : Option Cell :=
              match rowUniformColor baseRow with
              | some _ => some colColor
              | none => majorityNonZeroColor baseRow
            match newColor? with
            | some newColor =>
                loop (rowIdx + 1) (setCell acc rowIdx colIdx newColor)
            | none =>
                loop (rowIdx + 1) acc
  loop 0 grid

private def alignCrossSegmentsCore (base : Grid) (grid : Grid) (columns : List (Nat × Cell)) : Grid :=
  columns.foldl
    (fun acc entry =>
      match entry with
      | (colIdx, colColor) => alignColumnUsingBase base acc colIdx colColor)
    grid

private def alignCrossSegments (grid : Grid) : Grid :=
  let base := grid
  let columns := columnDominantColors base
  alignCrossSegmentsCore base grid columns

/-- Harmonise the intersection of dominant rows and columns: uniform rows adopt the column color, while mixed rows reinforce their majority color. -/
def alignCrossSegmentsTransform : Transform Grid Grid :=
  { name := "align-cross-segments"
  , apply := fun grid => pure <| alignCrossSegments grid }

/-- Count connected components of a target color and emit a diagonal of that color whose size equals the count. -/
def componentsToDiagonalTransform (target : Cell) : Transform Grid Grid :=
  { name := "components-to-diagonal"
  , apply := fun grid => pure <| componentsToDiagonal grid target }

private def paintIfZero (grid : Grid) (rowIdx colIdx : Nat) (color : Cell) : Grid :=
  match grid[rowIdx]? with
  | none => grid
  | some row =>
      match row[colIdx]? with
      | none => grid
      | some existing =>
          if existing == Cell.C0 then
            let newRow := row.set! colIdx color
            grid.set! rowIdx newRow
          else
            grid

private def fillRowBetween (grid : Grid) (rowIdx startCol endCol : Nat) (color : Cell) : Grid :=
  let lo := startCol + 1
  let rec loop (acc : Grid) (colIdx : Nat) : Grid :=
    if colIdx ≥ endCol then
      acc
    else
      loop (paintIfZero acc rowIdx colIdx color) (colIdx + 1)
  if lo ≥ endCol then
    grid
  else
    loop grid lo

private def fillColumnBetween (grid : Grid) (colIdx startRow endRow : Nat) (color : Cell) : Grid :=
  let lo := startRow + 1
  let rec loop (acc : Grid) (rowIdx : Nat) : Grid :=
    if rowIdx ≥ endRow then
      acc
    else
      loop (paintIfZero acc rowIdx colIdx color) (rowIdx + 1)
  if lo ≥ endRow then
    grid
  else
    loop grid lo

private def nearestLeft (row : Array Cell) (limit : Nat) : Option (Nat × Cell) :=
  (enumerateArray row).foldl
    (fun acc entry =>
      match entry with
      | (colIdx, cell) =>
          if (cell == Cell.C0) || (colIdx ≥ limit) then
            acc
          else
            match acc with
            | none => some (colIdx, cell)
            | some (bestIdx, _) =>
                if colIdx > bestIdx then
                  some (colIdx, cell)
                else
                  acc)
    none

private def nearestRight (row : Array Cell) (start : Nat) : Option (Nat × Cell) :=
  (enumerateArray row).foldl
    (fun acc entry =>
      match entry with
      | (colIdx, cell) =>
          if (cell == Cell.C0) || (colIdx ≤ start) then
            acc
          else
            match acc with
            | none => some (colIdx, cell)
            | some (bestIdx, _) =>
                if colIdx < bestIdx then
                  some (colIdx, cell)
                else
                  acc)
    none

private def nearestAbove (grid : Grid) (colIdx limitRow : Nat) : Option (Nat × Cell) :=
  let rec loop (rowIdx : Nat) (acc : Option (Nat × Cell)) : Option (Nat × Cell) :=
    if rowIdx ≥ limitRow then
      acc
    else
      match grid[rowIdx]? with
      | none => loop (rowIdx + 1) acc
      | some row =>
          match row[colIdx]? with
          | none => loop (rowIdx + 1) acc
          | some cell =>
              if cell == Cell.C0 then
                loop (rowIdx + 1) acc
              else
                loop (rowIdx + 1) (some (rowIdx, cell))
  loop 0 none

private def nearestBelow (grid : Grid) (colIdx startRow : Nat) : Option (Nat × Cell) :=
  let height := grid.size
  let rec loop (rowIdx : Nat) : Option (Nat × Cell) :=
    if rowIdx ≥ height then
      none
    else
      match grid[rowIdx]? with
      | none => loop (rowIdx + 1)
      | some row =>
          match row[colIdx]? with
          | none => loop (rowIdx + 1)
          | some cell =>
              if cell == Cell.C0 then
                loop (rowIdx + 1)
              else
                some (rowIdx, cell)
  loop (startRow + 1)

private def connectBlockRows (grid : Grid) (r0 r1 c0 c1 : Nat) : Grid :=
  [r0, r1].foldl
    (fun acc rowIdx =>
      match acc[rowIdx]? with
      | none => acc
      | some row =>
          let acc :=
            match nearestLeft row c0 with
            | none => acc
            | some (colIdx, color) => fillRowBetween acc rowIdx colIdx c0 color
          let acc :=
            match nearestRight row c1 with
            | none => acc
            | some (colIdx, color) => fillRowBetween acc rowIdx c1 colIdx color
          acc)
    grid

private def connectBlockColumns (grid : Grid) (r0 r1 c0 c1 : Nat) : Grid :=
  [c0, c1].foldl
    (fun acc colIdx =>
      let acc :=
        match nearestAbove acc colIdx r0 with
        | none => acc
        | some (rowIdx, color) => fillColumnBetween acc colIdx rowIdx r0 color
      let acc :=
        match nearestBelow acc colIdx r1 with
        | none => acc
        | some (rowIdx, color) => fillColumnBetween acc colIdx r1 rowIdx color
      acc)
    grid

private def findUniformBlock (grid : Grid) : Option (Nat × Nat) :=
  let height := grid.size
  let rec rowLoop (rowIdx : Nat) : Option (Nat × Nat) :=
    if rowIdx + 1 ≥ height then
      none
    else
      match grid[rowIdx]? with
      | none => rowLoop (rowIdx + 1)
      | some row =>
          match grid[rowIdx + 1]? with
          | none => rowLoop (rowIdx + 1)
          | some nextRow =>
              let width := Nat.min row.size nextRow.size
              let rec colLoop (colIdx : Nat) : Option (Nat × Nat) :=
                if colIdx + 1 ≥ width then
                  none
                else
                  match row[colIdx]?, row[colIdx + 1]?, nextRow[colIdx]?, nextRow[colIdx + 1]? with
                  | some topLeft, some topRight, some bottomLeft, some bottomRight =>
                      if topLeft == Cell.C0 then
                        colLoop (colIdx + 1)
                      else if (topLeft == topRight) && (topLeft == bottomLeft) && (topLeft == bottomRight) then
                        some (rowIdx, colIdx)
                      else
                        colLoop (colIdx + 1)
                  | _, _, _, _ => colLoop (colIdx + 1)
              match colLoop 0 with
              | some res => some res
              | none => rowLoop (rowIdx + 1)
  rowLoop 0

private def connectToUniformBlock (grid : Grid) : Grid :=
  match findUniformBlock grid with
  | none => grid
  | some (r0, c0) =>
      let r1 := r0 + 1
      let c1 := c0 + 1
      let grid := connectBlockRows grid r0 r1 c0 c1
      connectBlockColumns grid r0 r1 c0 c1

/-- Connect each non-zero lying on the same row or column as a detected uniform 2×2 block to that block through adjacent zeros. -/
def connectToUniformBlockTransform : Transform Grid Grid :=
  { name := "connect-uniform-block"
  , apply := fun grid => pure <| connectToUniformBlock grid }

end CogitoCore.ARC.Transformations
