# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Organization.find_or_create_by!(name: Faker::Company.name, code: '123', address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.phone_number)
Organization.find_or_create_by!(name: Faker::Company.name, code: '456', address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.phone_number)
Person.find_or_create_by!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, phone_number: Faker::PhoneNumber.phone_number, active: true, permission_codes: ['123', '456'])
Person.find_or_create_by!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, phone_number: Faker::PhoneNumber.phone_number, active: true, permission_codes: ['123'])
Person.find_or_create_by!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, phone_number: Faker::PhoneNumber.phone_number, active: false, permission_codes: ['123', '456'])
