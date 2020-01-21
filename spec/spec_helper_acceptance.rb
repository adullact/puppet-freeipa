require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

require 'bolt/pal'
Bolt::PAL.load_puppet

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

ip_master = fact_on('master', 'networking.interfaces.eth1.ip')

RSpec.configure do |c|
  c.before :suite do
    # Configure all nodes in nodeset
    hosts.each do |host|
      pp = <<-EOS
        exec { 'stop network manager':
          command => 'systemctl stop NetworkManager',
          onlyif  => 'systemctl status NetworkManager',
          path    => '/usr/bin:/sbin:/bin',
        }
        package { 'git':
          ensure => present,
        }
        # with nss 3.36.0 we can have trouble with CA failing to start
        if $facts['os']['family'] == 'RedHat' {
          package { 'nss':
            ensure => latest,
          }
        }
      EOS

      apply_manifest_on(host, pp, catch_failures: true)

      # install_module_from_forge_on(host, 'saz-resolv_conf', '>= 4.0.0 < 5.0.0')
      # we need to not use function install_module_from_forge_on() because saz/resolv_conf is not often published on forge
      modname = 'resolv_conf'
      giturl = "https://github.com/saz/puppet-#{modname}.git"
      on host, puppet("resource exec 'git clone #{modname}' command='git clone #{giturl} /etc/puppetlabs/code/environments/production/modules/#{modname}' path=/usr/bin")
    end

    hosts_as('master').each do |master|
      pp = <<-EOS
        exec { 'set master /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       ipa-server-1.example.lan ipa-server-1\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n #{ip_master} ipa-server-1.example.lan ipa-server-1\n" > /etc/hosts',
        }
        EOS

      apply_manifest_on(master, pp, catch_failures: true, debug: true)
    end

    hosts_as('replica').each do |replica|
      ip_replica = fact_on('replica', 'networking.interfaces.eth1.ip')
      pp = <<-EOS
        exec { 'set replica /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       ipa-server-2.example.lan ipa-server-2\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n #{ip_replica} ipa-server-2.example.lan ipa-server-2\n" > /etc/hosts',
        }
        class { 'resolv_conf':
          nameservers => ['#{ip_master}'],
        }
        host {'ipa-server-1.example.lan':
          ensure => present,
          ip => '#{ip_master}',
        }
      EOS

      apply_manifest_on(replica, pp, catch_failures: true, debug: true)
    end

    # WARNING : function hosts_as() return an array.
    # We now use hosts_as() normaly with several nodes returned.
    # All clients have role 'client' in nodeset.

    # Configure all clients nodes.
    hosts_as('client').each do |client|
      ip_client = fact_on('client', 'networking.interfaces.enp0s8.ip')
      pp = <<-EOS
        exec { 'set client ubuntu /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       #{client}.example.lan #{client}\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n #{ip_client} #{client}.example.lan #{client}\n" > /etc/hosts',
        }
        class { 'resolv_conf':
          nameservers => ['#{ip_master}'],
        }
        host {'ipa-server-1.example.lan':
          ensure => present,
          ip => '#{ip_master}',
        }
        EOS

      apply_manifest_on(client, pp, catch_failures: true)
    end

    # Configure all centos nodes
    hosts_as('centos').each do |centos|
      yumipv4 = <<-EOS
        exec { 'disable selinux':
          command => 'setenforce 0',
          path    => '/usr/bin:/sbin:/bin',
        }
        exec {'echo "ip_resolve=4" >> /etc/yum.conf':
          onlyif => 'grep -v "^ip_resolve=4" /etc/yum.conf',
          path   => '/usr/bin:/sbin:/bin',
        }
      EOS

      apply_manifest_on(centos, yumipv4, catch_failures: true)
    end
  end
end
