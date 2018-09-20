require 'spec_helper'

describe 'freeipa::install::autofs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) do
        'class{"freeipa": ipa_role => "client", ipa_master_fqdn => "foo.example.com", domain_join_password => "foobartest"}'
      end
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
