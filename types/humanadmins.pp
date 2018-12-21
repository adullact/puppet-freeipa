type Freeipa::Humanadmins = Hash[
  String[1],
  Struct[{
    password         => String[1],
    Optional[ensure] => Enum['present','absent'],
  }],
]
