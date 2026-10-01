# frozen_string_literal: true

class Person < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
end
