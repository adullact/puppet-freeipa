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

  exec { 'set /etc/hosts':
    command => "echo -e \"127.0.0.1       localhost\n::1	localhost ip6-localhost ip6-loopback\nfe00::0	ip6-localnet\nff00::0	ip6-mcastprefix\nff02::1	ip6-allnodes\nff02::2	ip6-allrouters\n${freeipa::ip_address}    ${freeipa::hostname}.${freeipa::domain} ${freeipa::hostname}\" > /etc/hosts",
    path    => '/usr/local/bin/:/bin/:/sbin',
  }

  if $freeipa::ipa_role == 'master' {
    contain 'freeipa::install::server::master'
  } elsif $freeipa::ipa_role == 'replica' {
    contain 'freeipa::install::server::replica'
  }

  exec { 'semanage':
    command => 'semanage port -a -t http_port_t -p tcp 8440',
    path    => '/usr/local/bin/:/bin/:/sbin',
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
