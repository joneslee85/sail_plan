# Sail Plan - DockYard's Rails Template

class EasyAuth
  attr_accessor :account_class

  def initialize(account_class)
    self.account_class = account_class
  end

  def account_filename
    account_class.underscore
  end

  def rake_task
    'easy_auth:install:migrations'
  end

  def gemfile
    %{gem 'easy_auth', :git => 'https://github.com/dockyard/easy_auth.git'}
  end
end

@install_options = {}

def install_options
  @install_options
end

def run_ruby_script(command, config={})
  return unless behavior == :invoke
  rbenv_run command, config.merge(:with => Thor::Util.ruby_command)
end

def replace_line(path, options = {})
  lines = File.open(path).readlines
  lines.map! do |line|
    if line.match(options[:match])
      line = "#{options[:with].rstrip}\n"
    end
    line
  end 

  run "rm #{path}"
  File.open(path, 'w+') { |file| file << lines.join }
end

def setup_shell
  begin
    require 'session'
  rescue LoadError
    puts 'Session gem unavailable. Attempting to install...'
    puts `gem install session`
    Gem::Specification.reset
    retry
  end

  $sh = Session.new

  stdout, stderr = $sh.execute('which rbenv')
  if stdout.present?
    version = File.open('.rbenv-version').read.strip
    $sh.execute %{eval "$(rbenv init -)"}
    $sh.execute "rbenv shell #{version}"
  else
    $sh = nil
  end
end

def rbenv_run(command, config={})
  unless $sh
    return run(command, config)
  end

  return unless behavior == :invoke

  destination = relative_to_original_destination_root(destination_root, false)
  desc = "#{command} from #{destination.inspect}"

  say_status :run, desc, config.fetch(:verbose, true)

  unless options[:pretend]
    config[:capture] ? `#{command}` : puts($sh.execute("#{command}")[0])
  end
end

def ask_with_default(prompt, default)
  value = ask("#{prompt} [#{default}]")
  value.blank? ? default : value
end

def easy_auth_installed?
  install_options[:easy_auth]
end

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

def install_additional_gems
  gems = %w{easy_auth}.inject([]) do |list, gem|
    list << install_options[gem.to_sym].gemfile if install_options[gem.to_sym]
    list
  end

  unless gems.empty?
    gems.join("\n") + "\n"
  end
end

def install_additional_asset_gems
  gems = []
  if install_options[:backbone]
    gems << "  gem 'haml_coffee_assets'"
    gems << "  gem 'execjs'"
  end

  unless gems.empty?
    gems.join("\n")
  end
end

def run_additional_rake_tasks
  if easy_auth = easy_auth_installed?
    rbenv_run "rake #{easy_auth.rake_task}"
  end
end

attempt = 0
begin
  raise "No PhantomJS" if `brew ls | grep phantomjs`.blank?
rescue
  attempt += 1
  if attempt == 1
    puts 'PhantomJS is not installed. Attempting to install via brew'
    `brew install phantomjs`
    retry
  else
    puts 'Could not install... please install PhantomJS before running this template. Exiting...'
    exit!
  end
end

file '.rbenv-version', <<-FILE
1.9.3-p125
FILE

setup_shell

# Gems
if yes?('Install Backbone?')
  install_options[:backbone] = true
end

if yes?('Install EasyAuth?')
  account_class = ask_with_default('  What should the account model be called?', 'Account')
  install_options[:easy_auth] = EasyAuth.new(account_class)
end

file 'Gemfile', <<-GEMFILE, :force => true
source 'https://rubygems.org'

gem 'rails', '3.2.3'
gem 'thin'
gem 'pg'
gem 'jquery-rails'
gem 'compass-rails'
gem 'haml-rails'
gem 'simple_form'
gem 'exceptional'
gem 'kaminari'
#{install_additional_gems}
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
#{install_additional_asset_gems}
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
  gem 'poltergeist', :git => 'git://github.com/jonleighton/poltergeist.git'
  gem 'valid_attribute'
  gem 'capybara-email'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'timecop'
  gem 'fivemat'
  gem 'factory_girl_rails'
  gem 'bourne'
  gem 'headless'
end
GEMFILE

rbenv_run 'bundle install --binstubs'
rbenv_run 'rbenv rehash'

# Test
FileUtils.rm_rf('test')

generate('rspec:install')
file '.rspec', <<-RSPEC, force: true
  --colour
  --format Fivemat
