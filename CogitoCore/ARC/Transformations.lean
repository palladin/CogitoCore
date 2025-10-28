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

private def boolToNat : Bool → Nat
  | true => 1
  | false => 0

private def maxCount (counts : List (Cell × Nat)) : Option (Cell × Nat) :=
  match counts with
  | [] => none
  | first :: rest =>
      some <|
        rest.foldl
          (fun (best : Cell × Nat) entry =>
            match best, entry with
            | (_, bestCount), (color, count) =>
                if count > bestCount then
                  (color, count)
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

private def boundingBoxForColor (grid : Grid) (color : Cell) : Option (Nat × Nat × Nat × Nat) :=
  let updateForCell
      (acc : Option (Nat × Nat × Nat × Nat))
      (rowIdx : Nat)
      (colIdx : Nat)
      (cell : Cell) : Option (Nat × Nat × Nat × Nat) :=
    if cell == color then
      match acc with
      | none => some (rowIdx, rowIdx, colIdx, colIdx)
      | some (minRow, maxRow, minCol, maxCol) =>
          some
            (Nat.min minRow rowIdx,
             Nat.max maxRow rowIdx,
             Nat.min minCol colIdx,
             Nat.max maxCol colIdx)
    else
      acc
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

private def cropBoundingBox (grid : Grid) : Grid :=
  match boundingBox grid with
  | none => grid
  | some (minRow, maxRow, minCol, maxCol) =>
      let height := maxRow + 1 - minRow
      let width := maxCol + 1 - minCol
      let rows := List.range height
      let cols := List.range width
      Array.mk <|
        rows.map fun rowOffset =>
          let rowIdx := minRow + rowOffset
          Array.mk <|
            cols.map fun colOffset =>
              let colIdx := minCol + colOffset
              cellAt grid rowIdx colIdx

private def setCell (grid : Grid) (rowIdx colIdx : Nat) (color : Cell) : Grid :=
  match grid[rowIdx]? with
  | none => grid
  | some row =>
      match row[colIdx]? with
      | none => grid
      | some _ =>
          let newRow := row.set! colIdx color
          grid.set! rowIdx newRow

private def componentCoordinates (grid : Grid) (target : Cell) : List (List (Nat × Nat)) :=
  let height := gridHeight grid
  let width := gridWidth grid
  let rec rowLoop (rowIdx : Nat) (visited : List (Nat × Nat)) (acc : List (List (Nat × Nat))) : List (List (Nat × Nat)) :=
    if rowIdx ≥ height then
      acc.reverse
    else
      let rec colLoop (colIdx : Nat) (visited : List (Nat × Nat)) (acc : List (List (Nat × Nat))) : (List (Nat × Nat)) × List (List (Nat × Nat)) :=
        if colIdx ≥ width then
          (visited, acc)
        else
          let hasTarget := cellAt grid rowIdx colIdx == target
          let already := containsCoord visited rowIdx colIdx
          if hasTarget && !already then
            let component := exploreComponent grid target height width [(rowIdx, colIdx)] []
            let visited := component ++ visited
            colLoop (colIdx + 1) visited (component :: acc)
          else
            colLoop (colIdx + 1) visited acc
      let (visited, acc) := colLoop 0 visited acc
      rowLoop (rowIdx + 1) visited acc
  rowLoop 0 [] []

private def neighborContribution (component : List (Nat × Nat)) (row col : Nat) : Nat :=
  let up :=
    match row with
    | 0 => 0
    | Nat.succ rPred => boolToNat (containsCoord component rPred col)
  let down := boolToNat (containsCoord component (row + 1) col)
  let left :=
    match col with
    | 0 => 0
    | Nat.succ cPred => boolToNat (containsCoord component row cPred)
  let right := boolToNat (containsCoord component row (col + 1))
  up + down + left + right

private def componentNeighborScore (component : List (Nat × Nat)) : Nat :=
  component.foldl
    (fun acc coord =>
      match coord with
      | (row, col) => acc + neighborContribution component row col)
    0

private def componentHasCycle (component : List (Nat × Nat)) : Bool :=
  let neighborScore := componentNeighborScore component
  neighborScore ≥ component.length * 2

private def setComponentColor (grid : Grid) (component : List (Nat × Nat)) (color : Cell) : Grid :=
  component.foldl
    (fun acc coord =>
      match coord with
      | (row, col) => setCell acc row col color)
    grid

private def recolorCyclicComponents (grid : Grid) (target replacement : Cell) : Grid :=
  (componentCoordinates grid target).foldl
    (fun acc component =>
      if componentHasCycle component then
        setComponentColor acc component replacement
      else
        acc)
    grid

private def recolorAdjacentCells (grid : Grid) (target anchor replacement : Cell) : Grid :=
  match boundingBoxForColor grid anchor with
  | none => grid
  | some (minRow, maxRow, minCol, maxCol) =>
      (enumerateArray grid).foldl
        (fun acc rowInfo =>
          match rowInfo with
          | (rowIdx, row) =>
              if (rowIdx < minRow) || (rowIdx > maxRow) then
                acc
              else
                (enumerateArray row).foldl
                  (fun inner cellInfo =>
                    match cellInfo with
                    | (colIdx, cell) =>
                        if (colIdx < minCol) || (colIdx > maxCol) then
                          inner
                        else if cell == target then
                          setCell inner rowIdx colIdx replacement
                        else
                          inner)
                  acc)
        grid

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

private def rowIsZero (row : Array Cell) : Bool :=
  row.all (fun cell => cell == Cell.C0)

private def repeatPatternRows (grid : Grid) : Grid :=
  match grid[0]? with
  | none => grid
  | some patternRow =>
      let width := patternRow.size
      if width == 0 then
        grid
      else
        let rec loop : List (Nat × Array Cell) → Nat → Grid → Grid
          | [], _, acc => acc
          | (rowIdx, row) :: rest, colorIdx, acc =>
              if rowIsZero row then
                let patternIdx := colorIdx % width
                match patternRow[patternIdx]? with
                | some color =>
                    let newRow := Array.replicate row.size color
                    let acc := acc.set! rowIdx newRow
                    loop rest (colorIdx + 1) acc
                | none => loop rest colorIdx acc
              else
                loop rest colorIdx acc
        loop (enumerateArray grid) 0 grid

/-- Replace zero rows with uniform rows that cycle through the colors of the first row. -/
def repeatPatternRowsTransform : Transform Grid Grid :=
  { name := "repeat-pattern-rows"
  , apply := fun grid => pure <| repeatPatternRows grid }

private def cellAtInt (grid : Grid) (row col : Int) : Cell :=
  if (row < 0) || (col < 0) then
    Cell.C0
  else
    let rowNat := Int.toNat row
    let colNat := Int.toNat col
    cellAt grid rowNat colNat

private def neighborhood3x3 (grid : Grid) (rowIdx colIdx : Nat) : Grid :=
  let baseRow : Int := Int.ofNat rowIdx
  let baseCol : Int := Int.ofNat colIdx
  let offsets : List Int := [-1, 0, 1]
  Array.mk <|
    offsets.map fun dr =>
      Array.mk <|
        offsets.map fun dc =>
          let targetRow := baseRow + dr
          let targetCol := baseCol + dc
          cellAtInt grid targetRow targetCol

private def majorityColorInPatch (patch : Grid) : Option Cell :=
  let counts :=
    patch.toList.foldl
      (fun acc row =>
        row.toList.foldl
          (fun acc cell =>
            if (cell == Cell.C0) || (cell == Cell.C8) then
              acc
            else
              incrementCount acc cell)
          acc)
      []
  match maxCount counts with
  | some (color, _) => some color
  | none => none

private def extractEightNeighborhood (grid : Grid) : Grid :=
  match findCellPosition grid Cell.C8 with
  | none => grid
  | some (rowIdx, colIdx) =>
      let patch := neighborhood3x3 grid rowIdx colIdx
      let replacement :=
        match majorityColorInPatch patch with
        | some color => color
        | none => Cell.C0
      setCell patch 1 1 replacement

/-- Crop the 3×3 neighborhood around the unique 8 and replace the centre with the surrounding dominant colour. -/
def extractEightNeighborhoodTransform : Transform Grid Grid :=
  { name := "extract-eight-neighborhood"
  , apply := fun grid => pure <| extractEightNeighborhood grid }

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

/-- Recolour each component of `target` that contains a cycle so that it becomes `replacement`. -/
def recolorCyclicComponentsTransform (target replacement : Cell) : Transform Grid Grid :=
  { name := "recolor-cyclic-components"
  , apply := fun grid => pure <| recolorCyclicComponents grid target replacement }

/-- Recolour every `target` cell that is orthogonally adjacent to an `anchor` cell. -/
def recolorAdjacentCellsTransform (target anchor replacement : Cell) : Transform Grid Grid :=
  { name := "recolor-adjacent-cells"
  , apply := fun grid => pure <| recolorAdjacentCells grid target anchor replacement }

/-- Crop a grid down to the bounding box that covers all non-zero cells. -/
def cropBoundingBoxTransform : Transform Grid Grid :=
  { name := "crop-bbox"
  , apply := fun grid => pure <| cropBoundingBox grid }

private def divisors (n : Nat) : List Nat :=
  (List.range (n + 1)).filter fun p => (p > 0) && (n % p == 0)

private def rowsRepeatWithPeriod (grid : Grid) (period : Nat) : Bool :=
  let height := grid.size
  (List.range height).all fun rowIdx =>
    match grid[rowIdx]? with
    | none => False
    | some row =>
        match grid[rowIdx % period]? with
        | none => False
        | some ref => row.toList == ref.toList

private def gridRowPeriod (grid : Grid) : Nat :=
  let height := grid.size
  match divisors height |>.find? (rowsRepeatWithPeriod grid) with
  | some period => period
  | none => height

private def columnsRepeatWithPeriod (grid : Grid) (period : Nat) : Bool :=
  let height := grid.size
  (List.range height).all fun rowIdx =>
    match grid[rowIdx]? with
    | none => False
    | some row =>
        let width := row.size
        (List.range width).all fun colIdx =>
          match row[colIdx]? , row[colIdx % period]? with
          | some cell, some ref => cell == ref
          | _, _ => False

private def gridColumnPeriod (grid : Grid) : Nat :=
  let width :=
    match grid[0]? with
    | none => 0
    | some row => row.size
  match divisors width |>.find? (columnsRepeatWithPeriod grid) with
  | some period => period
  | none => width

private def extractTile (grid : Grid) (rows cols : Nat) : Grid :=
  let rowIndices := List.range rows
  Array.mk <|
    rowIndices.map fun rowIdx =>
      match grid[rowIdx]? with
      | none => Array.mk []
      | some row =>
          let colIndices := List.range cols
          Array.mk <|
            colIndices.map fun colIdx =>
              match row[colIdx]? with
              | some cell => cell
              | none => Cell.C0

private def fundamentalTile (grid : Grid) : Grid :=
  let rowPeriod := gridRowPeriod grid
  let colPeriod := gridColumnPeriod grid
  if rowPeriod == 0 || colPeriod == 0 then
    grid
  else
    extractTile grid rowPeriod colPeriod

/-- Extract the minimal tile that repeats to form the grid. -/
def fundamentalTileTransform : Transform Grid Grid :=
  { name := "fundamental-tile"
  , apply := fun grid => pure <| fundamentalTile grid }

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

private def fillDiagonalSegment (grid : Grid)
    (startRow startCol endRow endCol : Nat) (color : Cell) : Grid :=
  let row1 : Int := Int.ofNat startRow
  let col1 : Int := Int.ofNat startCol
  let row2 : Int := Int.ofNat endRow
  let col2 : Int := Int.ofNat endCol
  let dRow := row2 - row1
  let dCol := col2 - col1
  let absRow := Int.natAbs dRow
  let absCol := Int.natAbs dCol
  if absRow == 0 && absCol == 0 then
    grid
  else if absRow != absCol then
    grid
  else
    let stepRow : Int := if dRow ≥ 0 then 1 else -1
    let stepCol : Int := if dCol ≥ 0 then 1 else -1
    let steps := absRow
    let offsets := List.range (steps + 1)
    offsets.foldl
      (fun acc offset =>
        let offsetInt : Int := Int.ofNat offset
        let row := row1 + offsetInt * stepRow
        let col := col1 + offsetInt * stepCol
        if (row < 0) || (col < 0) then
          acc
        else
          let rowNat := Int.toNat row
          let colNat := Int.toNat col
          match acc[rowNat]? with
          | none => acc
          | some rowArr =>
              match rowArr[colNat]? with
              | none => acc
              | some existing =>
                  if existing == Cell.C0 then
                    paintIfZero acc rowNat colNat color
                  else
                    acc)
      grid

private def collectColorCoords
    (grid : Grid) : List (Cell × List (Nat × Nat)) :=
  let pushCoord
      (acc : List (Cell × List (Nat × Nat)))
      (color : Cell)
      (coord : Nat × Nat) : List (Cell × List (Nat × Nat)) :=
    let rec go : List (Cell × List (Nat × Nat)) → List (Cell × List (Nat × Nat))
      | [] => [(color, [coord])]
      | (c, coords) :: rest =>
          if c == color then
            (c, coord :: coords) :: rest
          else
            (c, coords) :: go rest
    go acc
  (enumerateArray grid).foldl
    (fun outerAcc entry =>
      match entry with
      | (rowIdx, row) =>
          (enumerateArray row).foldl
            (fun innerAcc cellEntry =>
              match cellEntry with
              | (colIdx, cell) =>
                  if cell == Cell.C0 then
                    innerAcc
                  else
                    pushCoord innerAcc cell (rowIdx, colIdx))
            outerAcc)
    []

private def fillDiagonalsForColor (grid : Grid)
    (color : Cell) (coords : List (Nat × Nat)) : Grid :=
  let rec loop : List (Nat × Nat) → Grid → Grid
    | [], acc => acc
    | coord :: rest, acc =>
        let acc :=
          rest.foldl
            (fun inner other =>
              match coord, other with
              | (sr, sc), (er, ec) => fillDiagonalSegment inner sr sc er ec color)
            acc
        loop rest acc
  loop coords grid

private def fillDiagonalSegments (grid : Grid) : Grid :=
  (collectColorCoords grid).foldl
    (fun acc entry =>
      match entry with
      | (color, coords) => fillDiagonalsForColor acc color coords)
    grid

def fillDiagonalSegmentsTransform : Transform Grid Grid :=
  { name := "fill-diagonal-segments"
  , apply := fun grid => pure <| fillDiagonalSegments grid }

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

private def boundingBoxExcludingColor (grid : Grid) (ignore : Cell)
    : Option (Nat × Nat × Nat × Nat) :=
  let updateForCell
      (acc : Option (Nat × Nat × Nat × Nat))
      (rowIdx : Nat)
      (colIdx : Nat)
      (cell : Cell)
      : Option (Nat × Nat × Nat × Nat) :=
    if (cell == Cell.C0) || (cell == ignore) then
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
          (fun inner cellInfo =>
            match cellInfo with
            | (colIdx, cell) => updateForCell inner rowIdx colIdx cell)
          acc
          (enumerateArray row)
  List.foldl updateForRow none (enumerateArray grid)

private def collectRelativeShapeCells (grid : Grid)
    (minRow maxRow minCol maxCol : Nat) (ignore : Cell)
    : List (Nat × Nat × Cell) :=
  let height := maxRow + 1 - minRow
  let width := maxCol + 1 - minCol
  let rowIndices := List.range height
  rowIndices.foldr
    (fun relRow acc =>
      let rowIdx := minRow + relRow
      match grid[rowIdx]? with
      | none => acc
      | some row =>
          let colIndices := List.range width
          colIndices.foldr
            (fun relCol inner =>
              let colIdx := minCol + relCol
              match row[colIdx]? with
              | some cell =>
                  if (cell == Cell.C0) || (cell == ignore) then
                    inner
                  else
                    (relRow, relCol, cell) :: inner
              | none => inner)
            acc)
    []

private def copyShapeToAnchor (grid : Grid) : Grid :=
  match findCellPosition grid Cell.C5 with
  | none => grid
  | some (anchorRow, anchorCol) =>
      match boundingBoxExcludingColor grid Cell.C5 with
      | none => grid
      | some (minRow, maxRow, minCol, maxCol) =>
          let height := maxRow + 1 - minRow
          let width := maxCol + 1 - minCol
          if height == 0 || width == 0 then
            grid
          else
            let rowOffset := if height ≤ 1 then 0 else 1
            let colOffset := if width ≤ 1 then 0 else 1
            if (anchorRow < rowOffset) || (anchorCol < colOffset) then
              grid
            else
              let topRow := anchorRow - rowOffset
              let topCol := anchorCol - colOffset
              let gridHeightVal := gridHeight grid
              let gridWidthVal := gridWidth grid
              if (topRow + height > gridHeightVal) || (topCol + width > gridWidthVal) then
                grid
              else
                let cells := collectRelativeShapeCells grid minRow maxRow minCol maxCol Cell.C5
                cells.foldl
                  (fun acc entry =>
                    match entry with
                    | (relRow, relCol, color) =>
                        setCell acc (topRow + relRow) (topCol + relCol) color)
                  grid

/-- Duplicate the primary pattern so that it overlays the anchor cell coloured 5. -/
def copyShapeToAnchorTransform : Transform Grid Grid :=
  { name := "copy-shape-to-anchor"
  , apply := fun grid => pure <| copyShapeToAnchor grid }

private def overlayAnchorNeighborhoods (grid : Grid) : Grid :=
  -- Find all cells with value 5 (anchors)
  let anchors :=
    concatMap (enumerateArray grid) fun rowInfo =>
      match rowInfo with
      | (rowIdx, row) =>
          concatMap (enumerateArray row) fun cellInfo =>
            match cellInfo with
            | (colIdx, cell) =>
                if cell == Cell.C5 then
                  [(rowIdx, colIdx)]
                else
                  []

  -- Initialize 3×3 output with 5 at center
  let output := Array.mk [
    Array.mk [Cell.C0, Cell.C0, Cell.C0],
    Array.mk [Cell.C0, Cell.C5, Cell.C0],
    Array.mk [Cell.C0, Cell.C0, Cell.C0]
  ]

  -- For each anchor, overlay its neighborhood onto the output
  anchors.foldl
    (fun acc anchor =>
      match anchor with
      | (anchorRow, anchorCol) =>
          -- Iterate over 3×3 neighborhood of this anchor
          let offsets : List (Int × Int) := [(-1, -1), (-1, 0), (-1, 1),
                                              (0, -1),  (0, 0),  (0, 1),
                                              (1, -1),  (1, 0),  (1, 1)]
          offsets.foldl
            (fun innerAcc offset =>
              match offset with
              | (dr, dc) =>
                  let inputRow : Int := Int.ofNat anchorRow + dr
                  let inputCol : Int := Int.ofNat anchorCol + dc
                  let outputRow : Int := 1 + dr
                  let outputCol : Int := 1 + dc

                  if (inputRow < 0) || (inputCol < 0) ||
                     (outputRow < 0) || (outputCol < 0) ||
                     (outputRow ≥ 3) || (outputCol ≥ 3) then
                    innerAcc
                  else
                    let inR := Int.toNat inputRow
                    let inC := Int.toNat inputCol
                    let outR := Int.toNat outputRow
                    let outC := Int.toNat outputCol

                    -- Get value from input
                    let inputVal := cellAt grid inR inC

                    -- Only place non-zero, non-5 values if output is currently 0
                    if (inputVal != Cell.C0) && (inputVal != Cell.C5) then
                      let currentVal := cellAt innerAcc outR outC
                      if currentVal == Cell.C0 then
                        setCell innerAcc outR outC inputVal
                      else
                        innerAcc
                    else
                      innerAcc)
            acc)
    output

/-- Find all cells with color 5 (anchors), collect their 3×3 neighborhoods,
and overlay them into a single 3×3 output grid with 5 at the center. -/
def overlayAnchorNeighborhoodsTransform : Transform Grid Grid :=
  { name := "overlay-anchor-neighborhoods"
  , apply := fun grid => pure <| overlayAnchorNeighborhoods grid }

private def countCellsByColor (grid : Grid) : List (Cell × Nat) :=
  (enumerateArray grid).foldl
    (fun acc rowInfo =>
      match rowInfo with
      | (_, row) =>
          (enumerateArray row).foldl
            (fun innerAcc cellInfo =>
              match cellInfo with
              | (_, cell) =>
                  if cell == Cell.C0 then
                    innerAcc
                  else
                    incrementCount innerAcc cell)
            acc)
    []

private def findMostFrequentColor (grid : Grid) : Option Cell :=
  let counts := countCellsByColor grid
  match maxCount counts with
  | none => none
  | some (color, _) => some color

private def extractMostFrequentColorBoundingBox (grid : Grid) : Grid :=
  match findMostFrequentColor grid with
  | none => grid
  | some targetColor =>
      match boundingBoxForColor grid targetColor with
      | none => grid
      | some (minRow, maxRow, minCol, maxCol) =>
          let height := maxRow + 1 - minRow
          let width := maxCol + 1 - minCol
          let rows := List.range height
          let cols := List.range width
          Array.mk <|
            rows.map fun rowOffset =>
              let rowIdx := minRow + rowOffset
              Array.mk <|
                cols.map fun colOffset =>
                  let colIdx := minCol + colOffset
                  cellAt grid rowIdx colIdx

/-- Extract the bounding box region of the most frequently occurring non-zero color. -/
def extractMostFrequentColorBoundingBoxTransform : Transform Grid Grid :=
  { name := "extract-most-frequent-color-bbox"
  , apply := fun grid => pure <| extractMostFrequentColorBoundingBox grid }

private def countOnesInGrid (grid : Grid) : Nat :=
  (enumerateArray grid).foldl
    (fun acc rowInfo =>
      match rowInfo with
      | (_, row) =>
          (enumerateArray row).foldl
            (fun innerAcc cellInfo =>
              match cellInfo with
              | (_, cell) =>
                  if cell == Cell.C1 then
                    innerAcc + 1
                  else
                    innerAcc)
            acc)
    0

private def countOnesAndPlaceTwos (grid : Grid) : Grid :=
  let count := countOnesInGrid grid

  -- Create 3x3 output grid
  let emptyRow := Array.mk [Cell.C0, Cell.C0, Cell.C0]
  let output := Array.mk [emptyRow, emptyRow, emptyRow]

  -- Positions to place 2s: (0,0), (0,1), (0,2), (1,1)
  let positions : List (Nat × Nat) := [(0, 0), (0, 1), (0, 2), (1, 1)]

  -- Place 2s in the specified positions
  let rec placeTwos (pos : List (Nat × Nat)) (remaining : Nat) (acc : Grid) : Grid :=
    match pos, remaining with
    | _, 0 => acc
    | [], _ => acc
    | (r, c) :: rest, Nat.succ n =>
        let acc := setCell acc r c Cell.C2
        placeTwos rest n acc

  placeTwos positions count output

/-- Count cells with value 1 and place that many 2s in positions (0,0), (0,1), (0,2), (1,1). -/
def countOnesAndPlaceTwosTransform : Transform Grid Grid :=
  { name := "count-ones-place-twos"
  , apply := fun grid => pure <| countOnesAndPlaceTwos grid }

end CogitoCore.ARC.Transformations
