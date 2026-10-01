# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      org = Organization.new(name: 'Acme Corp', code: 'acme', address: '123 Main St', phone_number: '800.try.acme x42')
      expect(org).to be_valid
    end

    it 'is invalid with a blank name' do
      org = Organization.new(name: '')
      expect(org).not_to be_valid
      expect(org.errors[:name]).to be_present
    end

    it 'is invalid with a blank code' do
      org = Organization.new(code: '')
      expect(org).not_to be_valid
      expect(org.errors[:code]).to be_present
    end
  end
end
