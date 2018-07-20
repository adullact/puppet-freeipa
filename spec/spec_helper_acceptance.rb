require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'beaker/task_helper'

PUPPET_INSTALL_VERSION = 5.5

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do

    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-accounts')
    end

    #we need :
    # * an already existing system user to test backup without root privileges
    # * a restic wrapper with old path used before 0.10
#    pp = <<-EOS
#      accounts::user { 'bar': 
#      }
#      ->
#      exec { 'produce ssh pair of keys' :
#        command => '/usr/bin/ssh-keygen -t rsa -f /home/bar/.ssh/id_rsa -q -P ""',
#        user    => 'bar',
#	creates => '/home/bar/.ssh/id_rsa',
#      }
#      ->
#      exec { 'set authorized_keys' :
#        command => '/bin/cp -af /home/bar/.ssh/id_rsa.pub /home/bar/.ssh/authorized_keys',
#        user    => 'bar',
#	unless  => '/usr/bin/test -s /home/bar/.ssh/authorized_keys',
#      }
#      ->
#      file { '/usr/local/bin/restic-foowrapper-bar' :
#        ensure  => file,
#	content => 'testing file to similate old wrapper used with bumpversion true\n',
#      }
#    EOS
#
#    apply_manifest_on(agents, pp, catch_failures: true)

  end

end

#shared_examples 'a idempotent resource' do
#  it 'applies with no errors' do
#    apply_manifest(pp, catch_failures: true)
#  end
#
#  it 'applies a second time without changes' do
#    apply_manifest(pp, catch_changes: true)
#  end
#end

