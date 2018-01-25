source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
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

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# API Handling
gem 'jsonapi-resources'                                             # JSON API Resource handling
gem 'jsonapi-authorization'                                         # Authz for JSON API

# i18n
gem 'tzinfo-data'                                                   # Timezone info for different OSs

# Testing & Debugging
gem 'pry-rails'
gem 'terminal-table'

group :development, :test do
    # cli debugger
  gem 'awesome_print'
  gem 'colorize'
  gem 'pry-byebug'                                                  # Debugger

  gem 'brakeman', require: false                                    # Static security tests
  gem 'bullet'                                                      # Detect N+1 queries
  gem 'rubocop', '~> 0.52.1', require: false                        # Static code checks
  gem 'rubocop-rspec', '~> 1.22.1', require: false                  # Rubocop for Rspec
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'                                                      # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
end
