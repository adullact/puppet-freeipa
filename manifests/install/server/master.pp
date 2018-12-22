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
  --admin-password='${freeipa::puppet_admin_password}' \
  --ds-password='${freeipa::directory_services_password}' \
  ${freeipa::install::server::server_install_cmd_opts_setup_dns} \
  ${freeipa::install::server::server_install_cmd_opts_forwarders} \
  ${freeipa::install::server::server_install_cmd_opts_ip_address} \
  ${freeipa::install::server::server_install_cmd_opts_no_ntp} \
  ${freeipa::install::server::server_install_cmd_opts_idstart} \
  ${freeipa::install::server::server_install_cmd_opts_no_ui_redirect} \
  --unattended"

  if ! $facts['iparole'] or $facts['iparole'] == 'master' {
    file { '/etc/ipa/primary':
      ensure  => 'file',
      content => 'Added by IPA Puppet module. Designates primary master. Do not remove.',
    }
    -> exec { "server_install_${freeipa::ipa_server_fqdn}":
      command   => $server_install_cmd,
      timeout   => 0,
      unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
      creates   => '/etc/ipa/default.conf',
      logoutput => 'on_failure',
      notify    => Class['Freeipa::Helpers::Flushcache'],
      before    => Service['sssd'],
    }
    -> cron { 'k5start_root': #allows scp to replicas as root
      command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
      user    => 'root',
      minute  => '*/1',
      require => Package[$freeipa::kstart_package_name],
    }

  } else {
    fail ("to change ipa_role from '${facts['iparole']}' to 'master' is not supported.")
  }
}
