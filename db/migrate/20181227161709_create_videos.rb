class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :yt_id, null: false
      t.datetime :published_at
      t.string :description
      t.jsonb :tags
      t.references :channel, foreign_key: true

      t.timestamps
    end
  end
end
