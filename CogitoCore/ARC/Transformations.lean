import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Transformations


def gridIdentityTransform : Transform Grid Grid :=
  { name := s!"grid-id"
  , apply := fun input => pure input }

end CogitoCore.ARC.Transformations
