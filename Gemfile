source 'http://rubygems.org'

gem 'rails', '3.2.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end
gem 'therubyracer'

# Use unicorn as the web server
gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

gem "rails3-generators"
gem "factory_girl_rails", ">= 1.0.1", :group => :test
gem "jquery-rails"
gem "haml-rails"

gem "origin"
gem "moped"
gem "mongoid", "~> 3.0"
gem "bson_ext"
gem "database_cleaner", ">= 0.6.7"

group :development, :test do
  gem "rspec", "~> 2.11.0"
  gem "rspec-rails", "~> 2.11.0"
  gem "rspec-parameterized"
  gem "mongoid-rspec", ">= 1.4.4"
  gem "cucumber-rails", :require => false
  gem "spork", ">= 0.9.0"
  gem "capybara"
  gem "capybara-webkit"
  gem "cucumber"
  gem "minitest"
  gem "launchy"
  gem "pry-rails"
  gem "ci_reporter"
  gem "ruby_gntp"
  gem "tapp"
end

group :test do
  gem "simplecov", ">=0.3.8", :require => false
  gem "simplecov-rcov", :require => false
  gem "rb-fsevent"
  gem "guard-spork"
  gem "growl"
  gem "guard-rspec"
  gem "guard-cucumber"

  # Pretty printed test output
  gem 'turn', :require => false
  gem "delorean"
end

gem "mechanize"
gem "pit"

gem "sunspot_mongoid"
gem "sunspot_rails"
gem "sunspot_solr"
gem "sunspot_with_kaminari", '>= 0.1'

gem "kaminari"

gem "devise"

gem "resque", :require => "resque/server"

gem "carrierwave"
gem "carrierwave-mongoid"
gem "fog", "~> 1.3.1"

gem "which_browser", :git => 'git://github.com/joker1007/which_browser.git'
