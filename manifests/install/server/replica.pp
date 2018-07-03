#
class freeipa::install::server::replica {
  $replica_install_cmd = "\
/usr/sbin/ipa-replica-install \
  --principal=${freeipa::final_domain_join_principal} \
  --admin-password='${freeipa::final_domain_join_password}' \
  ${freeipa::install::server::server_install_cmd_opts_hostname} \
  --realm=${freeipa::final_realm} \
  --domain=${freeipa::domain} \
  --server=${freeipa::ipa_master_fqdn} \
  ${freeipa::install::server::server_install_cmd_opts_setup_dns} \
  ${freeipa::install::server::server_install_cmd_opts_forwarders} \
  ${freeipa::install::server::server_install_cmd_opts_ip_address} \
  ${freeipa::install::server::server_install_cmd_opts_no_ntp} \
  ${freeipa::install::server::server_install_cmd_opts_no_ui_redirect} \
  --unattended"

  # TODO: config-show and grep for IPA\ masters
  file { '/etc/ipa/primary':
    ensure  => 'file',
    content => 'Added by IPA Puppet module. Designates primary master. Do not remove.',
  }
  -> exec { "server_install_${freeipa::ipa_server_fqdn}":
    command   => $replica_install_cmd,
    timeout   => 0,
    unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates   => '/etc/ipa/default.conf',
    logoutput => 'on_failure',
    notify    => Easy_ipa::Helpers::Flushcache["server_${freeipa::ipa_server_fqdn}"],
    before    => Service['sssd'],
  }
  -> cron { 'k5start_root':
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
    require => Package[$freeipa::kstart_package_name],
  }

}
