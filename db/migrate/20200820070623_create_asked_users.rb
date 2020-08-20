class CreateAskedUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :asked_users do |t|

      t.timestamps
    end
  end
end
