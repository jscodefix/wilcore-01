class AddAttributesToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :name, :text, null: false
    add_column :organizations, :code, :text, null: false
    add_column :organizations, :address, :text
    add_column :organizations, :phone_number, :text
    add_index :organizations, :code
  end
end
