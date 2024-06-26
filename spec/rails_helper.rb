# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'rspec/json_expectations'
require 'aasm/rspec'
require 'jsonapi/resources/matchers'
require 'shoulda/matchers'
require 'support/authorization_helper'
require 'support/docx_helper'
require 'support/endpoints'
require 'support/factory_bot'
require 'support/shared_examples/authorization'
require 'support/shared_examples/forbid_ews_users'
require 'support/shared_examples/simple_crud_authorization'
require 'support/shared_examples/state_transitions'
require 'support/v1/shoulda/matchers/active_record/uniqueness/test_models/contacu_resource'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Uncomment if you want to have SQL queries to be logged into STDOUT during specs
# ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # https://www.sitepoint.com/learn-the-first-best-practices-for-rails-and-rspec/
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  Shoulda::Matchers.configure do |conf|
    conf.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    # In most tests we don't want scores to be automatically recalculated on save (ie. cannot test moving scores!)
    Contact.skip_callback(:commit, :after, :update_mandate_score)
    Contact::Person.skip_callback(:save, :before, :calculate_score)
    Contact::Organization.skip_callback(:save, :before, :calculate_score)
    Mandate.skip_callback(:save, :before, :calculate_score)

    # Also disabling all these rescoring callbacks so we can test scores explicitly
    BankAccount.skip_callback(:commit, :after, :rescore_owner)
    ComplianceDetail.skip_callback(:commit, :after, :rescore_contact)
    ContactRelationship.skip_callback(:commit, :after, :rescore_owner)
    Document.skip_callback(:commit, :after, :rescore_owner)
    MandateMember.skip_callback(:commit, :after, :rescore_mandate)
    TaxDetail.skip_callback(:commit, :after, :rescore_contact)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Bullet configuration
  config.before(:each, bullet: false) do
    Bullet.enable = false
  end

  config.after(:each, bullet: false) do
    Bullet.enable = true
  end

  config.before(:each) do
    Bullet.start_request if Bullet.enable?
  end

  config.after(:each) do
    if Bullet.enable?
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
