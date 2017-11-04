class StatementsPicture < ActiveRecord::Migration[5.1]
  def up
    add_attachment :statements, :picture
  end

  def down
    remove_attachment :statements, :picture
  end
end
