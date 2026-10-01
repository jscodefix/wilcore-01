# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      person = Person.new(first_name: 'Jimmy', last_name: 'Hoffa', phone_number: '303.555.DEAD', active: true, permission_codes: ['org1'])
      expect(person).to be_valid
    end

    it 'is invalid with a blank first_name' do
      person = Person.new(first_name: '')
      expect(person).not_to be_valid
      expect(person.errors[:first_name]).to be_present
    end

    it 'is invalid with a blank last_name' do
      person = Person.new(last_name: '')
      expect(person).not_to be_valid
      expect(person.errors[:last_name]).to be_present
    end
  end

  describe 'permission_codes serialization' do
    it 'serializes and deserializes permission_codes as an Array' do
      person = Person.create!(first_name: 'Jimmy', last_name: 'Hoffa', permission_codes: ['org1', 'org2'])
      reloaded_person = Person.find(person.id)
      expect(reloaded_person.permission_codes).to be_an(Array)
      expect(reloaded_person.permission_codes).to eq(['org1', 'org2'])
    end
  end
end
