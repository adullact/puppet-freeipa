#
class freeipa::install::sssd {

  package { $freeipa::sssd_package_name:
    ensure => present,
  }

}
