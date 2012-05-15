# Sail Plan - DockYard's Rails Template

def get_rid_of_shitty_double_quotes
  require 'find'
  Find.find('.').each do |file|
    if file.match(/\.rb$/)
     lines = File.open(file).readlines
     lines.map! { |line| line.gsub(/"/, "'") }
     file = File.open(file, 'w+')
     file << lines.join
     file.close
    end
  end
end

# Gems
file 'Gemfile', <<-GEMFILE, :force => true
source 'https://rubygems.org'

gem 'rails', '3.2.3'
gem 'pg'
gem 'jquery-rails'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'compass-rails'
gem 'haml'
gem 'simple_form'
gem 'exceptional'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'quiet_assets'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'debugger'
  gem 'heroku'
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'valid_attribute'
  gem 'capybara-email'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'timecop'
  gem 'fivemat'
  gem 'factory_girl_rails'
  gem 'bourne'
end
GEMFILE

run 'bundle install'

file '.rvmrc', 'rvm use 1.9.3-p0'

# Test
FileUtils.rm_rf('test')

generate('rspec:install')
file '.rspec', <<-RSPEC, force: true
  --colour
  --format Fivemat
RSPEC

inside('spec') do
  run 'mkdir support'
end

inside('spec/support') do
  file 'factory_girl.rb', <<-FILE
  RSpec.configure do |config|
    config.include Factory::Syntax::Methods
  end
  FILE

  file 'factories.rb', <<-FILE
  # Factories

  FILE

  file 'database_cleaner.rb', <<-FILE
  require 'database_cleaner'

  RSpec.configure do |config|
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.clean
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
  FILE

  file 'timecop.rb', <<-FILE
  require 'timecop'

  RSpec.configure do |config|
    config.before(:suite) do
      Timecop.travel(DateTime.new(2012, 1, 1, 6, 30, 0, 0))
    end

    config.after(:suite) do
      Timecop.return
    end
  end
  FILE

  file 'capybara', <<-FILE
  require 'capybara/rspec'
  FILE

  file 'capybara-email', <<-FILE
  require 'capybara/email/rspec'
  FILE

  file 'spec/support/capybara-webkit.rb', <<-FILE
  RSpec.configure do |config|
    config.before(:suite) do
      @headless = Headless.new
      @headless.start
      Capybara.javascript_driver = :webkit
    end

    config.after(:suite) do
      @headless.destroy
    end
  end
  FILE

  file 'bourne.rb', <<-FILE
  RSpec.configure do |config|
    config.mock_with :mocha
  end
  FILE
end

# Database
file 'config/database.example.yml', <<-DATABASE, :force => true
development:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_development
  pool: 5
  username:
  password:

test:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_test
  pool: 5
  username:
  password:
DATABASE

file 'lib/tasks/db.rake', <<-RAKE
namespace :db do
  desc 'Will completely drop the database, recreate it, then reseed and set up the test database'
  task :reset do
    %w{drop setup test:prepare}.each do |task|
      Rake::Task["db:\#{task}"].invoke
      Rake::Task['db:schema:load'].reenable
    end
     puts '== DB Reseeding Complete =='
  end
end
RAKE

run 'cp config/database.example.yml config/database.yml'
run 'rake db:create'
run 'rake db:migrate'
run 'rake db:test:prepare'

# Views
inside('app/views') do
  run 'rm layouts/application.html.erb'
  file 'layouts/application.html.haml', <<-VIEW
  !!!5
  %html
    %head
      %title #{app_name}
      = stylesheet_link_tag :application, :media => :all
      = javascript_include_tag :application
      = yield :head

    %body{:class => body_class}
      %header
        = render :partial => 'shared/header'
      %section#main
        = yield
      %footer
        = render :partial => 'shared/footer'
  VIEW

  run 'mkdir shared'
  FileUtils.touch('shared/_header.html.haml')
  FileUtils.touch('shared/_footer.html.haml')
end

application_rb = File.open('config/application.rb').readlines
haml_config = <<-RUBY

    # Set Haml to be the default template type
    config.generators do |generator|
      generator.template_engine :haml
    end
RUBY

new_application_rb = ((application_rb.clone[0..-3] << haml_config) + application_rb[-2..-1]).join

file 'config/application.rb', new_application_rb, :force => true

# Initializers
generate('simple_form:install')

run 'rm public/index.html'
run 'rm README.rdoc'

file 'README.md', <<-README
# #{app_name.titleize} #

## Getting set up ##

This project uses [RVM](http://beginrescueend.com) to manage its Ruby version.

Please install RVM if you don't have it already:

```
$ bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
```

If you already have RVM make sure you are using the latest version:

```
$ rvm get head && rvm reload
```

Make sure you have `Ruby-1.9.3-p0` installed:

```
$ rvm install ruby-1.9.3-p0
```

If you are on OSX Lion, you may need to build with clang:

(http://stackoverflow.com/questions/8032824/cant-install-ruby-under-lion-with-rvm-gcc-issues)

```
$ rvm install ruby-1.9.3-p0 --with-gcc=clang
```

Now you'll need to give RVM permission to append the `bundler_binstubs` directory to your path:

```
$ chmod +x $rvm_path/hooks/after_cd_bundler
```

[Install QT](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-QT)

Install the app:

```
$ bundle install
```

Configure, create, migrate, and seed the database

```
$ cp config/database.yml/example config/database.yml
$ vim config/database.yml
$ rake db:reseed
```

You should be good to go!
README

# Git Ignore
file '.gitignore', <<-GITIGNORE, :force => true
.bundle
log/*.log
/log/*.pid
tmp/*
/coverage/*
public/system/*
public/stylesheets/compiled/*
config/database.yml
db/*.sqlite3
db/structure.sql
*.swp
*.swo
.DS_Store
**/.DS_STORE
GITIGNORE

get_rid_of_shitty_double_quotes

git :init
git :add => '.'
git :commit => "-a -m 'Initial project commit'"
