require 'spec_helper'

describe 'freeipa::install::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) do
        'class{"freeipa": ipa_role => "master", ipa_master_fqdn => "foo.example.com", domain_join_password => "foobartest", admin_password => "foobartest", directory_services_password => "foobartest", install_ipa_client => false, install_ipa_server => true}'
      end
      let(:facts) { os_facts }
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
