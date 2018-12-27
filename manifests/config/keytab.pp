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

    $uid_number = $freeipa::idstart
    $home_dir_path = '/home/admin'

    # Ensure admin homedir and keytab files.
    file { $home_dir_path:
      ensure  => directory,
      mode    => '0700',
      owner   => $uid_number,
      group   => $uid_number,
      require => Exec["server_install_${freeipa::ipa_server_fqdn}"],
    }

    # Set keytab for admin user.
    $configure_admin_keytab_cmd = "/usr/sbin/kadmin.local -q \"ktadd -norandkey -k ${home_dir_path}/admin.keytab admin\" "
    exec { 'configure_admin_keytab':
      command => $configure_admin_keytab_cmd,
      cwd     => $home_dir_path,
      unless  => shellquote('/usr/bin/kvno','-k',"${home_dir_path}/admin.keytab","admin@${freeipa::realm}"),
      require => File[$home_dir_path],
      notify  => File["${home_dir_path}/admin.keytab"],
    }

    file { "${home_dir_path}/admin.keytab":
      owner   => $uid_number,
      group   => $uid_number,
      mode    => '0600',
      require => File[$home_dir_path],
    }
  } else {
    # manage keytab only on master
  }
}
