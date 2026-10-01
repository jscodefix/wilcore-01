class PersonSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name, :phone_number
end
