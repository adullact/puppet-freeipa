# A description of what this class does
# Installs and start autofs
# @summary A short summary of the purpose of this class
#
# @example
#   include freeipa::install::autofs
class freeipa::install::autofs {
  package { $freeipa::autofs_package_name:
    ensure => present,
  }

  service { 'autofs':
    ensure => 'running',
    enable => true,
  }
}
