class DropConfigurables < ActiveRecord::Migration
  def up
  	remove_index :configurables, :name
    drop_table :configurables
  end

  def down
  	create_table :configurables do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
    
    add_index :configurables, :name
  end
end
