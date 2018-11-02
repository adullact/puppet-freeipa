

require 'spec_helper'

describe 'freeipa' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          ipa_role: 'client',
          ipa_master_fqdn: 'foo.example.com',
          domain_join_password: 'foobartest'
        }
      end

      it { is_expected.to compile }
    end
  end
end
