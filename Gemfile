# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
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
gem 'devise-async'                                                  # Send devise mails in background
gem 'devise-jwt', '~> 0.5.5'                                        # Authn with JWT for devise
gem 'devise_invitable'                                              # Invitation management for users based on devise

# API Handling
gem 'jsonapi-authorization', github: 'HQTrust/jsonapi-authorization', branch: 'hqtrust' # Auth for JSON API
gem 'jsonapi-resources', github: 'HQTrust/jsonapi-resources', branch: 'hqtrust' # JSON API Resource handling
gem 'pundit', '~> 1.1.0'                                            # Simple authorization layer
gem 'rack-cors'                                                     # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible

# Business Logic & Validation
gem 'aasm'                                                                           # State machines for Ruby classes
gem 'axlsx', github: 'randym/axlsx', ref: 'c593a08b2a929dac7aa8dc418b55e26b4c49dc34' # Wrapper for generation of .xlsx documents
gem 'carmen'                                                                         # A repository of geographic regions for Ruby
gem 'draper'                                                                         # Decorate models
gem 'email_validator', '~> 1.6.0'                                                    # Validates Emails, locked to v1.6.0 to use strict mode
gem 'enumerize'                                                                      # Advanced Enum handling
gem 'faker'                                                                          # A library for generating fake data such as names, addresses, and phone numbers.
gem 'ibanizator'                                                                     # Validates IBAN
gem 'jwt'                                                                            # Interact with Json-Web-Tokens
gem 'mail'                                                                           # Parse, generate or send emails
gem 'money'                                                                          # List of Currency
gem 'phony_rails'                                                                    # Validates, displays and saves phone numbers
gem 'rubyzip'                                                                        # reading and writing zip files
gem 'steuernummer'                                                                   # Validates German tax numbers
gem 'tzinfo-data'                                                                    # Timezone info for different OSs
gem 'validate_url'                                                                   # Validates URLs
gem 'valvat'                                                                         # Validates European VAT numbers

# Cloud Resources
gem 'aws-sdk-rails'                                                 # Interact with AWS in general (SES for example)
gem 'aws-sdk-s3'                                                    # Interact with AWS S3
gem 'mailjet'                                                       # Interact with Mailjet for emails
gem 'savon'                                                         # Interact with SOAP services

# Database, Storage & Job Handling
gem 'activerecord-import'                                           # Bulk import object into the database
gem 'paper_trail'                                                   # Track changes of models for auditing
gem 'pg', '~> 0.18'                                                 # Use postgresql as the database for Active Record
gem 'sidekiq'                                                       # Handle background jobs with sidekiq

# Testing & Debugging
gem 'pry'
gem 'pry-rails'
gem 'terminal-table'

# Logging & Issue Management
gem 'r7insight'                                                     # Logging with Logentries (Rapid7 Insight)
gem 'sentry-raven'                                                  # Issue Management with Sentry
gem 'skylight'                                                      # Performance Management with Skylight.io

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman', require: false                                    # Static security tests
  gem 'bullet', '5.7.5'                                             # Detect N+1 queries, currently locked to 5.7.5 because of https://github.com/flyerhzm/bullet/issues/435
  gem 'colorize'
  gem 'factory_bot_rails'                                           # Factory for testing objects
  gem 'pry-byebug'                                                  # Debugger
  gem 'rspec-rails'                                                 # Run RSpec tests
  gem 'rubocop', require: false                                     # Static code checks
  gem 'rubocop-rspec', require: false                               # Rubocop for Rspec
end

group :development do
  gem 'annotate', github: 'ctran/annotate_models', branch: 'develop'  # Use Annotate to add database schema to models
  gem 'get_process_mem'
  gem 'guard-rspec', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'                                                        # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner' # Strategies for cleaning databases in Ruby. Can be used to ensure a clean state for testing.
  gem 'jsonapi-resources-matchers', github: 'GabrielSandoval/jsonapi-resources-matchers', branch: 'ae-rails_5_upgrade_dependencies-155929975', require: false # Test matchers for jsonapi-resources
  gem 'shoulda-matchers' # Collection of testing matchers extracted from Shoulda
  gem 'timecop' # Provides time travel for tests
end
# rubocop:enable Metrics/LineLength
