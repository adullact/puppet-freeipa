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
  gem 'puppet', '5.5'
  # should be 3.7.2 but not available on rubygems
  gem 'facter'
  gem 'hiera', '3.3.1'
  gem 'parallel_tests'

  # other testing gems we want
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-module_install_helper'
  gem 'metadata-json-lint'
  gem 'rake-notes'
  gem 'puppet-lint', '~> 2.1'

  # rspec must be v2 for ruby 1.8.7
  if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
    gem 'rspec', '~> 2.0'
    gem 'rake', '~> 10.0'
  else
    # rubocop requires ruby >= 1.9
    gem 'rubocop'
  end

end
