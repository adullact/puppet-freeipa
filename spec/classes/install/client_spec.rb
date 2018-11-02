

require 'spec_helper'

describe 'freeipa::install::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) do
        manifest = <<-EOS
          class{'freeipa':
            ipa_role             => 'client',
            ipa_master_fqdn      => 'foo.example.com',
            domain_join_password => 'foobartest',
            install_ipa_client   => true,
            install_ipa_server   => false
          }
        EOS
        manifest
      end
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
