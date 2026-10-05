class AddUniqueIndexToPeople < ActiveRecord::Migration[7.1]
  def change
    add_index :people, [:last_name, :first_name], unique: true
  end
end
