class AddPositionToAgreement < ActiveRecord::Migration[5.1]
  def change
    add_column :agreements, :position, :integer
  end
end
