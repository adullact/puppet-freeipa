require 'spec_helper'

describe 'Freeipa::Humanadmin' do
  humanadmin = {
    'ensure' => 'present',
    'password' => 'secret123'
  }

  it { is_expected.to allow_value(humanadmin) }
end
