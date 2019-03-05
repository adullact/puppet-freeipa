require 'spec_helper'

describe 'freeipa', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      if facts[:os]['family'] == 'RedHat'
        context 'on Centos' do
          context 'as master' do
            context 'with defaults' do
              let :params do
                {
                  ipa_role:                    'master',
                  domain:                      'example.lan',
                  puppet_admin_password:       'rspecrspec123',
                  directory_services_password: 'rspecrspec123',
                  ip_address:                  '10.10.10.35',
                  ipa_master_fqdn:             'master.example.lan'
                }
              end

              it { is_expected.to contain_class('freeipa::install') }
              it { is_expected.to contain_class('freeipa::install::server') }
              it { is_expected.to contain_class('freeipa::install::sssd') }
              it { is_expected.to contain_class('freeipa::install::server::master') }

              it { is_expected.not_to contain_class('freeipa::install::autofs') }
              it { is_expected.not_to contain_class('freeipa::install::server::replica') }
              it { is_expected.not_to contain_class('freeipa::install::client') }

              it { is_expected.to contain_package('ipa-server-dns') }
              it { is_expected.to contain_package('bind-dyndb-ldap') }
              it { is_expected.to contain_package('ipa-server') }
              it { is_expected.to contain_package('openldap-clients') }
              it { is_expected.to contain_package('sssd-common') }

              it { is_expected.not_to contain_package('ipa-client') }

              it { is_expected.to compile.with_all_deps }
            end
          end

          context 'as replica' do
            context 'with defaults' do
              let :params do
                {
                  ipa_role:                    'replica',
                  domain:                      'example.lan',
                  puppet_admin_password:       'rspecrspec123',
                  directory_services_password: 'rspecrspec123',
                  ip_address:                  '10.10.10.36',
                  ipa_master_fqdn:             'replica.example.lan',
                  password_usedto_joindomain:  'rspecrspec123'
                }
              end

              it { is_expected.to contain_class('freeipa::install') }
              it { is_expected.to contain_class('freeipa::install::server') }
              it { is_expected.to contain_class('freeipa::install::sssd') }
              it { is_expected.to contain_class('freeipa::install::server::replica') }

              it { is_expected.not_to contain_class('freeipa::install::autofs') }
              it { is_expected.not_to contain_class('freeipa::install::server::master') }
              it { is_expected.not_to contain_class('freeipa::install::client') }

              it { is_expected.to contain_package('ipa-server-dns') }
              it { is_expected.to contain_package('bind-dyndb-ldap') }
              it { is_expected.to contain_package('ipa-server') }
              it { is_expected.to contain_package('openldap-clients') }
              it { is_expected.to contain_package('sssd-common') }

              it { is_expected.not_to contain_package('ipa-client') }

              it { is_expected.to compile.with_all_deps }
            end
          end
        end
      end

      context 'as client' do
        context 'with defaults' do
          let :params do
            {
              ipa_role:                    'client',
              domain:                      'example.lan',
              puppet_admin_password:       'rspecrspec123',
              directory_services_password: 'rspecrspec123',
              ip_address:                  '10.10.10.36',
              ipa_master_fqdn:             'client.example.lan',
              password_usedto_joindomain:  'rspecrspec123'
            }
          end

          it { is_expected.to contain_class('freeipa::install') }
          it { is_expected.to contain_class('freeipa::install::sssd') }
          it { is_expected.to contain_class('freeipa::install::client') }

          it { is_expected.not_to contain_class('freeipa::install::autofs') }
          it { is_expected.not_to contain_class('freeipa::install::server') }
          it { is_expected.not_to contain_class('freeipa::install::server::master') }
          it { is_expected.not_to contain_class('freeipa::install::server::replica') }

          if facts[:os]['family'] == 'Debian'
            it { is_expected.to contain_package('freeipa-client') }
          else
            it { is_expected.to contain_package('ipa-client') }
          end

          it { is_expected.to contain_package('sssd-common') }

          it { is_expected.not_to contain_package('ipa-server-dns') }
          it { is_expected.not_to contain_package('bind-dyndb-ldap') }
          it { is_expected.not_to contain_package('ipa-server') }
          it { is_expected.not_to contain_package('openldap-clients') }
          it { is_expected.not_to contain_package('ldap-utils') }

          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end
end
