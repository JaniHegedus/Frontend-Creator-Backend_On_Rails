class AddGithubFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :github_uid, :string
    add_column :users, :github_nickname, :string
  end
end
