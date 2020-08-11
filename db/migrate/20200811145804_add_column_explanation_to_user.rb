class AddColumnExplanationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :explanation, :string
  end
end
