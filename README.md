# First Time Setup

In this ReadMe you can find the nessesary steps to get this project up and running.\
And the things you may want to cover:

* Ruby version:\
Ruby 3.2.2

### * *System dependencies:*\

-Install Ruby 3.2.2 + Devtools recommended\
-Consider using the included MSYS2 MINGW as Admin to install libyaml library, if not present.\
*Prompt for MSYS2 install:* "pacman -S libyaml"

### * *Configuration:*\

-Run Bundler install with given Gemfile\
-If you havent recieved my exact masterkey then you can proceed with the next step:\
-Generate a master key(if not given)\
  **Run the command:**\
$env:EDITOR = "your-editor (example: code) --wait" bin/rails credentials:edit*\
Replacing your-editor with the command for the text editor they prefer (like vim, nano, code for Visual Studio Code, etc.).
  This command will open a new credentials file in the chosen text editor and automatically generate a new master.key file in the config directory.\
  Now here is an example how the credentials are structured in this project:
`- secret_key_base: This one will be generated automatically
- openai_api_key: your_key
- google_api_key: your_key
- github:\
-- client_id: your_id\ 
-- client_secret: your_secret
- email:\
  -- address: your_address\
  -- port: your_port\
  -- domain: your_domain\
  -- user_name: your_user_name\
  -- password: your_password\
  -- authentication: your_authentication
- email_test:\
  -- address: your_test_address\
  -- port: your_test_port\
  -- domain: your_test_domain\
  -- user_name: your_test_user_name\
  -- password: your_test_password\
  -- authentication: your_test_authentication
`
* Open the credentials with rails credentials:edit\
Add the Openai, Google Vision and Github credentials\
Add the Mailer smtp credentials for UserMailer\
And the add the smtp for the development environment labeled: "email_test"
### Database creation:
Create a sqlite3 database migration with rails, if not present in current Rails project\
**Prompt**:\
"rails generate migration CreateUsers username:string email:string password_digest:string github_uid:integer github_nickname:string github_repos:json" 
### Database initialization:
Then when migration file  is done or present run:\
**Prompt**:\
"rails db:migrate"
### * How to run the test suite:
You can use the "rails server command" or you can use the any IDE-s server starter Configurations. 
The default rails project will be available to 

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
