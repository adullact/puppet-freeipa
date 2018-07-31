require 'spec_helper_acceptance'

describe 'freeipa class' do

  context 'master' do
    context 'with default parameters' do
      it 'applies idempotently' do
        pp = <<-EOS
class { 'freeipa':
  ipa_role => 'master',
  hostname => 'ipa-server-1',
  domain => 'vagrant.example.lan',
  ipa_server_fqdn => 'ipa-server-1.vagrant.example.lan',
  admin_password => 'vagrant123',
  directory_services_password => 'vagrant123',
  install_ipa_server => true,
  ip_address => '192.168.44.35',
  enable_ip_address => true,
  enable_hostname => true,
  manage_host_entry => true,
  install_epel => true,
  webui_disable_kerberos => true,
  webui_enable_proxy => true,
  webui_force_https => true,
}
        EOS

        apply_manifest(pp, :catch_failures => true, :debug => true)
        apply_manifest(pp, :catch_changes  => true, :debug => true)
      end


      describe command('ipactl status') do
        its(:exit_status) { should eq 0 }
      end

    end
  end

#  context 'replica' do
#    context 'with default parameters' do
#      pp = "class { 'freeipa': }"
#      apply_manifest(pp, :catch_failures => true)
#      apply_manifest(pp, :catch_changes  => true)
#
#    end
#
#
#    step 'test ipactl status with beaker exec' do
#      on(host, "ipactl status")
#    end
#
#  end
#
#  context 'client' do
#    context 'with default parameters' do
#      pp = "class { 'freeipa': }"
#      apply_manifest(pp, :catch_failures => true)
#      apply_manifest(pp, :catch_changes  => true)
#
#    end
#
#
#  end


end










#  # Run these tests on the following platform
#  confine :to, :platform => 'centos'
#
#
#  step "Make sure ipa-server packages are installed" do
#    hosts.each do |host|
#      assert check_for_package(host, 'ipa-server')
#      assert check_for_package(host, 'ipa-client')
#    end
#  end
