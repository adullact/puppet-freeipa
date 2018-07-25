require 'spec_helper_acceptance'

describe ' freeipa class' do

  context 'master' do
    context 'with default parameters' do
      it 'applies idempotently' do
        pp = "class { 'freeipa': }"
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end  

      step 'test ipactl status with beaker exec' do
        on(host, "ipactl status")
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
