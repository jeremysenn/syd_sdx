class CreateInventoriesTable < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.integer :user_id
      t.text :closed_packs
      t.text :scanned_packs
      
      t.timestamps
    end
  end
end
