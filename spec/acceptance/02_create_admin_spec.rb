require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'create_admin task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def bolt_config
    { 'modulepath' => File.join(File.dirname(File.expand_path(__FILE__)), '../', 'fixtures', 'modules') }
  end

  def bolt_inventory
    hosts_to_inventory
  end

  it 'creates admin account' do
    # rubocop:disable Style/BracesAroundHashParameters
    result = run_task(
      'freeipa::create_admin',
      'master',
      { 'operator_login' => 'admin', 'operator_password' => 's^ecr@et.ea;R/O*=?j!.QsAu+$', 'login' => 'jaimarre', 'firstname' => 'Jean', 'lastname' => 'Aimarre', 'password' => 'adminsecret' }
    )
    # rubocop:enable Style/BracesAroundHashParameters
    expect(result.first).to include('status' => 'success')
  end
end
