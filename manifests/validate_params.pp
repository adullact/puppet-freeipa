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

  if $freeipa::manage_host_entry {
    if $freeipa::ip_address  == '0.0.0.0' {
      fail('When using the parameter manage_host_entry, the parameter ip_address is mandatory.')
    }
  }


  if $freeipa::idstart < 10000 {
    fail('Parameter "idstart" must be an integer greater than 10000.')
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

    if $freeipa::ipa_master_fqdn == 'default'{
      fail("When creating a ${freeipa::ipa_role} the parameter named ipa_master_fqdn must be set.")
    }

    if $freeipa::final_domain_join_password == '' {
      fail("When creating a ${freeipa::ipa_role} the parameter named domain_join_password cannot be empty.")
    }
  }
}
