type Freeipa::Humanadmin = Struct[{
  Optional[password] => String[1],
  Optional[ensure]   => Enum['present','absent'],
}]
