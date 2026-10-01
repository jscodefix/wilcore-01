# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeopleController, type: :request do
  describe 'GET /people/{:id}' do
    context 'person exists' do
      let!(:person) do
        Person.create!(
          first_name: 'James',
          last_name: 'Buffett',
          phone_number: '305.555.0001',
          active: true,
          permission_codes: ['org1']
        )
      end

      it 'returns allowed JSON parameters' do
        get "/people/#{person.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to eq({
          'first_name' => 'James',
          'last_name' => 'Buffett',
          'phone_number' => '305.555.0001'
        })
        expect(json).not_to have_key('id')
        expect(json).not_to have_key('active')
        expect(json).not_to have_key('permission_codes')
      end
    end

    context 'person does not exist' do
      it 'returns 404' do
        get '/people/-1'

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json).to eq({ 'error' => 'Person not found' })
      end
    end
  end

  describe 'POST /people/{:id}/check_access' do
    context 'person does not exist' do
      it 'returns 404' do

      end
    end

    context 'person is not active' do
      it 'returns  { access: false }' do

      end
    end

    context 'person is marked active but not listed for access to organization' do
      it 'returns  { access: false }' do

      end
    end

    context 'person is listed for access to organization' do
      it 'returns  { access: true }' do

      end
    end
  end
end

