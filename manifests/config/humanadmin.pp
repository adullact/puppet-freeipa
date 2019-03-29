# From FreeIPA master, creates or deletes admin account in FreeIPA.
#
# @summary From FreeIPA master, creates or deletes admin account in FreeIPA.
#
# @example
#   freeipa::config::humanadmin { 'myadmin' :
#     adminsettings => {
#       password => 'secret123',
#       ensure   =>  'present',
#     }
#   }
#
# @param adminsettings Hash of settings for one admin account
# @option adminsettings [Enum['present','absent']] :ensure Desired state
# @option adminsettings [String[1]] :password Password of this account
#
define freeipa::config::humanadmin(
  Freeipa::Humanadmin $adminsettings,
) {
  if $facts['iparole'] == 'master' or $freeipa::ipa_role == 'master' {
    $_adminname = $name

    # forge domain shaped for ldappasswd
    $_dc_domain_split = regsubst($freeipa::domain, '([^.]+)\.*', 'dc=\1,', 'G')
    $_dc = regsubst($_dc_domain_split, ',$', '')

    $_ensure = $adminsettings['ensure'] ? {
      Undef   =>  'present',
      default =>  $adminsettings['ensure'],
    }

    Exec {
        path    => '/usr/local/bin/:/bin/:/sbin',
    }

    case $_ensure {
      'present': {
        $_adminpassword = $adminsettings['password']

        exec { "ipa user-add ${_adminname}":
          command => "ipa user-add ${_adminname} --first=${_adminname} --last=${_adminname} ",
          unless  => "kinit admin -k -t /home/admin/admin.keytab; ipa user-show ${_adminname} | grep login",
        }
        -> exec { "ipa group-add-member admins --users=${_adminname}":
          command => "ipa group-add-member admins --users=${_adminname}",
          unless  => "kinit admin -k -t /home/admin/admin.keytab; ipa group-show admins | grep ${_adminname}",
        }
        -> exec { "ldappasswd uid=${_adminname},cn=users,cn=accounts,${_dc}":
          command => "ldappasswd -Z -H ldap://localhost -x -D 'cn=Directory Manager' -w '${freeipa::directory_services_password}' -s '${_adminpassword}' 'uid=${_adminname},cn=users,cn=accounts,${_dc}'",
          unless  => "echo '${_adminpassword}' | kinit ${_adminname}"
        }
      }
      'absent': {
        exec { "ipa user-del ${_adminname}":
          command => "ipa user-del ${_adminname}",
          onlyif  => "kinit admin -k -t /home/admin/admin.keytab; ipa user-show ${_adminname}",
        }
      }
      default: { fail("unexpected value ${_ensure}") }
    }
  } else {
    # manage accounts of human admins only on master
    # replication will do the job on replicate
  }
}
