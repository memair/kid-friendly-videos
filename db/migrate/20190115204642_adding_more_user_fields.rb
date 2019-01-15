class AddingMoreUserFields < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :functioning_age, :integer
    add_column :users, :daily_watch_time, :integer
    add_column :users, :interests, :jsonb, default: []
  end
end
