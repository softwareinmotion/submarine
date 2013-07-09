class RemoveFinishedAtAttribute < ActiveRecord::Migration
  def change
    change_table :issues do |t|
      t.remove :finished_at
    end
  end
end
