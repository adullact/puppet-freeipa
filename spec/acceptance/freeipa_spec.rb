require 'spec_helper_acceptance'

describe 'freeipa class' do
  describe 'install' do
    ### Test Install Master
    context 'master' do
      context 'with default parameters' do
        hosts_as('master').each do |master|
          it 'applies idempotently' do
            pp = <<-EOS
            class { 'freeipa':
              ipa_role => 'master',
              hostname => 'ipa-server-1',
              domain => 'vagrant.example.lan',
              ipa_server_fqdn => 'ipa-server-1.vagrant.example.lan',
              admin_password => 'vagrant123',
              directory_services_password => 'vagrant123',
              install_ipa_server => true,
              ip_address => '192.168.44.35',
              enable_ip_address => true,
              enable_hostname => true,
              manage_host_entry => true,
              install_epel => true,
              webui_disable_kerberos => true,
              webui_enable_proxy => true,
              webui_force_https => true,
            }
            EOS

            apply_manifest_on(master, pp, catch_failures: true)
            apply_manifest_on(master, pp, catch_changes: true)
          end

          describe command('ipactl status') do
            its(:exit_status) { is_expected.to be 0 }
          end
        end
      end
    end

    ### Test Install Replica
    context 'replica' do
      context 'with default parameters' do
        hosts_as('replica').each do |replica|
          it 'applies idempotently' do
            pp = <<-EOS
            class {'freeipa':
             ipa_role => 'replica',
             domain => 'vagrant.example.lan',
             ipa_server_fqdn => 'ipa-server-2.vagrant.example.lan',
             domain_join_password => 'vagrant123',
             install_ipa_server => true,
             ip_address => '192.168.44.36',
             enable_ip_address => true,
             enable_hostname => true,
             manage_host_entry => true,
             install_epel => true,
             ipa_master_fqdn => 'ipa-server-1.vagrant.example.lan',
            }
            EOS

            apply_manifest_on(replica, pp, :catch_failures => true, :debug => true)
            apply_manifest_on(replica, pp, :catch_changes  => true, :debug => true)
          end

          describe command('ipactl status') do
            its(:exit_status) { is_expected.to be 0 }
          end
        end
      end
    end
    
    ### Test Install Client
    context 'when clients' do
      context 'with default parameters' do
        hosts_as('client').each do |client|
          it 'applies idempotently' do
            pp = <<-EOS
            class {'freeipa':
             ipa_role => 'client',
             domain => 'vagrant.example.lan',
             domain_join_password => 'vagrant123',
             install_epel => true,
             ipa_master_fqdn => 'ipa-server-1.vagrant.example.lan',
            }
            EOS

            apply_manifest_on(client, pp, catch_failures: true, debug: true)
            apply_manifest_on(client, pp, catch_changes: true, debug: true)
          end
        end
      end
    end
  end
end
