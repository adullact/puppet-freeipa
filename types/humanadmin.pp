type Freeipa::Humanadmin = Struct[{
  password         => String[1],
  Optional[ensure] => Enum['present','absent'],
}]
