class ChangeDefaultPostState < ActiveRecord::Migration[6.0]
  def change
    change_column_default :posts, :state, from: :accepting, to: :open
  end
end
