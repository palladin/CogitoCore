import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Transformations


def gridIdentityTransform : Transform (Grid rows cols) (Grid rows cols) :=
  { name := s!"grid-id-{rows}x{cols}"
  , apply := id }

end CogitoCore.ARC.Transformations
