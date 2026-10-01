# frozen_string_literal: true

class PeopleController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    person = Person.find(params[:id])
    render json: person, serializer: PersonSerializer, status: :ok
  end

  def check_access
    person = Person.find(params[:id])
    org_id = params.dig(:organization, :id)
    org = Organization.find_by(id: org_id) if org_id.present?

    has_access = person.active? && org.present? && Array(person.permission_codes).map(&:to_s).include?(org.code.to_s)
    render json: { access: has_access }, status: :ok
  end

  private

  def record_not_found
    render json: { error: 'Person not found' }, status: :not_found
  end
end
