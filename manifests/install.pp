#
class freeipa::install {

  if $freeipa::install_epel {
    ensure_resource(
      'package',
      'epel-release',
      {'ensure' => 'present'},
    )
  }

  if $freeipa::manage_host_entry {
    host { $freeipa::ipa_server_fqdn:
      ip => $freeipa::ip_address,
    }
  }

  # Note: sssd.conf handled by ipa-server-install.
  if $freeipa::install_sssd {
    contain 'freeipa::install::sssd'
  }

  if $freeipa::install_autofs {
    contain 'freeipa::install::autofs'
  }

  if $freeipa::install_sssdtools {
    package { $freeipa::sssdtools_package_name:
      ensure => present,
    }
  }

  case $freeipa::ipa_role {
    'client': {
       if $freeipa::install_ipa_client {
         contain 'freeipa::install::client'
       }
    }
    default: {
      if $freeipa::final_configure_dns_server {
        $dns_packages = [
          'ipa-server-dns',
          'bind-dyndb-ldap',
        ]
        package{$dns_packages:
          ensure => present,
        }
      }

      if $freeipa::install_ipa_server {
        contain 'freeipa::install::server'
      }
    }
  }

}
