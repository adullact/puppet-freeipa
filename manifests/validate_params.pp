# A description of what this class does
# Validates input configs from init.pp.
#
# @summary Validates input configs from init.pp.
#
# @example
#   include freeipa::validate_params
class freeipa::validate_params {

  case $freeipa::ipa_role {
    'client': {}
    'master': {}
    'replica': {}
    default: {fail('The parameter ipa_role must be set to client, master, or replica.')}
  }

  if $freeipa::ip_address != '' {
    # TODO: validate_legacy
    if !is_ipv4_address($freeipa::ip_address) {
      fail('The parameter ip_address must pass validation as an IPv4 address.')
    }
  }

  if $freeipa::manage_host_entry {
    if $freeipa::ip_address  == '' {
      fail('When using the parameter manage_host_entry, the parameter ip_address is mandatory.')
    }
  }

  if $freeipa::idstart < 10000 {
    fail('Parameter "idstart" must be an integer greater than 10000.')
  }

  # TODO: validate_legacy
  if ! is_domain_name($freeipa::domain) {
    fail('The parameter \'domain\' must pass validation as a domain name.')
  }

  # TODO: validate_legacy
  if ! is_domain_name($freeipa::final_realm) {
    fail('The parameter \'realm\' must pass validation as a domain name.')
  }

  if $freeipa::ipa_role == 'master' {
    if length($freeipa::admin_password) < 8 {
      fail('When ipa_role is set to master, the parameter admin_password must be populated and at least of length 8.')
    }

    if length($freeipa::directory_services_password) < 8 {
      fail("\
When ipa_role is set to master, the parameter directory_services_password \
must be populated and at least of length 8."
      )
    }
  }

  if $freeipa::ipa_role != 'master' { # if replica or client

    # TODO: validate_legacy
    if $freeipa::ipa_master_fqdn == ''{
      fail("When creating a ${freeipa::ipa_role} the parameter named ipa_master_fqdn cannot be empty.")
    } elsif !is_domain_name($freeipa::ipa_master_fqdn) {
      fail('The parameter \'ipa_master_fqdn\' must pass validation as a domain name.')
    }

    if $freeipa::final_domain_join_password == '' {
      fail("When creating a ${freeipa::ipa_role} the parameter named domain_join_password cannot be empty.")
    }
  }
}
