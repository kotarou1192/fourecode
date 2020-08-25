class AddIndexToPosts < ActiveRecord::Migration[6.0]
  def change
    add_index :posts, :body
    add_index :posts, :code
    add_index :posts, :title
  end
end
