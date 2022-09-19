require 'spec_helper_acceptance'

ip_master = fact_on('master', 'networking.interfaces.eth1.ip')
ip_replica = fact_on('replica', 'networking.interfaces.eth1.ip')

describe 'class freeipa' do
  context 'with ipa_role master' do
    hosts_as('master').each do |master|
      pp = <<-EOS
      class { 'freeipa':
        ipa_role                    => 'master',
        domain                      => 'example.lan',
        ipa_server_fqdn             => 'ipa-server-1.example.lan',
        puppet_admin_password       => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
        directory_services_password => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
        install_ipa_server          => true,
        ip_address                  => '#{ip_master}',
        enable_ip_address           => true,
        enable_hostname             => true,
        manage_host_entry           => true,
        install_epel                => true,
        ipa_master_fqdn             => 'ipa-server-1.example.lan',
      }
      EOS

      it 'installs master without error' do
        apply_manifest_on(master, pp, catch_failures: true)
      end
      it 'installs master idempotently' do
        apply_manifest_on(master, pp, catch_changes: true)
      end

      describe command('ipactl status') do
        its(:exit_status) { is_expected.to be 0 }
      end
    end
  end

  context 'with ipa_role replica' do
    hosts_as('replica').each do |replica|
      it 'applies idempotently' do
        pp = <<-EOS
        class {'freeipa':
          ipa_role                    => 'replica',
          domain                      => 'example.lan',
          ipa_server_fqdn             => 'ipa-server-2.example.lan',
          puppet_admin_password       => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          directory_services_password => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          password_usedto_joindomain  => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          install_ipa_server          => true,
          ip_address                  => '#{ip_replica}',
          enable_ip_address           => true,
          enable_hostname             => true,
          manage_host_entry           => true,
          install_epel                => true,
          ipa_master_fqdn             => 'ipa-server-1.example.lan',
        }
        EOS

        apply_manifest_on(replica, pp, catch_failures: true)
        apply_manifest_on(replica, pp, catch_changes: true)
      end

      it 'ipactl status on replica' do
        result = on(replica, 'ipactl status')
        expect(result.exit_code).to be == 0
      end
    end
  end

  context 'with ipa_role client' do
    hosts_as('client').each do |client|
      ip_client = fact_on('client', 'networking.interfaces.enp0s8.ip')
      it 'applies idempotently' do
        pp = <<-EOS
        class {'freeipa':
          ipa_role                    => 'client',
          domain                      => 'example.lan',
          puppet_admin_password       => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          directory_services_password => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          password_usedto_joindomain  => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          ip_address                  => '#{ip_client}',
          install_epel                => true,
          ipa_master_fqdn             => 'ipa-server-1.example.lan'
        }
        EOS

        apply_manifest_on(client, pp, catch_failures: true)
        apply_manifest_on(client, pp, catch_changes: true)
      end
    end
  end

  context 'with ipa_role replica on master' do
    hosts_as('master').each do |master|
      it 'fails' do
        pp = <<-EOS
        class { 'freeipa':
          ipa_role                    => 'replica',
          domain                      => 'example.lan',
          ipa_server_fqdn             => 'ipa-server-1.example.lan',
          puppet_admin_password       => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          directory_services_password => Sensitive('s^ecr@et.ea;R/O*=?j!.QsAu+$'),
          install_ipa_server          => true,
          ip_address                  => '#{ip_master}',
          enable_ip_address           => true,
          enable_hostname             => true,
          manage_host_entry           => true,
          install_epel                => true,
          ipa_master_fqdn             => 'ipa-server-1.example.lan',
        }
        EOS

        apply_manifest_on(master, pp, expect_failures: true)
      end
    end
  end

  context 'with ipa_role client on master' do
    hosts_as('master').each do |master|
      it 'fails' do
        pp = <<-EOS
        class { 'freeipa':
          ipa_role                    => 'client',
          domain                      => 'example.lan',
          puppet_admin_password       => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          directory_services_password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          password_usedto_joindomain  => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          ip_address                  => '#{ip_master}',
          install_epel                => true,
          ipa_master_fqdn             => 'ipa-server-1.example.lan'
        }
        EOS

        apply_manifest_on(master, pp, expect_failures: true)
      end
    end
  end
end
