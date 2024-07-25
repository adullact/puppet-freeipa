

require 'spec_helper'

describe 'freeipa::install::server' do
  context 'with node not yet configured' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:pre_condition) do
          manifest = <<-EOS
            class{ 'freeipa' :
              ipa_role                    => 'master',
              ipa_master_fqdn             => 'master.example.lan',
              ipa_server_fqdn             => 'foo.example.lan',
              domain                      => 'example.lan',
              password_usedto_joindomain  => 'foobartest',
              puppet_admin_password       => 'foobartest',
              directory_services_password => 'foobartest',
              ip_address                  => '10.10.10.35',
            }
          EOS
          manifest
        end

        it { is_expected.to compile }
      end

      context "Sensitive password on #{os}" do
        let(:facts) { os_facts }
        let(:pre_condition) do
          manifest = <<-EOS
            class{ 'freeipa' :
              ipa_role                    => 'master',
              ipa_master_fqdn             => 'master.example.lan',
              ipa_server_fqdn             => 'foo.example.lan',
              domain                      => 'example.lan',
              password_usedto_joindomain  => Sensitive('foobartest'),
              puppet_admin_password       => Sensitive('foobartest'),
              directory_services_password => Sensitive('foobartest'),
              ip_address                  => '10.10.10.35',
            }
          EOS
          manifest
        end

        it { is_expected.to compile }
      end

      context "External CA on #{os}" do
        let(:facts) { os_facts }
        let(:pre_condition) do
          manifest = <<-EOS
            class{ 'freeipa' :
              ipa_role                    => 'master',
              ipa_master_fqdn             => 'master.example.lan',
              ipa_server_fqdn             => 'foo.example.lan',
              domain                      => 'example.lan',
              password_usedto_joindomain  => 'foobartest',
              puppet_admin_password       => 'foobartest',
              directory_services_password => 'foobartest',
              ip_address                  => '10.10.10.35',
              external_ca                 => true,
            }
          EOS
          manifest
        end

        it { is_expected.to compile }
      end
    end
  end

  context 'with node configured as master' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts.merge(iparole: 'master') }
        let(:pre_condition) do
          manifest = <<-EOS
            class{ 'freeipa' :
              ipa_role                    => 'master',
              ipa_master_fqdn             => 'master.example.lan',
              ipa_server_fqdn             => 'foo.example.lan',
              domain                      => 'example.lan',
              password_usedto_joindomain  => 'foobartest',
              puppet_admin_password       => 'foobartest',
              directory_services_password => 'foobartest',
              ip_address                  => '10.10.10.35',
            }
          EOS
          manifest
        end

        it { is_expected.to compile }
      end
    end
  end

  context 'with node configured as client' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts.merge(iparole: 'client') }
        let(:pre_condition) do
          manifest = <<-EOS
            class{ 'freeipa' :
              ipa_role                    => 'master',
              ipa_master_fqdn             => 'master.example.lan',
              ipa_server_fqdn             => 'foo.example.lan',
              domain                      => 'example.lan',
              password_usedto_joindomain  => 'foobartest',
              puppet_admin_password       => 'foobartest',
              directory_services_password => 'foobartest',
              ip_address                  => '10.10.10.35',
            }
          EOS
          manifest
        end

        it { is_expected.to compile.and_raise_error(%r{to change ipa_role from 'client' to 'master' is not supported}) }
      end
    end
  end
end
