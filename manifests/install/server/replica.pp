# 
# @summary Installs freeipa server as replica
#
# @example
#   include freeipa::install::server::replica
#
# @api private
#
class freeipa::install::server::replica {
  assert_private()

  $replica_install_cmd = "/usr/sbin/ipa-replica-install \
  --principal=${freeipa::principal_usedto_joindomain} \
  --admin-password='${freeipa::password_usedto_joindomain}' \
  ${freeipa::install::server::server_install_cmd_opts_hostname} \
  --realm=${freeipa::realm} \
  --domain=${freeipa::domain} \
  --server=${freeipa::ipa_master_fqdn} \
  ${freeipa::install::server::server_install_cmd_opts_setup_dns} \
  ${freeipa::install::server::server_install_cmd_opts_forwarders} \
  ${freeipa::install::server::server_install_cmd_opts_ip_address} \
  ${freeipa::install::server::server_install_cmd_opts_no_ntp} \
  ${freeipa::install::server::server_install_cmd_opts_no_ui_redirect} \
  ${freeipa::install::server::server_install_cmd_opts_setup_ca} \
  --unattended"

  if ! $facts['iparole'] or $facts['iparole'] == 'replica' {
    exec { "server_install_${freeipa::ipa_server_fqdn}":
      command   => $replica_install_cmd,
      timeout   => 0,
      unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
      creates   => '/etc/ipa/default.conf',
      logoutput => 'on_failure',
      notify    => Class['Freeipa::Helpers::Flushcache'],
      before    => Service['sssd'],
    }
  } else {
    fail ("to change ipa_role from '${facts['iparole']}' to 'replica' is not supported.")
  }
}
