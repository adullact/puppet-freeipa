source 'https://rubygems.org'

group :development do
  # controlrepo is a helper tool to setup spec and integration testing inside of a
  # Puppet control repository.  We're not using the rake rakes, but instead
  # directly invoking `rspec spec` in an effort to cut down on the amount of
  # implicit, magic behavior.  The controlrepo gem provides value in the form of
  # an updated set of dependencies suitable for spec testing using rspec-puppet.
  #
  # https://github.com/jeffmccune/controlrepo_gem
  gem 'controlrepo'
end

group :test, :development do
  gem 'facter'
  gem 'hiera'
  gem 'parallel_tests'

  # other testing gems we want
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'beaker-puppet'
  gem 'beaker-docker'
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-module_install_helper'
  gem 'metadata-json-lint'
  gem 'puppet-lint'
  gem 'rspec'
  gem 'rake'
  gem 'rubocop'

  # net-telnet 0.2.0 requires Ruby version >= 2.3.0
  if RUBY_VERSION == '2.1.9'
    gem 'net-telnet', '< 0.2.0'
  elsif RUBY_VERSION == '2.4.4'
    gem 'net-telnet', '>= 0.2.0'
  end

end
