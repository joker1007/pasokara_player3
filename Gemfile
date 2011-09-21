source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end
gem 'therubyracer'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
gem "rails3-generators"
gem "factory_girl_rails", ">= 1.0.1", :group => :test
gem "rspec", ">= 2.5.0", :group => [:test, :development]
gem "rspec-rails", ">= 2.5.0", :group => [:test, :development]
gem "spork", "~> 0.9.0rc", :group => [:test, :development]
gem "ZenTest", :group => :test
gem "autotest", :group => :test
gem "autotest-rails", :group => :test
gem "webrat", :group => [:test, :development]
gem "capybara", '~> 1.0.0', :group => [:test, :development]
gem "capybara-webkit", :git => 'git://github.com/thoughtbot/capybara-webkit.git', :group => [:test, :development]
gem "cucumber", :group => [:test, :development]
gem "cucumber-rails", :group => [:test, :development]
gem "launchy", :group => [:test, :development]
gem "jquery-rails"
gem "haml-rails"
gem "erb2haml", "~> 0.1.2", :group => :development

gem "mongoid", "~> 2.0"
gem "mongoid-rspec", "~> 1.4.4", :group => :test
gem "bson_ext", "~> 1.3"
gem "database_cleaner", "~> 0.6.7"

group :test do
  gem "simplecov", ">=0.3.8", :require => false
  gem "rb-fsevent"
  gem "guard-spork"
  gem "growl"
  gem "guard-rspec"
  gem "guard-cucumber"

  # Pretty printed test output
  gem 'turn', :require => false
end

gem "mechanize"
gem "pit"

gem "open4"
gem "newbamboo-rvideo", "~> 0.9.6", :require => "rvideo"

gem "sunspot_mongoid"
gem "sunspot_rails"
gem "sunspot_with_kaminari", '~> 0.1'

gem "kaminari"

gem "devise"

gem "resque", :require => "resque/server"

gem "carrierwave", '= 0.5.4'

gem "eventmachine"
