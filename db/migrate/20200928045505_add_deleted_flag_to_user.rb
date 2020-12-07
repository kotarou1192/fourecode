class AddDeletedFlagToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at

    add_column :posts, :discarded_at, :datetime
    add_index :posts, :discarded_at
  end
end
