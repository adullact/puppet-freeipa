#
# @summary Install sssd package
#
# @example
#   include freeipa::install::sssd
class freeipa::install::sssd {

  package { $freeipa::sssd_package_name:
    ensure => present,
  }

}
