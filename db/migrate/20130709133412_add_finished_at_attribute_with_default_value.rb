class AddFinishedAtAttributeWithDefaultValue < ActiveRecord::Migration
  def change
    change_table :issues do |t|
      t.datetime :finished_at, :default => Time.now
    end
  end
end
