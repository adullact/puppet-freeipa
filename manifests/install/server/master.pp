#
# @summary Installs freeipa server as master
#
# @example
#   include freeipa::install::server::master
#
# @api private
#
class freeipa::install::server::master {
  assert_private()

  $server_install_cmd = "\
/usr/sbin/ipa-server-install \
  ${freeipa::install::server::server_install_cmd_opts_hostname} \
  --realm=${freeipa::realm} \
  --domain=${freeipa::domain} \
  --admin-password=\"\$PUPPET_ADMIN_PASSWORD\" \
  --ds-password=\"\$DIRECTORY_SERVICES_PASSWORD\" \
  --ca-subject='${freeipa::ca_subject}' \
  ${freeipa::install::server::server_install_cmd_opts_setup_dns} \
  ${freeipa::install::server::server_install_cmd_opts_forwarders} \
  ${freeipa::install::server::server_install_cmd_opts_ip_address} \
  ${freeipa::install::server::server_install_cmd_opts_random_serial_numbers} \
  ${freeipa::install::server::server_install_cmd_opts_no_ntp} \
  ${freeipa::install::server::server_install_cmd_opts_idstart} \
  ${freeipa::install::server::server_install_cmd_opts_no_ui_redirect} \
  ${freeipa::install::server::server_install_cmd_opts_external_ca} \
  --unattended"

  if ! $facts['iparole'] or $facts['iparole'] == 'master' {
    exec { "server_install_${freeipa::ipa_server_fqdn}":
      environment => [
        "PUPPET_ADMIN_PASSWORD=${freeipa::puppet_admin_password.unwrap}",
        "DIRECTORY_SERVICES_PASSWORD=${freeipa::directory_services_password.unwrap}",
      ],
      command     => $server_install_cmd,
      timeout     => 0,
      unless      => '/usr/sbin/ipactl status >/dev/null 2>&1',
      creates     => '/etc/ipa/default.conf',
      logoutput   => 'on_failure',
      notify      => Class['Freeipa::Helpers::Flushcache'],
      before      => Service['sssd'],
      require     => Package[$freeipa::ipa_server_package_name],
    }
  } else {
    fail ("to change ipa_role from '${facts['iparole']}' to 'master' is not supported.")
  }
}
