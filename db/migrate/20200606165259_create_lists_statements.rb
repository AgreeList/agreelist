class CreateListsStatements < ActiveRecord::Migration[5.1]
  def change
    create_table :lists_statements do |t|
      t.belongs_to :list
      t.belongs_to :statement
    end
  end
end
