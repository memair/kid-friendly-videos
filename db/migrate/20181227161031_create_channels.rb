class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.string :yt_id, null: false
      t.string :title
      t.string :description
      t.integer :min_age, null: false
      t.integer :max_age, null: false
      t.datetime :last_extracted_at

      t.timestamps
    end
  end
end
