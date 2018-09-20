# A description of what this class does
# Install sssd package
#
# @summary A short summary of the purpose of this class
#
# @example
#   include freeipa::install::sssd
class freeipa::install::sssd {

  package { $freeipa::sssd_package_name:
    ensure => present,
  }

}
