require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

# With follwoing issue not fixed the acceptance tests about tasks are disabled :
# https://github.com/puppetlabs/beaker-task_helper/issues/47
# PR : https://github.com/puppetlabs/beaker-task_helper/pull/48
#
# describe 'manage_admin task' do
#  include Beaker::TaskHelper::Inventory
#  include BoltSpec::Run
#
#  def bolt_config
#    { 'modulepath' => File.join(File.dirname(File.expand_path(__FILE__)), '../', 'fixtures', 'modules') }
#  end
#
#  def bolt_inventory
#    hosts_to_inventory
#  end
#
#  context 'with ensure present' do
#    it 'creates admin account' do
#      result = run_task(
#        'freeipa::manage_admin',
#        'master',
#        { 'operator_login' => 'admin', 'operator_password' => 's^ecr@et.ea;R/O*=?j!.QsAu+$', 'ensure' => 'present', 'login' => 'jaimarre', 'firstname' => 'Jean', 'lastname' => 'Ai marre', 'password' => 'adminsecret' }
#      )
#      expect(result.first).to include('status' => 'success')
#    end
#  end
#
#  context 'with ensure absent on existing existing' do
#    it 'deletes admin account' do
#      result = run_task(
#        'freeipa::manage_admin',
#        'master',
#        { 'operator_login' => 'admin', 'operator_password' => 's^ecr@et.ea;R/O*=?j!.QsAu+$', 'ensure' => 'absent', 'login' => 'jaimarre' }
#      )
#      expect(result.first).to include('status' => 'success')
#    end
#  end
#
#  context 'with ensure absent on NOT existing account' do
#    it 'deletes admin account' do
#      result = run_task(
#        'freeipa::manage_admin',
#        'master',
#        { 'operator_login' => 'admin', 'operator_password' => 's^ecr@et.ea;R/O*=?j!.QsAu+$', 'ensure' => 'absent', 'login' => 'jaimarre' }
#      )
#      expect(result.first).to include('status' => 'success')
#    end
#  end
# end
