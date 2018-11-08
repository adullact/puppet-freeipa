# A description of what this class does
# Manages IPA masters, replicas and clients.
#
# @summary Manages IPA masters, replicas and clients.
# @example
#   include freeipa
#
# Parameters
# ----------
# @param domain The name of the IPA domain to create or join.
# @param ipa_role What role the node will be. Options are 'master', 'replica', and 'client'.
# @param admin_password Password which will be assigned to the IPA account named 'admin'.
# @param directory_services_password Password which will be passed into the ipa setup's parameter named "--ds-password".
# @param autofs_package_name Name of the autofs package to install if enabled.
# @param client_install_ldaputils If true, then the ldaputils packages are installed if ipa_role is set to client.
# @param configure_dns_server If true, then the parameter '--setup-dns' is passed to the IPA server installer. 
# Also, triggers the install of the required dns server packages.
# @param configure_ntp If false, then the parameter '--no-ntp' is passed to the IPA server installer.
# @param custom_dns_forwarders Each element in this array is prefixed with '--forwarder' and passed to the IPA server installer.
# @param principal_usedto_joindomain The principal (usually username) used to join a client or replica to the IPA domain.
# @param password_usedto_joindomain The password for the domain_join_principal.
# @param enable_hostname If true, then the parameter '--hostname' is populated with the parameter 'ipa_server_fqdn' 
# and passed to the IPA installer.
# @param enable_ip_address If true, then the parameter '--ip-address' is populated with the parameter 'ip_address' 
# and passed to the IPA installer.
# @param fixed_primary If true, then the parameter '--fixed-primary' is passed to the IPA installer.
# @param idstart From the IPA man pages: "The starting user and group id number".
# @param install_autofs If true, then the autofs packages are installed.
# @param install_epel If true, then the epel repo is installed. The epel repo is usually required for sssd packages.
# @param install_kstart If true, then the kstart packages are installed.
# @param install_sssdtools If true, then the sssdtools packages are installed.
# @param ipa_client_package_name Name of the IPA client package.
# @param ipa_server_package_name Name of the IPA server package.
# @param install_ipa_client If true, then the IPA client packages are installed if the parameter 'ipa_role' is set to 'client'.
# @param install_ipa_server If true, then the IPA server packages are installed if the parameter 'ipa_role' is not set to 'client'.
# @param install_sssd If true, then the sssd packages are installed.
# @param ip_address IP address to pass to the IPA installer.
# @param ipa_server_fqdn Actual fqdn of the IPA server or client.
# @param kstart_package_name Name of the kstart package.
# @param ldaputils_package_name Name of the ldaputils package.
# @param ipa_master_fqdn FQDN of the server to use for a client or replica domain join.
# @param manage_host_entry If true, then a host entry is created using the parameters 'ipa_server_fqdn' and 'ip_address'.
# @param mkhomedir If true, then the parameter '--mkhomedir' is passed to the IPA client installer.
# @param no_ui_redirect If true, then the parameter '--no-ui-redirect' is passed to the IPA server installer.
# @param realm The name of the IPA realm to create or join.
# @param server_install_ldaputils If true, then the ldaputils packages are installed if ipa_role is not set to client.
# @param sssd_package_name Name of the sssd package.
# @param sssdtools_package_name Name of the sssdtools package.
# @param webui_disable_kerberos If true, then /etc/httpd/conf.d/ipa.conf is written to exclude kerberos support for incoming 
# requests whose HTTP_HOST variable match the parameter 'webio_proxy_external_fqdn'. This allows the IPA Web UI to work on a 
# proxied port, while allowing IPA client access to  function as normal.
# @param webui_enable_proxy If true, then httpd is configured to act as a reverse proxy for the IPA Web UI. This allows 
# the Web UI to be accessed from different ports and hostnames than the default.
# @param webui_force_https If true, then /etc/httpd/conf.d/ipa-rewrite.conf is modified to force all connections to https. 
# This is necessary to allow the WebUI to be accessed behind a reverse proxy when using nonstandard ports.
# @param webui_proxy_external_fqdn The public or external FQDN used to access the IPA Web UI behind the reverse proxy.
# @param webui_proxy_https_port The HTTPS port to use for the reverse proxy. Cannot be 443.
#
#
class freeipa (
  Stdlib::Fqdn                             $domain,
  Enum['master','replica','client']        $ipa_role,
  String[8]                                $admin_password,
  String[8]                                $directory_services_password,
  Stdlib::IP::Address::V4                  $ip_address,
  Stdlib::Fqdn                             $ipa_master_fqdn,
  Stdlib::Fqdn                             $realm                              = upcase($domain),
  String                                   $autofs_package_name                = 'autofs',
  Boolean                                  $client_install_ldaputils           = false,
  Boolean                                  $configure_dns_server               = true,
  Boolean                                  $configure_ntp                      = true,
  Array[String]                            $custom_dns_forwarders              = [],
  String                                   $principal_usedto_joindomain        = 'admin',
  String                                   $password_usedto_joindomain         = $directory_services_password,
  Boolean                                  $enable_hostname                    = true,
  Boolean                                  $enable_ip_address                  = false,
  Boolean                                  $fixed_primary                      = false,
  Integer[10000]                           $idstart                            = 10000,
  Boolean                                  $install_autofs                     = false,
  Boolean                                  $install_epel                       = true,
  Boolean                                  $install_kstart                     = true,
  Boolean                                  $install_sssdtools                  = true,
  String                                   $ipa_client_package_name            = $facts['os']['family'] ? {
    'Debian' => 'freeipa-client',
    default  => 'ipa-client',
  },
  String                                   $ipa_server_package_name            = 'ipa-server',
  Boolean                                  $install_ipa_client                 = true,
  Boolean                                  $install_ipa_server                 = true,
  Boolean                                  $install_sssd                       = true,
  Stdlib::Fqdn                             $ipa_server_fqdn                    = $facts['fqdn'],
  String                                   $kstart_package_name                = 'kstart',
  String                                   $ldaputils_package_name             = $facts['os']['family'] ? {
    'Debian' => 'ldap-utils',
    default  => 'openldap-clients',
  },
  Boolean                                  $manage_host_entry                  = false,
  Boolean                                  $mkhomedir                          = true,
  Boolean                                  $no_ui_redirect                     = false,
  Boolean                                  $server_install_ldaputils           = true,
  String                                   $sssd_package_name                  = 'sssd-common',
  String                                   $sssdtools_package_name             = 'sssd-tools',
  Boolean                                  $webui_disable_kerberos             = false,
  Boolean                                  $webui_enable_proxy                 = false,
  Boolean                                  $webui_force_https                  = false,
  Stdlib::Fqdn                             $webui_proxy_external_fqdn          = 'localhost',
  String                                   $webui_proxy_https_port             = '8440',
) {

  if $facts['kernel'] != 'Linux' or $facts['osfamily'] == 'Windows' {
    fail('This module is only supported on Linux.')
  }

  $master_principals = suffix(
    prefix(
      [$ipa_server_fqdn],
      'host/'
    ),
    "@${realm}"
  )

  if $ipa_role == 'client' {
    $final_configure_dns_server = false
  } else {
    $final_configure_dns_server = $configure_dns_server
  }

  class {'::freeipa::install':}

}

