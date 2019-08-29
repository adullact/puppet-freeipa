require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

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
      EOS

      apply_manifest_on(host, pp, catch_failures: true)

      # install_module_from_forge_on(host, 'saz-resolv_conf', '>= 4.0.0 < 5.0.0')
      # we need to not use function install_module_from_forge_on() because saz/resolv_conf is not often published on forge
      modname = 'resolv_conf'
      giturl = "https://github.com/saz/puppet-#{modname}.git"
      on host, puppet("resource exec 'git clone #{modname}' command='git clone #{giturl} /etc/puppetlabs/code/environments/production/modules/#{modname}' path=/usr/bin")
    end

    # Configure /etc/hosts for each node.
    # WARNING : function hosts_as() return an array.
    # But here we use several roles dedicated, used only once time in nodeset.
    # This permit to use one different IP for each role : master, replica, client-centos7 and client-ubuntu16.

    # Here master with ip address 10.10.10.35
    hosts_as('master').each do |master|
      pp = <<-EOS
        exec { 'set master /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       ipa-server-1.example.lan ipa-server-1\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 10.10.10.35 ipa-server-1.example.lan ipa-server-1\n" > /etc/hosts',
        }
        EOS

      apply_manifest_on(master, pp, catch_failures: true, debug: true)
    end

    # Here replica with ip address 10.10.10.36
    hosts_as('replica').each do |replica|
      pp = <<-EOS
         exec { 'set replica /etc/hosts':
           path     => '/bin/',
           command  => 'echo -e "127.0.0.1       ipa-server-2.example.lan ipa-server-2\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 10.10.10.36 ipa-server-2.example.lan ipa-server-2\n" > /etc/hosts',
         }
         class { 'resolv_conf':
           nameservers => ['10.10.10.35'],
         }
         host {'ipa-server-1.example.lan':
           ensure => present,
           ip => '10.10.10.35',
         }
      EOS

      apply_manifest_on(replica, pp, catch_failures: true, debug: true)
    end

    # Here a first client running CentOS7 with ip address 10.10.10.37
    hosts_as('client-centos7').each do |clientcentos7|
      pp = <<-EOS
        exec { 'set client centos /etc/hosts':
          path     => '/bin/',
          command  => 'echo -e "127.0.0.1       ipa-client-centos.example.lan ipa-server-2\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 10.10.10.37 ipa-client-centos.example.lan ipa-client-centos\n" > /etc/hosts',
        }
      EOS

      apply_manifest_on(clientcentos7, pp, catch_failures: true)
    end

    # Here a second client running Ubuntu1604 with ip address 10.10.10.38
    hosts_as('client-ubuntu16').each do |clientubuntu16|
      pp = <<-EOS
         exec { 'set client ubuntu /etc/hosts':
           path     => '/bin/',
           command  => 'echo -e "127.0.0.1       ipa-client-ubuntu16.example.lan ipa-server-2\n ::1     ip6-localhost ip6-loopback\n fe00::0 ip6-localnet\n ff00::0 ip6-mcastprefix\n ff02::1 ip6-allnodes\n ff02::2 ip6-allrouters\n\n 10.10.10.38 ipa-client-ubuntu16.example.lan ipa-client-ubuntu16\n" > /etc/hosts',
         }
         EOS

      apply_manifest_on(clientubuntu16, pp, catch_failures: true)
    end

    # WARNING : function hosts_as() return an array. We now use hosts_as() normaly with several nodes returned.
    #  * all clients have role 'client' in nodeset.
    #  * all nodes running CentOS have role 'centos' in nodeset.

    # Configure all clients nodes.
    hosts_as('client').each do |client|
      pp = <<-EOS
        class { 'resolv_conf':
          nameservers => ['10.10.10.35'],
        }
        host {'ipa-server-1.example.lan':
          ensure => present,
          ip => '10.10.10.35',
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
