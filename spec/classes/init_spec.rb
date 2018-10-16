

require 'spec_helper'

describe 'freeipa', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      if facts[:os]['family'] == 'RedHat'
        context 'on Centos' do
          context 'as bad_val role' do
            let :params do
              {
                ipa_role: 'bad_val',
                domain: 'rspec.example.lan'
              }
            end

            it { is_expected.to raise_error(Puppet::Error, %r{parameter ipa_role must be}) }
          end

          context 'as master' do
            context 'with defaults' do
              let :params do
                {
                  ipa_role:                    'master',
                  domain:                      'rspec.example.lan',
                  admin_password:              'rspecrspec123',
                  directory_services_password: 'rspecrspec123'
                }
              end

              it { is_expected.to contain_class('freeipa::install') }
              it { is_expected.to contain_class('freeipa::install::server') }
              it { is_expected.to contain_class('freeipa::install::sssd') }
              it { is_expected.to contain_class('freeipa::install::server::master') }
              it { is_expected.to contain_class('freeipa::config::webui') }
              it { is_expected.to contain_class('freeipa::validate_params') }

              it { is_expected.not_to contain_class('freeipa::install::autofs') }
              it { is_expected.not_to contain_class('freeipa::install::server::replica') }
              it { is_expected.not_to contain_class('freeipa::install::client') }

              it { is_expected.to contain_package('ipa-server-dns') }
              it { is_expected.to contain_package('bind-dyndb-ldap') }
              it { is_expected.to contain_package('kstart') }
              it { is_expected.to contain_package('ipa-server') }
              it { is_expected.to contain_package('openldap-clients') }
              it { is_expected.to contain_package('sssd-common') }

              it { is_expected.not_to contain_package('ipa-client') }

              it { is_expected.to compile.with_all_deps }
            end

            context 'with idstart out of range' do
              let :params do
                {
                  ipa_role:                    'master',
                  domain:                      'rspec.example.lan',
                  admin_password:              'rspecrspec123',
                  directory_services_password: 'rspecrspec123',
                  idstart:                     100
                }
              end

              it { is_expected.to raise_error(Puppet::Error, %r{an integer greater than 10000}) }
            end

            context 'with manage_host_entry but not ip_address' do
              let :params do
                {
                  ipa_role:                    'master',
                  domain:                      'rspec.example.lan',
                  admin_password:              'rspecrspec123',
                  directory_services_password: 'rspecrspec123',
                  manage_host_entry:           true
                }
              end

              it { is_expected.to raise_error(Puppet::Error, %r{parameter ip_address is mandatory}) }
            end

            context 'without admin_password' do
              let :params do
                {
                  ipa_role:                    'master',
                  domain:                      'rspec.example.lan',
                  directory_services_password: 'rspecrspec123'
                }
              end

              it { is_expected.to raise_error(Puppet::Error, %r{populated and at least of length 8}) }
            end

            context 'without directory_services_password' do
              let :params do
                {
                  ipa_role:                     'master',
                  domain:                       'rspec.example.lan',
                  admin_password:               'rspecrspec123'
                }
              end

              it { is_expected.to raise_error(Puppet::Error, %r{populated and at least of length 8}) }
            end
          end

          context 'as replica' do
            context 'with defaults' do
              let :params do
                {
                  ipa_role:             'replica',
                  domain:               'rspec.example.lan',
                  ipa_master_fqdn:      'ipa-server-1.rspec.example.lan',
                  domain_join_password: 'rspecrspec123'
                }
              end

              it { is_expected.to contain_class('freeipa::install') }
              it { is_expected.to contain_class('freeipa::install::server') }
              it { is_expected.to contain_class('freeipa::install::sssd') }
              it { is_expected.to contain_class('freeipa::install::server::replica') }
              it { is_expected.to contain_class('freeipa::config::webui') }
              it { is_expected.to contain_class('freeipa::validate_params') }

              it { is_expected.not_to contain_class('freeipa::install::autofs') }
              it { is_expected.not_to contain_class('freeipa::install::server::master') }
              it { is_expected.not_to contain_class('freeipa::install::client') }

              it { is_expected.to contain_package('ipa-server-dns') }
              it { is_expected.to contain_package('bind-dyndb-ldap') }
              it { is_expected.to contain_package('kstart') }
              it { is_expected.to contain_package('ipa-server') }
              it { is_expected.to contain_package('openldap-clients') }
              it { is_expected.to contain_package('sssd-common') }

              it { is_expected.not_to contain_package('ipa-client') }

              it { is_expected.to compile.with_all_deps }
            end

            context 'missing ipa_master_fqdn' do
              let :params do
                {
                  ipa_role:             'replica',
                  domain:               'rspec.example.lan',
                  domain_join_password: 'rspecrspec123'
                }
              end

              it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn must be set}) }
            end

            context 'missing domain_join_password' do
              let :params do
                {
                  ipa_role:               'replica',
                  domain:                 'rspec.example.lan',
                  ipa_master_fqdn:        'ipa-server-1.rspec.example.lan'
                }
              end

              it { is_expected.to raise_error(Puppet::Error, %r{domain_join_password cannot be empty}) }
            end
          end
        end
      end

      context 'as client' do
        context 'with defaults' do
          let :params do
            {
              ipa_role:             'client',
              domain:               'rspec.example.lan',
              ipa_master_fqdn:      'ipa-server-1.rspec.example.lan',
              domain_join_password: 'rspecrspec123'
            }
          end

          it { is_expected.to contain_class('freeipa::install') }
          it { is_expected.to contain_class('freeipa::install::sssd') }
          it { is_expected.to contain_class('freeipa::install::client') }
          it { is_expected.to contain_class('freeipa::validate_params') }

          it { is_expected.not_to contain_class('freeipa::install::autofs') }
          it { is_expected.not_to contain_class('freeipa::install::server') }
          it { is_expected.not_to contain_class('freeipa::install::server::master') }
          it { is_expected.not_to contain_class('freeipa::install::server::replica') }
          it { is_expected.not_to contain_class('freeipa::config::webui') }

          if facts[:os]['family'] == 'Debian'
            it { is_expected.to contain_package('freeipa-client') }
          else
            it { is_expected.to contain_package('ipa-client') }
          end

          it { is_expected.to contain_package('sssd-common') }
          it { is_expected.to contain_package('kstart') }

          it { is_expected.not_to contain_package('ipa-server-dns') }
          it { is_expected.not_to contain_package('bind-dyndb-ldap') }
          it { is_expected.not_to contain_package('ipa-server') }
          it { is_expected.not_to contain_package('openldap-clients') }
          it { is_expected.not_to contain_package('ldap-utils') }

          it { is_expected.to compile.with_all_deps }
        end

        context 'missing ipa_master_fqdn' do
          let :params do
            {
              ipa_role:             'client',
              domain:               'rspec.example.lan',
              domain_join_password: 'rspecrspec123'
            }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn must be set}) }
        end

        context 'missing domain_join_password' do
          let :params do
            {
              ipa_role:               'client',
              domain:                 'rspec.example.lan',
              ipa_master_fqdn:        'ipa-server-1.rspec.example.lan'
            }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{domain_join_password cannot be empty}) }
        end
      end
    end
  end
end
