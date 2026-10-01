# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonSerializer, type: :serializer do
  let(:person) do
    Person.new(
      first_name: 'Jane',
      last_name: 'Fonda',
      phone_number: '619.555.1234',
      active: true,
      permission_codes: ['org1']
    )
  end

  subject(:serialization) { described_class.new(person).as_json }

  it 'includes only whitelisted attributes' do
    expect(serialization.stringify_keys).to include(
      'first_name' => 'Jane',
      'last_name' => 'Fonda',
      'phone_number' => '619.555.1234'
    )
  end

  it 'does not expose private metadata' do
    keys = serialization.keys.map(&:to_s)
    expect(keys).not_to include('active')
    expect(keys).not_to include('permission_codes')
  end
end
