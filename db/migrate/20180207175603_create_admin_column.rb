class CreateAdminColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :individuals, :admin, :boolean, default: false
  end
end
