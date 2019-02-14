class AddTagsToChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :tags, :jsonb, default: []
  end
end
