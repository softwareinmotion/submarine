class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :name
      t.text :description
      t.integer :predecessor_id
      t.float :story_points
      t.string :type
      t.integer :project_id

      t.timestamps
    end
  end
end
