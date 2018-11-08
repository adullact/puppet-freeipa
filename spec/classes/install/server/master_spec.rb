

require 'spec_helper'

describe 'freeipa::install::server::master' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) do
        manifest = <<-EOS
          class{ 'freeipa' :
            ipa_role                    => 'master',
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
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
