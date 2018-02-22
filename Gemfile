# rubocop:disable Metrics/LineLength
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.5'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Authentication
gem 'devise'                                                        # Authentication
gem 'devise-jwt', '~> 0.5.5'                                        # Authn with JWT for devise
gem 'devise_invitable'                                              # Invitation management for users based on devise

# API Handling
gem 'jsonapi-authorization'                                         # Authz for JSON API
gem 'jsonapi-resources'                                             # JSON API Resource handling
gem 'rack-cors'                                                     # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible

# i18n & Business Logic
gem 'aasm'                                                          # State machines for Ruby classes
gem 'carmen'                                                        # A repository of geographic regions for Ruby
gem 'enumerize'                                                     # Advanced Enum handling
gem 'steuernummer'                                                  # Validates German tax numbers
gem 'tzinfo-data'                                                   # Timezone info for different OSs
gem 'valvat'                                                        # Validates European VAT numbers

# Testing & Debugging
gem 'pry-rails'
gem 'terminal-table'

# Logging & Issue Management
gem 'r7insight'                                                     # Logging with Logentries (Rapid7 Insight)
gem 'sentry-raven'                                                  # Issue Management with Sentry

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman', require: false                                    # Static security tests
  gem 'bullet'                                                      # Detect N+1 queries
  gem 'colorize'
  gem 'factory_bot_rails'                                           # Factory for testing objects
  gem 'pry-byebug'                                                  # Debugger
  gem 'rspec-rails'                                                 # Run RSpec tests
  gem 'rubocop', require: false                                     # Static code checks
  gem 'rubocop-rspec', require: false                               # Rubocop for Rspec
end

group :development do
  gem 'annotate'                                                    # Use Annotate to add database schema to models
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'                                                      # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'                                                            # Strategies for cleaning databases in Ruby. Can be used to ensure a clean state for testing.
  gem 'shoulda-matchers', github: 'thoughtbot/shoulda-matchers', branch: 'master'   # Collection of testing matchers extracted from Shoulda
end
# rubocop:enable Metrics/LineLength
