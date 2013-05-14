class CreateBacklogs < ActiveRecord::Migration
  def up
    create_table :backlogs do |t|
      t.string :name
      t.boolean :locked
      t.string :locked_session_id

      t.timestamps
    end

    add_column :issues, :backlog_id, :integer

    # migrate data
    backlog          = Backlog.create! name: "backlog", locked: false
    sprint_backlog   = Backlog.create! name: "sprint_backlog", locked: false
    finished_backlog = Backlog.create! name: "finished_backlog", locked: false

    Issue.all.each do |issue|
      if issue.finished
        issue.backlog = finished_backlog
      elsif issue.sprint_flag
        issue.backlog = sprint_backlog
      else
        issue.backlog = backlog
      end
      issue.save!
    end

    remove_column :issues, :sprint_flag
    remove_column :issues, :finished
  end

  def down
    drop_table :backlogs

    add_column :issues, :sprint_flag, :boolean
    add_column :issues, :finished, :boolean
  end
end
