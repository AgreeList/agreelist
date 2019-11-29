class AddNobelLaureate < ActiveRecord::Migration[5.1]
  def change
    add_column :individuals, :nobel_laureate, :boolean, default: false, null: false
  end
end
