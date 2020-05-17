class AddApiKeyToIndividuals < ActiveRecord::Migration[5.1]
  def change
    add_column :individuals, :api_key, :string
  end
end
