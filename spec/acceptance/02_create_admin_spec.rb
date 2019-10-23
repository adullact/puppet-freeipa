require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'manage_admin task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def bolt_config
    { 'modulepath' => File.join(File.dirname(File.expand_path(__FILE__)), '../', 'fixtures', 'modules') }
  end

  def bolt_inventory
    hosts_to_inventory
  end

  context 'with ensure present' do
    it 'creates admin account' do
      # rubocop:disable Style/BracesAroundHashParameters
      result = run_task(
        'freeipa::manage_admin',
        'master',
        { 'operator_login' => 'admin', 'operator_password' => 's^ecr@et.ea;R/O*=?j!.QsAu+$', 'ensure' => 'present', 'login' => 'jaimarre', 'firstname' => 'Jean', 'lastname' => 'Aimarre', 'password' => 'adminsecret' }
      )
      # rubocop:enable Style/BracesAroundHashParameters
      expect(result.first).to include('status' => 'success')
    end
  end

  context 'with ensure absent' do
    it 'deletes admin account' do
      # rubocop:disable Style/BracesAroundHashParameters
      result = run_task(
        'freeipa::manage_admin',
        'master',
        { 'operator_login' => 'admin', 'operator_password' => 's^ecr@et.ea;R/O*=?j!.QsAu+$', 'ensure' => 'absent', 'login' => 'jaimarre' }
      )
      # rubocop:enable Style/BracesAroundHashParameters
      expect(result.first).to include('status' => 'success')
    end
  end
end
