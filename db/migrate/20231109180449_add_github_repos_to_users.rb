class AddGithubReposToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :github_repos, :json
  end
end
