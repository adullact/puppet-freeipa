# @summary This class manages admin accounts. It will create/give rights to any admin accounts missing. It will delete accounts set in Hiera to be deleted.
#
# @example
#   include freeipa::config::humanadmins
class freeipa::config::humanadmins {

  # Get domain in shape for ldappasswd
  $dc_domain_split = regsubst($freeipa::domain, '([^.]+)\.*', 'dc=\1,', 'G')
  $dc = regsubst($dc_domain_split, ',$', '')


  # Loop through $human_admins
  $freeipa::humanadmins.each | String $adminname, Hash[Enum['password','ensure'], String] $adminsettings | {
    $_ensure_admin = $adminsettings['ensure'] ? {
      Undef   => 'present',
      default => $adminsettings['ensure'],
    }
    case $_ensure_admin {
      'present': {
        exec { "Create ${adminname} account":
          command => "kinit admin -k -t /home/admin/admin.keytab; ipa user-add ${adminname} --first=${adminname} --last=${adminname} ",
          unless  => "ipa user-show ${adminname} | grep login",
        }
        -> exec { "Add ${adminname} account to admins group in FreeIPA":
          command => "kinit admin -k -t /home/admin/admin.keytab; ipa group-add-member admins --users=${adminname}",
          unless  => "ipa group-show admins | grep ${adminname}",
        }
        -> exec { "Update ${adminname} password":
          command => "ldappasswd -Z -H ldap://localhost -x -D \"cn=Directory Manager\" -w ${freeipa::directory_services_password} -s ${adminsettings['password']} \"uid=${adminname},cn=users,cn=accounts,${dc}\"",
          unless  => "echo \"${adminsettings['password']}\" | kinit ${adminname}"
        }
      }
      'absent': {
        exec { "Delete ${adminname} account":
          command => "kinit admin -k -t /home/admin/admin.keytab; ipa user-del ${adminname}",
          onlyif  => "kinit admin -k -t /home/admin/admin.keytab; ipa user-show ${adminname}",
        }
      }
      default: { fail("unexpected value ${adminsettings['ensure']}") }
    }
  }
}
