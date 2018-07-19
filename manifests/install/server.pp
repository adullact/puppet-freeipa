#
class freeipa::install::server {

  package{$freeipa::ipa_server_package_name:
    ensure => present,
  }

  package{$freeipa::kstart_package_name:
    ensure => present,
  }

  if $freeipa::server_install_ldaputils {
    package { $freeipa::ldaputils_package_name:
      ensure => present,
    }
  }

  $server_install_cmd_opts_idstart = "--idstart=${freeipa::idstart}"

  if $freeipa::enable_hostname {
    $server_install_cmd_opts_hostname = "--hostname=${freeipa::ipa_server_fqdn}"
  } else {
    $server_install_cmd_opts_hostname = ''
  }

  if $freeipa::enable_ip_address {
    $server_install_cmd_opts_ip_address = "--ip-address ${freeipa::ip_address}"
  } else {
    $server_install_cmd_opts_ip_address = ''
  }

  if $freeipa::final_configure_dns_server {
    $server_install_cmd_opts_setup_dns = '--setup-dns'
  } else {
    $server_install_cmd_opts_setup_dns = ''
  }

  if $freeipa::configure_ntp {
    $server_install_cmd_opts_no_ntp = ''
  } else {
    $server_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $freeipa::final_configure_dns_server {
    if size($freeipa::custom_dns_forwarders) > 0 {
      $server_install_cmd_opts_forwarders = join(
        prefix(
          $freeipa::custom_dns_forwarders,
          '--forwarder '),
        ' '
      )
    }
    else {
      $server_install_cmd_opts_forwarders = '--no-forwarders'
    }
  }
  else {
    $server_install_cmd_opts_forwarders = ''
  }

  if $freeipa::no_ui_redirect {
    $server_install_cmd_opts_no_ui_redirect = ''
  } else {
    $server_install_cmd_opts_no_ui_redirect = '--no-ui-redirect'
  }

  if $freeipa::ipa_role == 'master' {
    contain 'freeipa::install::server::master'
  } elsif $freeipa::ipa_role == 'replica' {
    contain 'freeipa::install::server::replica'
  }

  exec { 'semanage':
    command => 'semanage port -a -t http_port_t -p tcp 8440',
    path    => '/usr/local/bin/:/bin/:/sbin',
    # path    => [ '/usr/local/bin/', '/bin/' ],  # alternative syntax
  }

  ensure_resource (
    'service',
    'httpd',
    {ensure => 'running'},
  )

  contain 'freeipa::config::webui'

  service { 'ipa':
    ensure  => 'running',
    enable  => true,
    require => Exec["server_install_${freeipa::ipa_server_fqdn}"],
  }

  if $freeipa::install_sssd {
    service { 'sssd':
      ensure  => 'running',
      enable  => true,
      require => Package[$freeipa::sssd_package_name],
    }
  }

  freeipa::helpers::flushcache { "server_${freeipa::ipa_server_fqdn}": }
  class {'freeipa::config::admin_user': }

}
