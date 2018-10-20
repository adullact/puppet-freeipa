require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
install_module_on(hosts)

# The module saz-resolv_conf, used by this helper, requires puppetlabs-stdlibs < 5.0.0.
# The puppet-freeipa dependencies descrived by metadata.json installs puppetlabs-stdlib > 5.0.0.
# It is prefered, for the moment, to not use the helping function
# install_module_dependencies_on() until saz-resolv_conf accepts puppetlabs-stdlib > 5.0.0
#
# By this way, users of puppet-freeipa can use puppetlabs-stdlibs version > 5.0.0.
# and acceptance tests can use puppetlabs-stdlibs version < 5.0.0
#install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      install_module_from_forge_on(host, 'saz-resolv_conf', '>= 4.0.0 < 5.0.0')
      install_module_from_forge_on(host, 'puppetlabs-stdlib', '>= 4.25.0 < 5.0.0')
      install_module_from_forge_on(host, 'stahnma-epel', '>= 1.3.1 < 2.0.0')

      pp = <<-EOS
        exec { 'stop network manager':
          command => 'systemctl stop NetworkManager',
          onlyif  => 'systemctl status NetworkManager',
          path    => '/usr/bin:/sbin:/bin',
        }
      EOS

      apply_manifest_on(host, pp, catch_failures: true)

      yumipv4 = <<-EOS
        exec {'echo "ip_resolve=4" >> /etc/yum.conf':
          onlyif => 'grep -v "^ip_resolve=4" /etc/yum.conf',
          path   => '/usr/bin:/sbin:/bin',
        }
      EOS
      apply_manifest_on(host, yumipv4, catch_failures: true) if fact('os.family') == 'RedHat'

    end

    ## Preconfigure master
    hosts_as('master').each do |master|
      pp = <<-EOS
        exec { 'set master /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       ipa-server-1.vagrant.example.lan ipa-server-1\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 192.168.44.35 ipa-server-1.vagrant.example.lan ipa-server-1\n" > /etc/hosts',
        }
        EOS

      apply_manifest_on(master, pp, catch_failures: true, debug: true)
    end

    ## Preconfigure replica
    hosts_as('replica').each do |replica|
      pp = <<-EOS
         exec { 'set replica /etc/hosts':
           path     => '/bin/',
           command  => 'echo -e "127.0.0.1       ipa-server-2.vagrant.example.lan ipa-server-2\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 192.168.44.36 ipa-server-2.vagrant.example.lan ipa-server-2\n" > /etc/hosts',
         }
         class { 'resolv_conf':
           nameservers => ['192.168.44.35'],
         }
         host {'ipa-server-1.vagrant.example.lan':
           ensure => present,
           ip => '192.168.44.35',
         }
      EOS

      apply_manifest_on(replica, pp, :catch_failures => true, :debug => true)
    end

    ## Preconfigure client
    hosts_as('centos7').each do |centos7|
      pp = <<-EOS
        exec { 'set client centos /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       ipa-client-centos.vagrant.example.lan ipa-server-2\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 192.168.44.37 ipa-client-centos.vagrant.example.lan ipa-client-centos\n" > /etc/hosts',
        }
        class { 'resolv_conf':
          nameservers => ['192.168.44.35'],
        }
        host {'ipa-server-1.vagrant.example.lan':
          ensure => present,
          ip => '192.168.44.35',
        }
      EOS

      apply_manifest_on(centos7, pp, catch_failures: true)
    end
  end
end
