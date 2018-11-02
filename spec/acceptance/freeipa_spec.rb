

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
              webui_force_https => true
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
             ipa_master_fqdn => 'ipa-server-1.vagrant.example.lan'
            }
            EOS

            apply_manifest_on(replica, pp, catch_failures: true, debug: true)
            apply_manifest_on(replica, pp, catch_changes: true, debug: true)
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
             ipa_master_fqdn => 'ipa-server-1.vagrant.example.lan'
            }
            EOS

            apply_manifest_on(client, pp, catch_failures: true, debug: true)
            apply_manifest_on(client, pp, catch_changes: true, debug: true)
          end
        end
      end
    end

    ### Test HBAC (ssh connections for a user with limited rights)
    context 'Test ssh connnections for toto user with pre-defined ssh-key' do
      context 'with default parameters' do
        # Install ssh key on root on master
        hosts_as('master').each do |master|
          it 'doest a kinit' do
            on(master, "echo 'vagrant123' | kinit admin")
          end

          it 'creates user toto in freeipa' do
            on(master, "echo 'vagrant123' | ipa user-add toto --first=John --last=Smith --password")
          end

          it 'creates ssh key' do
            on(master, "ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa")
          end

          it 'adds the public key in freeipa to toto' do
            on(master, 'key=`cat /root/.ssh/id_rsa.pub`; ipa user-mod toto --sshpubkey=\"$key\"')
          end

          # Add HBAC Rule to give all ipa users access to ipa-client-centos
          it 'creates a HBAC rule for all users' do
            on(master, 'ipa hbacrule-add --usercat=all --servicecat=all allGroup')
          end

          it 'adds centos client to allGroup rule' do
            on(master, 'ipa hbacrule-add-host --hosts=ipa-client-centos allGroup')
          end

          # Remove allow_all HBAC
          it 'deletes the allow_all default rule' do
            on(master, 'ipa hbacrule-del allow_all')
          end

          it 'test ssh on allowed host with returns' do
            pp = <<-EOS
              exec { 'test ssh':
              path     => '/bin/',
              command  => 'ssh -o "StrictHostKeyChecking no" toto@192.168.44.37 id',
              returns  => "0"
              }
              EOS

            apply_manifest_on(master, pp, catch_failures: true)
          end

          it 'test ssh on not allowed host with returns' do
            pp = <<-EOS
              exec { 'test ssh':
              path     => '/bin/',
              command  => 'ssh -o "StrictHostKeyChecking no" toto@localhost id',
              returns  => "255"
              }
              EOS

            apply_manifest_on(master, pp, catch_failures: true)
          end
        end
      end
    end
  end
end
