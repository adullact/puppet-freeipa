# @summary This class manages admin accounts. It will create/give rights to any admin accounts set to be present. It will delete accounts set to be absent.
#
# @example
#   class { 'freeipa::config::humanadmins' :
#     humanadmins => {
#       admin1 => {ensure=>'present', password=>'secreat123'},
#       admin2 => {ensure=>'absent'},
#     }
#   }
#
# @param humanadmins Hash defines desired admins of FreeIPA
#
class freeipa::config::humanadmins(
  Freeipa::Humanadmins $humanadmins,
) {

  # Loop through $humanadmins
  $humanadmins.each | String $_adminname, Freeipa::Humanadmin $_adminsettings | {
    freeipa::config::humanadmin { $_adminname :
      adminsettings =>  $_adminsettings,
    }
  }
}
