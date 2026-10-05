# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  before do
    Organization.create!(name: 'Org 1', code: 'org1')
  end

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

    it 'is invalid with duplicate case-insensitive last_name and first_name' do
      Person.create!(first_name: 'Hans', last_name: 'Solo')
      duplicate = Person.new(first_name: 'hans', last_name: 'SOLO')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:last_name]).to include("and first name already exists")
    end

    it 'is invalid if any permission code is not associated with an organization' do
      person = Person.new(first_name: 'Jimmy', last_name: 'Hoffa', permission_codes: ['org1', 'org2'])
      expect(person).not_to be_valid
      expect(person.errors[:permission_codes]).to be_present
    end
  end

  describe 'permission_codes serialization' do
    it 'serializes and deserializes permission_codes as an Array' do
      Organization.create!(name: 'Org 2', code: 'org2')
      person = Person.create!(first_name: 'Jimmy', last_name: 'Hoffa', permission_codes: ['org1', 'org2'])
      reloaded_person = Person.find(person.id)
      expect(reloaded_person.permission_codes).to be_an(Array)
      expect(reloaded_person.permission_codes).to eq(['org1', 'org2'])
    end
  end
end
