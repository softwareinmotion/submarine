class AddReadyToFinishAttribute < ActiveRecord::Migration
  def change
    change_table :issues do |t|
      t.boolean :ready_to_finish, :default => false
    end
  end
end
