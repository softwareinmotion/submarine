class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|

      t.string :betreff
      t.string :email
      t.string :name
      t.string :question
      t.timestamps
    end
  end
end
