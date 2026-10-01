# frozen_string_literal: true

class Organization < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true
end
