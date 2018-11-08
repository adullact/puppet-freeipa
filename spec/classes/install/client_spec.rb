

require 'spec_helper'

describe 'freeipa::install::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        manifest = <<-EOS
          class{ 'freeipa' :
            ipa_role                    => 'client',
            ipa_master_fqdn             => 'master.example.com',
            ipa_server_fqdn             => 'foo.example.com',
            domain                      => 'vagrant.lan',
            password_usedto_joindomain  => 'foobartest',
            admin_password              => 'foobartest',
            directory_services_password => 'foobartest',
            ip_address                  => '192.168.44.35',
          }
        EOS
        manifest
      end

      it { is_expected.to compile }
    end
  end
end
