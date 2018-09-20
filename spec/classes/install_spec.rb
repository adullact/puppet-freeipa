require 'spec_helper'

describe 'freeipa::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        'class{"freeipa": ipa_role => "client", ipa_master_fqdn => "foo.example.com", domain_join_password => "foobartest"}'
      end     
      it { is_expected.to compile }
    end
  end
end
