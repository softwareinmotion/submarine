class AddFileAttachmentToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :file_attachment, :string
  end
end
