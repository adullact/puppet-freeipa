

require 'spec_helper'

describe 'freeipa::config::webui' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) do
        manifest = <<-EOS
          class{ 'freeipa' :
            ipa_role                    => 'master',
            ipa_master_fqdn             => 'master.example.lan',
            ipa_server_fqdn             => 'foo.example.lan',
            domain                      => 'example.lan',
            password_usedto_joindomain  => 'foobartest',
            admin_password              => 'foobartest',
            directory_services_password => 'foobartest',
            ip_address                  => '10.10.10.35',
          }
        EOS
        manifest
      end
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
