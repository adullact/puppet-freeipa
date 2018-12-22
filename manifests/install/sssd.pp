#
# @summary Install sssd package
#
# @example
#   include freeipa::install::sssd
#
# @api private
#
class freeipa::install::sssd {
  assert_private()

  package { $freeipa::sssd_package_name:
    ensure => present,
  }

}
