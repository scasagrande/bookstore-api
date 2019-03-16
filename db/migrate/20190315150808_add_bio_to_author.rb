class AddBioToAuthor < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :biography, :text
    add_column :authors, :github_issue_id, :integer
  end
end
