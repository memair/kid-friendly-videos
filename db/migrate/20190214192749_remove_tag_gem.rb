class RemoveTagGem < ActiveRecord::Migration[5.2]
  def change
    drop_table :gutentag_taggings
    drop_table :gutentag_tags
  end
end
