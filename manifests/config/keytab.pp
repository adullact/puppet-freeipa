#
# @summary Configures keytab for admin user on FreeIPA master. 
#
# @example
#   include freeipa::config::keytab
#
# @api private
#
class freeipa::config::keytab {
  assert_private()

  if $facts['iparole'] == 'master' or $freeipa::ipa_role == 'master' {

    $_uid_number = $freeipa::idstart
    $_home_dir_path = '/home/admin'
    $_admin_keytab = "${_home_dir_path}/admin.keytab"

    # Ensure admin homedir and keytab files.
    file { $_home_dir_path:
      ensure  => directory,
      mode    => '0700',
      owner   => $_uid_number,
      group   => $_uid_number,
      require => Exec["server_install_${freeipa::ipa_server_fqdn}"],
    }

    # Set keytab for admin user.
    exec { 'ktadd admin keytab':
      command => "/usr/sbin/kadmin.local -q \"ktadd -norandkey -k ${_admin_keytab} admin\"",
      cwd     => $_home_dir_path,
      unless  => "/usr/bin/kvno -k ${_admin_keytab} admin@${freeipa::realm}",
      require => File[$_home_dir_path],
      notify  => File[$_admin_keytab],
    }

    file { $_admin_keytab :
      owner   => $_uid_number,
      group   => $_uid_number,
      mode    => '0600',
      require => File[$_home_dir_path],
    }
  } else {
    # manage keytab only on master
  }
}
