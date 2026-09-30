class AddAttributesToPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :first_name, :text, null: false
    add_column :people, :last_name, :text, null: false
    add_column :people, :phone_number, :text
    add_column :people, :active, :boolean, default: true, null: false
    add_column :people, :permission_codes, :json, default: []
  end
end
