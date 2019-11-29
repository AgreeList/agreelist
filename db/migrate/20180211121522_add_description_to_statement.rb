class AddDescriptionToStatement < ActiveRecord::Migration[5.1]
  def change
    add_column :statements, :description, :text
  end
end