RSPEC

inside('spec') do
  run 'mkdir support'
  run 'mkdir config'
  run 'mkdir -p requests/step_helpers'
  FileUtils.touch('requests/step_helpers/.gitkeep')

  insert_into_file 'spec_helper.rb', :before => "Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}\n" do
    "Dir[Rails.root.join('spec/config/**/*.rb')].each  {|f| require f}\n" + 
    "Dir[Rails.root.join('spec/requests/step_helpers/**/*.rb')].each  {|f| require f}\n"
  end
end

file 'spec/support/factories.rb', <<-FILE
# Factories

FILE

inside('spec/config') do
  file 'rspec.rb', <<-FILE
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
FILE

  file 'active_record.rb', <<-FILE
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
  end
end
FILE

  file 'factory_girl.rb', <<-FILE
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
FILE

  file 'database_cleaner.rb', <<-FILE
require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
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

  file 'capybara.rb', <<-FILE
require 'capybara/rspec'
FILE

  file 'capybara-email.rb', <<-FILE
require 'capybara/email/rspec'
FILE

  file 'poltergeist.rb', <<-FILE
require 'capybara/poltergeist'

RSpec.configure do |config|
  config.before(:suite) do
    Capybara.javascript_driver = :poltergeist
  end
end
FILE

  file 'headless.rb', <<-FILE
require 'headless'

$headless = Headless.new
$headless.start
at_exit do
  $headless.destroy
end
FILE

  file 'bourne.rb', <<-FILE
RSpec.configure do |config|
  config.mock_with :mocha
end
FILE
end

# Models
if easy_auth = easy_auth_installed?
  generate("model #{easy_auth.account_class} email:string first_name:string last_name:string session_token:string")
  inside('app/models') do
    insert_into_file("#{easy_auth.account_filename}.rb", :after => /ActiveRecord::Base\n/) do
      "  include EasyAuth::Models::Account\n"
    end
  end
end

# Controllers
inside('app/controllers') do
  file 'landing_controller.rb', <<-CONTROLLER
class LandingController < ApplicationController
end
CONTROLLER
  if easy_auth_installed?
    insert_into_file('application_controller.rb', :after => /ActionController::Base\n/) do
      "  include EasyAuth::Helpers\n"
    end
  end
end

# Views
inside('app/views') do
  run 'rm layouts/application.html.erb'
  file 'layouts/application.html.haml', <<-VIEW
!!!5
%html
  %head
    %title #{app_name.titleize}
    = stylesheet_link_tag :application, :media => :all
    = stylesheet_link_tag :print, :media => :print
    = javascript_include_tag 'http://cdnjs.cloudflare.com/ajax/libs/modernizr/2.5.3/modernizr.min.js'
    = javascript_include_tag :application
    = csrf_meta_tags
    %link{:rel => 'author', :type => 'text/plain', :href => '/humans.txt'}
    = yield :head

  %body{:class => body_classes}
    %header
      = render :partial => 'shared/header'
    %section#flash
      = flash_helper
    %section#main
      = yield
    %footer
      = render :partial => 'shared/footer'
VIEW

  run 'mkdir shared'
  FileUtils.touch('shared/_header.html.haml')
  FileUtils.touch('shared/_footer.html.haml')

  file 'shared/_flash.html.haml', <<-VIEW
%section{:class => ['flash', key]}
  %p= message
VIEW

  run 'mkdir landing'
  file 'landing/show.html.haml', ''
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
replace_line('config/application.rb', :match => /config.autoload_paths/, :with => '   config.autoload_paths += %W(#{config.root}/app/assets/fonts)')

#Add print.css.scss to asset precompilation
replace_line('config/environments/production.rb', :match => /config.assets.precompile \+=/, :with => '  config.assets.precompile += %w( print.css )')

file 'config/routes.rb', <<-ROUTES, :force => true
#{app_name.classify}::Application.routes.draw do
  root :to => 'landing#show'
end
ROUTES

if easy_auth_installed?
  insert_into_file 'config/routes.rb', :after => /routes.draw do\n/ do
    "  easy_auth_routes\n"
  end
end

# Helpers

inside('app/helpers') do
  file 'application_helper.rb', <<-HELPER, :force => true
module ApplicationHelper
  def body_classes
    [params[:controller], params[:action]]
  end

  def flash_helper
    flash.keys.inject('') do |html, key|
      html << render(:partial => 'shared/flash', :locals => { :key => key, :message => flash[key] })
    end.html_safe
  end
