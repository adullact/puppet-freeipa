require 'spec_helper'

describe 'freeipa::helpers::flushcache' do
  let(:pre_condition) { 'class{"::freeipa": ipa_role => "client", ipa_master_fqdn => "foo.example.com", domain_join_password => "foobartest"}' }
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
