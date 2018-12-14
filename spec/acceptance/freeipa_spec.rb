require 'spec_helper_acceptance'

describe 'freeipa class' do
  context 'with ipa_role master' do
    hosts_as('master').each do |master|
      it 'applies idempotently' do
        pp = <<-EOS
        class { 'freeipa':
          ipa_role => 'master',
          domain => 'example.lan',
          ipa_server_fqdn => 'ipa-server-1.example.lan',
          puppet_admin_password => 'vagrant123',
          directory_services_password => 'vagrant123',
	  humanadmins => { foo => { password => 'vagrant123', ensure => 'present'}, bar => { password => 'vagrant123', ensure => 'present'} },
          install_ipa_server => true,
          ip_address => '10.10.10.35',
          enable_ip_address => true,
          enable_hostname => true,
	  enable_manage_admins => false,
          manage_host_entry => true,
          install_epel => true,
          webui_disable_kerberos => true,
          webui_enable_proxy => true,
          webui_force_https => true,
          ipa_master_fqdn => 'ipa-server-1.example.lan',
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

  context 'with ipa_role replica' do
    hosts_as('replica').each do |replica|
      it 'applies idempotently' do
        pp = <<-EOS
        class {'freeipa':
         ipa_role => 'replica',
         domain => 'example.lan',
         ipa_server_fqdn => 'ipa-server-2.example.lan',
         puppet_admin_password => 'vagrant123',
         directory_services_password => 'vagrant123',
         password_usedto_joindomain => 'vagrant123',
         install_ipa_server => true,
         ip_address => '10.10.10.36',
         enable_ip_address => true,
         enable_hostname => true,
         manage_host_entry => true,
         install_epel => true,
         ipa_master_fqdn => 'ipa-server-1.example.lan'
        }
        EOS

        apply_manifest_on(replica, pp, catch_failures: true)
        apply_manifest_on(replica, pp, catch_changes: true)
      end

      it 'ipactl status on replica' do
        result = on(replica, 'ipactl status')
        result.exit_code.should == 0
      end
    end
  end

  context 'with ipa_role client' do
    hosts_as('client').each do |client|
      it 'applies idempotently' do
        pp = <<-EOS
        class {'freeipa':
         ipa_role => 'client',
         domain => 'example.lan',
         puppet_admin_password => 'vagrant123',
         directory_services_password => 'vagrant123',
         password_usedto_joindomain => 'vagrant123',
         ip_address => '10.10.10.37',
         install_epel => true,
         ipa_master_fqdn => 'ipa-server-1.example.lan'
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
          ipa_role => 'replica',
          domain => 'example.lan',
          ipa_server_fqdn => 'ipa-server-1.example.lan',
          puppet_admin_password => 'vagrant123',
          directory_services_password => 'vagrant123',
          install_ipa_server => true,
          ip_address => '10.10.10.35',
          enable_ip_address => true,
          enable_hostname => true,
          manage_host_entry => true,
          install_epel => true,
          webui_disable_kerberos => true,
          webui_enable_proxy => true,
          webui_force_https => true,
          ipa_master_fqdn => 'ipa-server-1.example.lan',
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
          ipa_role => 'client',
          domain => 'example.lan',
          puppet_admin_password => 'vagrant123',
          directory_services_password => 'vagrant123',
          password_usedto_joindomain => 'vagrant123',
          ip_address => '10.10.10.35',
          install_epel => true,
          ipa_master_fqdn => 'ipa-server-1.example.lan'
        }
        EOS

        apply_manifest_on(master, pp, expect_failures: true)
      end
    end
  end

  context 'Test ssh connnections for toto user with pre-defined ssh-key' do
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
        on(master, 'key=`cat /root/.ssh/id_rsa.pub`; ipa user-mod toto --sshpubkey="$key"')
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
          command  => 'ssh -o "StrictHostKeyChecking no" toto@10.10.10.37 id',
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

  context 'Test creation of admin accounts' do
    hosts_as('master').each do |master|
      it 'updates admin password' do
        pp = <<-EOS
        class { 'freeipa':
          ipa_role => 'master',
          domain => 'example.lan',
          ipa_server_fqdn => 'ipa-server-1.example.lan',
          puppet_admin_password => 'vagrant123',
          directory_services_password => 'vagrant123',
	  humanadmins => { foo => { password => 'vagrant123', ensure => 'present'}, bar => { password => 'vagrant123'} },
          install_ipa_server => true,
          ip_address => '10.10.10.35',
          enable_ip_address => true,
          enable_hostname => true,
          manage_host_entry => true,
          install_epel => true,
          webui_disable_kerberos => true,
          webui_enable_proxy => true,
          webui_force_https => true,
          ipa_master_fqdn => 'ipa-server-1.example.lan',
        }
        EOS

        apply_manifest_on(master, pp, catch_failures: true)
      end
    end
  end

  context 'Test update and delete on admin accounts' do
    hosts_as('master').each do |master|
      it 'updates admin password' do
        pp = <<-EOS
        class { 'freeipa':
          ipa_role => 'master',
          domain => 'example.lan',
          ipa_server_fqdn => 'ipa-server-1.example.lan',
          puppet_admin_password => 'vagrant123',
          directory_services_password => 'vagrant123',
	  humanadmins => { foo => { password => 'beaker456', ensure => 'present'}, bar => { password => 'vagrant123', ensure => 'absent'} },
          install_ipa_server => true,
          ip_address => '10.10.10.35',
          enable_ip_address => true,
          enable_hostname => true,
          manage_host_entry => true,
          install_epel => true,
          webui_disable_kerberos => true,
          webui_enable_proxy => true,
          webui_force_https => true,
          ipa_master_fqdn => 'ipa-server-1.example.lan',
        }
        EOS

        apply_manifest_on(master, pp, catch_failures: true)
      end
    end
  end
end
