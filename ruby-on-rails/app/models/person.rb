# frozen_string_literal: true

class Person < ApplicationRecord
  before_validation :normalize_name

  validates :first_name, presence: true
  validates :last_name, presence: true, uniqueness: { scope: :first_name, message: 'and first name already exists' }
  validates :permission_codes, inclusion: { in: ->(person) { Organization.pluck(:code) }, message: 'are not associated with an organization' }

  private

  def normalize_name
    self.first_name = first_name&.strip&.capitalize
    self.last_name = last_name&.strip&.capitalize
  end
end
