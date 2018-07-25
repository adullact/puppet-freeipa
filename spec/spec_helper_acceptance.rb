require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

PUPPET_INSTALL_VERSION = 5.5

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do

    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-concat')
      on host, puppet('module', 'install', 'puppetlabs-stdlib')
      on host, puppet('module', 'install', 'crayfishx-firewalld')
      on host, puppet('module', 'install', 'puppet-selinux')
    end

### Doit installer les modules suivants pour master:
### * puppet module install puppetlabs-concat
### * puppet module install puppetlabs-stdlib
### * puppet module install crayfishx-firewalld
### * puppet module install puppet-selinux
### * IPV6 activée
### * hostname/hostname -f

### Doit installer les modules suivants pour replicas:
### * puppet module install puppetlabs-concat
### * puppet module install puppetlabs-stdlib
### * puppet module install crayfishx-firewalld
### * puppet module install puppet-selinux
### * puppet module install saz-resolv_conf
### * IPV6 activée
### * hostname/hostname -f

### Doit installer les modules suivants pour clients:
### * puppet module install puppetlabs-concat
### * puppet module install puppetlabs-stdlib
### * puppet module install crayfishx-firewalld
### * puppet module install puppet-selinux
### * puppet module install saz-resolv_conf
### * IPV6 activée


  end

end