end
HELPER
end

# Assets
inside('app/assets/stylesheets') do
  run 'rm application.css'
  file 'application.css.sass', <<-FILE
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets/application, vendor/assets/stylesheets/application,
 * or vendor/assets/stylesheets/application of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 *= require_tree ./application
 */
FILE
run 'mkdir application'
file 'application/index.css.sass', <<-FILE
/*
 * Index for application.css.sass
 */

@import "compass/reset"
FILE

  file 'print.css.sass', <<-FILE
/*
 * This is a manifest file that'll be compiled into print.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets/print, vendor/assets/stylesheets/print,
 * or vendor/assets/stylesheets/print of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add print-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 *= require_tree ./print
 */
FILE
run 'mkdir print'
file 'print/index.css.sass', <<-FILE
/*
 * Index for print.css.sass
 */
FILE
run 'mkdir mixins'
FileUtils.touch('mixins/.gitkeep')
end

if install_options[:backbone]
  inside('vendor/assets/javascripts') do
    run 'curl -s http://backbonejs.org/backbone.js > backbone.js'
    run 'curl -s http://documentcloud.github.com/underscore/underscore.js > underscore.js'
  end
end

inside('app/assets/javascripts') do
  javascript = File.open('application.js').readlines
  File.open('application.js.coffee', 'w+') { |f| f << javascript.map { |line| line.gsub(/^\/\//, '#') }.join }
  run 'rm application.js'

  if install_options[:backbone]
    insert_into_file 'application.js.coffee', :after => "#= require jquery_ujs\n" do
      ['underscore', 'hamlcoffee', 'backbone', 'backbone/bootstrap'].map { |req| "#= require #{req}" }.join("\n") + "\n"
    end
    run 'mkdir backbone'
    inside('backbone') do
      %w{models routers templates views}.each do |dir|
        run "mkdir #{dir}"
        FileUtils.touch("#{dir}/.gitkeep")
      end
      file 'bootstrap.js.coffee', <<-COFFEE
window.App =
  Collections = {}
  Models      = {}
  Routers     = {}
  Views       = {}

window.routers = {}

#= require_tree ./template
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers
COFFEE
    end
  end
end

run('mkdir app/assets/fonts')
FileUtils.touch('app/assets/fonts/.gitkeep')

# Database
file 'config/database.example.yml', <<-DATABASE, :force => true
development:
  adapter: postgresql
  database: #{app_name}_development
  username:
  password:
  encoding: utf8

test:
  adapter: postgresql
  database: #{app_name}_test
  username:
  password:
  encoding: utf8
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
run_additional_rake_tasks
rbenv_run 'rake db:create'
rbenv_run 'rake db:migrate'
rbenv_run 'rake db:test:prepare'

# Initializers
generate('simple_form:install')
replace_line('config/initializers/simple_form.rb', :match => /config.label_text/, :with => "  config.label_text = lambda { |label, required| label }")

generate('kaminari:config')

if (api_key = ask('Exceptional.io API Key: ')).present?
  rbenv_run "exceptional install #{api_key}"
end

run 'rm public/index.html'
run 'rm README.rdoc'

file 'public/humans.txt', <<-FILE
/* TEAM */
  This app was built by DockYard, LLC
  Web: http://dockyard.com
  Twitter: @dockyard
  Email: contact@dockyard.com
  Location: Boston, MA

/* SITE */
  Standards: HTML5, CSS3
  Components: Ruby on Rails
  Software: Vim, OSX
  Frameworks: Ruby on Rails, jQuery, Backbone, Compass
FILE

file 'README.md', <<-README
# #{app_name.titleize} #

## Getting set up ##

This app uses [rbenv](https://github.com/sstephenson/rbenv/)

Please follow the instructions for setting on rbenv if you already have not done so.

PhantomJS must be installed, use [homebrew](http://mxcl.github.com/homebrew/)

```
brew install phantomjs
```

Install the app:

```
bundle install
```

Configure, create, migrate, and seed the database

```
cp config/database.yml/example config/database.yml
vim config/database.yml
rake db:reseed
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
.sass-cache/*
bundler_stubs/*
binstubs/*
GITIGNORE

get_rid_of_shitty_double_quotes

git :init
git :add => '.'
git :commit => "-a -m 'Initial Project Generated from SailPlan'"
