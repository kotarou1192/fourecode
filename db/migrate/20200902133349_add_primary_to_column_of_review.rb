class AddPrimaryToColumnOfReview < ActiveRecord::Migration[6.0]
  def change
    add_column :reviews, :primary, :boolean
  end
end
