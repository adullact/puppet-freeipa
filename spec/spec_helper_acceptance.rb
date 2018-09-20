require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

# PUPPET_INSTALL_VERSION = 5+

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-concat')
      on host, puppet('module', 'install', 'puppetlabs-stdlib')
      on host, puppet('module', 'install', 'crayfishx-firewalld')
      on host, puppet('module', 'install', 'puppet-selinux')

      pp = <<-EOS
        exec { 'stop network manager':
          command => 'systemctl stop NetworkManager',
          onlyif  => 'systemctl status NetworkManager',
          path    => '/usr/bin:/sbin:/bin'
        }
        EOS

      apply_manifest_on(host, pp, catch_failures: true)

      ## Preconfigure master
      pp = <<-EOS
        exec { 'set master /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       ipa-server-1.vagrant.example.lan ipa-server-1\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 192.168.44.35 ipa-server-1.vagrant.example.lan ipa-server-1\n" > /etc/hosts',
        }
        EOS

      apply_manifest(pp, catch_failures: true, debug: true)
    end
  end
end
