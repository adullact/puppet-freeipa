require 'spec_helper'

ipa_node = 'foo.example.com'

describe 'freeipa::install::client' do
  context 'with node not yet configured' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }
        let(:pre_condition) do
          manifest = <<-EOS
            class{ 'freeipa' :
              ipa_role                    => 'client',
              ipa_master_fqdn             => 'master.example.com',
              ipa_server_fqdn             => '#{ipa_node}',
              domain                      => 'example.com',
              password_usedto_joindomain  => 'foobartest',
              puppet_admin_password       => 'foobartest',
              directory_services_password => 'foobartest',
              ip_address                  => '10.10.10.35',
            }
          EOS
          manifest
        end

        it { is_expected.to compile }
        it { is_expected.to contain_exec("client_install_#{ipa_node}").with('command' => %r{.*hostname=#{ipa_node}.*}) }
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
              ipa_role                    => 'client',
              ipa_master_fqdn             => 'master.example.com',
              ipa_server_fqdn             => 'foo.example.com',
              domain                      => 'example.com',
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

  context 'with node configured as master' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts.merge(iparole: 'master') }
        let(:pre_condition) do
          manifest = <<-EOS
            class{ 'freeipa' :
              ipa_role                    => 'client',
              ipa_master_fqdn             => 'master.example.com',
              ipa_server_fqdn             => 'foo.example.com',
              domain                      => 'example.com',
              password_usedto_joindomain  => 'foobartest',
              puppet_admin_password       => 'foobartest',
              directory_services_password => 'foobartest',
              ip_address                  => '10.10.10.35',
            }
          EOS
          manifest
        end

        it { is_expected.to compile.and_raise_error(%r{to change ipa_role from 'master' to 'client' is not supported}) }
      end
    end
  end
end
