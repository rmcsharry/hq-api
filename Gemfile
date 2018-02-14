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

# i18n
gem 'tzinfo-data' # Timezone info for different OSs

# Testing & Debugging
gem 'pry-rails'
gem 'terminal-table'

group :development, :test do
  # cli debugger
  gem 'awesome_print'
  gem 'brakeman', require: false                                    # Static security tests
  gem 'bullet'                                                      # Detect N+1 queries
  gem 'colorize'
  gem 'pry-byebug'                                                  # Debugger
  gem 'rspec-rails', '~> 3.7'                                       # Run RSpec tests
  gem 'rubocop', '~> 0.52.1', require: false                        # Static code checks
  gem 'rubocop-rspec', '~> 1.22.1', require: false                  # Rubocop for Rspec
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'                                                      # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
end
# rubocop:enable Metrics/LineLength
