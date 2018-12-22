#
# @summary Flushcache sss for Debian and RedHat only
#
# @example
#   include freeipa::helpers::flushcache
#
class freeipa::helpers::flushcache {

  #TODO: nscd should be called on both platforms.
  case $facts['os']['family'] {
    'RedHat': {
      $ipa_fluch_cache_cmd = "\
if [ -x /usr/sbin/sss_cache ]; then \
  /usr/sbin/sss_cache -UGNA >/dev/null 2>&1 ; \
else \
  /usr/bin/find /var/lib/sss/db -type f -exec rm -f \"{}\" ; ; \
fi"
    }
    'Debian': {
      $ipa_fluch_cache_cmd = "\
if [ -x /usr/sbin/nscd ]; then \
  /usr/sbin/nscd -i passwd -i group -i netgroup -i automount >/dev/null 2>&1 ; \
elif [ -x /usr/sbin/sss_cache ]; then \
  /usr/sbin/sss_cache -UGNA >/dev/null 2>&1 ; \
else \
  /usr/bin/find /var/lib/sss/db -type f -exec rm -f \"{}\" ; ; \
fi"
    }
    default: {
      fail('The class freeipa::flushcache is only written for RedHat and Debian.')
    }
  }

  exec { "ipa_flushcache_${freeipa::ipa_server_fqdn}":
    command     => "/bin/bash -c ${ipa_fluch_cache_cmd}",
    returns     => ['0','1','2'],
    notify      => Service['sssd'],
    refreshonly => true,
  }

}
