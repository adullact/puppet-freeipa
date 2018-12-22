require 'spec_helper'

describe 'Freeipa::Humanadmins' do
  humanadmins = {
    'admin1' => {
      'ensure' => 'present',
      'password' => 'secret123'
    },
    'admin2' => {
      'password' => 'secret123'
    },
    'admin3' => {
      'ensure' => 'absent'
    }
  }

  it { is_expected.to allow_value(humanadmins) }
end
