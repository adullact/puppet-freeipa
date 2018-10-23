

require 'spec_helper'

describe 'freeipa' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          ipa_role: 'client',
          ipa_master_fqdn: 'foo.example.com',
	  domain: 'vagrant.lan',
          password_usedto_joindomain: 'foobartest',
	  admin_password: 'vagrant123',
	  directory_services_password: 'vagrant123',
	  ip_address: '192.168.44.35'
        }
      end

      it { is_expected.to compile }
    end
  end
end
