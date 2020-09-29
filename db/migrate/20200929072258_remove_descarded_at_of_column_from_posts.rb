class RemoveDescardedAtOfColumnFromPosts < ActiveRecord::Migration[6.0]
  def change
    remove_column :posts, :discarded_at, :datetime
  end
end
