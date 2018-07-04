#
class freeipa::install::autofs {
  package { $freeipa::autofs_package_name:
    ensure => present,
  }

  service { 'autofs':
    ensure => 'running',
    enable => true,
  }
}
