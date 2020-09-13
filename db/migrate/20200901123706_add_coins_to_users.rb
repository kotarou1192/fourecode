class AddCoinsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :coins, :integer
  end
end
