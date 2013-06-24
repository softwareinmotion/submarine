class AddFinishedAtToIssues < ActiveRecord::Migration
  def change
    change_table :issues do |t|
      t.datetime :finished_at
    end
  end
end
