# frozen_string_literal: true

class PeopleController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    person = Person.find(params[:id])
    render json: person, serializer: PersonSerializer, status: :ok
  end

  def check_access
    render json: { success: 'true or false goes here' }
  end

  private

  def record_not_found
    render json: { error: 'Person not found' }, status: :not_found
  end
end
