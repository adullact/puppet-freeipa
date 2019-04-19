require 'spec_helper_acceptance'

describe 'class freeipa' do
  context 'with ipa_role master and no humanadmins defined' do
    hosts_as('master').each do |master|
      pp = <<-EOS
      class { 'freeipa':
        ipa_role                    => 'master',
        domain                      => 'example.lan',
        ipa_server_fqdn             => 'ipa-server-1.example.lan',
        puppet_admin_password       => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
        directory_services_password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
        install_ipa_server          => true,
        ip_address                  => '10.10.10.35',
        enable_ip_address           => true,
        enable_hostname             => true,
        enable_manage_admins        => true,
        manage_host_entry           => true,
        install_epel                => true,
        ipa_master_fqdn             => 'ipa-server-1.example.lan',
        humanadmins                 => {},
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

  context 'with ipa_role master and some humanadmins defined' do
    hosts_as('master').each do |master|
      pp = <<-EOS
      class { 'freeipa':
        ipa_role                    => 'master',
        domain                      => 'example.lan',
        ipa_server_fqdn             => 'ipa-server-1.example.lan',
        puppet_admin_password       => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
        directory_services_password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
        install_ipa_server          => true,
        ip_address                  => '10.10.10.35',
        enable_ip_address           => true,
        enable_hostname             => true,
        enable_manage_admins        => true,
        manage_host_entry           => true,
        install_epel                => true,
        ipa_master_fqdn             => 'ipa-server-1.example.lan',
        humanadmins                 => {
          foo => {
            ensure   => 'present',
            password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          },
          bar => {
            password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
            ensure   => 'present',
          },
        },
      }
      EOS

      it 'creates humanadmins without error' do
        apply_manifest_on(master, pp, catch_failures: true)
      end
      it 'creates humanadmins idempotently' do
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
          puppet_admin_password       => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          directory_services_password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          password_usedto_joindomain  => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          install_ipa_server          => true,
          ip_address                  => '10.10.10.36',
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
        result.exit_code.should == 0
      end
    end
  end

  context 'with ipa_role client' do
    hosts_as('client').each do |client|
      it 'applies idempotently' do
        pp = <<-EOS
        class {'freeipa':
          ipa_role                    => 'client',
          domain                      => 'example.lan',
          puppet_admin_password       => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          directory_services_password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          password_usedto_joindomain  => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          ip_address                  => '10.10.10.37',
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
          puppet_admin_password       => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          directory_services_password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          install_ipa_server          => true,
          ip_address                  => '10.10.10.35',
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
          ip_address                  => '10.10.10.35',
          install_epel                => true,
          ipa_master_fqdn             => 'ipa-server-1.example.lan'
        }
        EOS

        apply_manifest_on(master, pp, expect_failures: true)
      end
    end
  end

  context 'Test ssh connnections for jsmith user with pre-defined ssh-key' do
    # Install ssh key on root on master
    hosts_as('master').each do |master|
      it 'doest a kinit with puppet admin user' do
        on(master, "echo 's^ecr@et.ea;R/O*=?j!.QsAu+$' | kinit admin")
      end

      it 'creates user jsmith in freeipa' do
        on(master, "echo 's^ecr@et.ea;R/O*=?j!.QsAu+$' | ipa user-add jsmith --first=John --last=Smith --password")
      end

      it 'creates ssh key' do
        on(master, "ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa")
      end

      it 'adds the public key in freeipa to jsmith' do
        on(master, 'key=`cat /root/.ssh/id_rsa.pub`; ipa user-mod jsmith --sshpubkey="$key"')
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

      it 'ssh on allowed host' do
        pp = <<-EOS
          exec { 'test ssh':
          path     => '/bin/',
          command  => 'ssh -o "StrictHostKeyChecking no" jsmith@10.10.10.37 id',
          returns  => "0"
          }
          EOS

        apply_manifest_on(master, pp, catch_failures: true)
      end

      it 'ssh on not allowed host ' do
        pp = <<-EOS
          exec { 'test ssh':
          path     => '/bin/',
          command  => 'ssh -o "StrictHostKeyChecking no" jsmith@localhost id',
          returns  => "255"
          }
          EOS

        apply_manifest_on(master, pp, catch_failures: true)
      end
    end
  end

  context 'update and delete on humain admins accounts' do
    hosts_as('master').each do |master|
      it 'kinit for account foo with old password is expected to work' do
        pp = <<-EOS
          exec { 'kinit foo':
          path     => '/bin/',
          command  => 'echo "s^ecr@et.ea;R/O*=?j!.QsAu+$" | kinit foo',
          }
          EOS

        apply_manifest_on(master, pp, catch_failures: true)
      end
      it 'updates password account for foo and drops account for bar' do
        pp = <<-EOS
        class { 'freeipa':
          ipa_role                    => 'master',
          domain                      => 'example.lan',
          ipa_server_fqdn             => 'ipa-server-1.example.lan',
          puppet_admin_password       => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          directory_services_password => 's^ecr@et.ea;R/O*=?j!.QsAu+$',
          install_ipa_server          => true,
          ip_address                  => '10.10.10.35',
          enable_ip_address           => true,
          enable_hostname             => true,
          enable_manage_admins        => true,
          manage_host_entry           => true,
          install_epel                => true,
          ipa_master_fqdn             => 'ipa-server-1.example.lan',
          humanadmins                 => {
            foo => {
              ensure   => 'present',
              password => 'newsecr@et',
            },
            bar => {
              ensure   => 'absent',
            },
          },
        }
        EOS

        apply_manifest_on(master, pp, catch_failures: true)
        apply_manifest_on(master, pp, catch_changes: true)
      end
      it 'kinit for account foo with new password and expected to work' do
        pp = <<-EOS
          exec { 'kinit foo':
          path     => '/bin/',
          command  => 'echo "newsecr@et" | kinit foo',
          }
          EOS

        apply_manifest_on(master, pp, catch_failures: true)
      end
      it 'kinit for deleted account bar and expected to fail' do
        pp = <<-EOS
          exec { 'kinit bar':
          path     => '/bin/',
          command  => 'echo "s^ecr@et.ea;R/O*=?j!.QsAu+$" | kinit bar',
          }
          EOS

        apply_manifest_on(master, pp, expect_failures: true)
      end
    end
  end
end
