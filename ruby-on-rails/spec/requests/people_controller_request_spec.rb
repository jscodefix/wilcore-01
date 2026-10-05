# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeopleController, type: :request do
  before do
    Organization.create!(name: 'Org 1', code: 'org1')
  end

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
        post '/people/-1/check_access', params: { organization: { id: 1 } }, as: :json

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json).to eq({ 'error' => 'Person not found' })
      end
    end

    context 'person is NOT active' do
      let!(:inactive_person) do
        Person.create!(
          first_name: 'Janis',
          last_name: 'Joplin',
          phone_number: '305.555.0002',
          active: false,
          permission_codes: ['org1']
        )
      end
      let!(:org_one) do
        Organization.create!(name: 'Org One', code: 'org1')
      end

      it 'returns access denied' do
        post "/people/#{inactive_person.id}/check_access", params: { organization: { id: org_one.id } }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to eq({ 'access' => false })
      end
    end

    context 'person IS active' do
      context 'WITHOUT access to organization' do
        let!(:active_person) do
          Person.create!(
            first_name: 'James',
            last_name: 'Buffett',
            phone_number: '305.555.0001',
            active: true,
            permission_codes: ['org1']
          )
        end
        let!(:org_two) do
          Organization.create!(name: 'Org Two', code: 'org2')
        end

        it 'returns access denied' do
          post "/people/#{active_person.id}/check_access", params: { organization: { id: org_two.id } }, as: :json

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json).to eq({ 'access' => false })
        end
      end

      context 'WITH access to organization' do
        let!(:active_person) do
          Person.create!(
            first_name: 'James',
            last_name: 'Buffett',
            phone_number: '305.555.0001',
            active: true,
            permission_codes: ['org1']
          )
        end
        let!(:org_one) do
          Organization.create!(name: 'Org One', code: 'org1')
        end

        it 'returns access granted' do
          post "/people/#{active_person.id}/check_access", params: { organization: { id: org_one.id } }, as: :json

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json).to eq({ 'access' => true })
        end
      end
    end
  end
end
