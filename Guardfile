# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  watch('spec/spec_helper.rb') { 'spec' }
  watch('config/routes.rb') { 'spec/routing' }
  watch('app/controllers/application_controller.rb') { 'spec/controllers' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/policies/(.+)_policy.rb$}) { |m| "spec/controllers/v1/authorization/#{m[1]}_authorization_spec.rb" }
  watch(%r{^app/jobs/(.+).rb$}) { |m| "spec/jobs/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/v1/(.+).rb$}) { |m| "spec/controllers/v1/#{m[1]}_spec.rb" }
  watch(%r{^app/models/v1/(.+).rb$}) { |m| "spec/models/v1/#{m[1]}_spec.rb" }
  watch(%r{^app/models/concerns/(.+).rb$}) { |m| "spec/models/concerns/#{m[1]}_spec.rb" }
  watch(%r{^app/models/document/fund_template.rb$}) { 'spec/controllers/v1/investors_controller_spec.rb' }
  watch(%r{^app/models/document/fund_template.rb$}) { 'spec/controllers/v1/investor_cashflows_controller_spec.rb' }
  watch(%r{^app/resources/v1/(.+).rb$}) { |m| "spec/resources/v1/#{m[1]}_spec.rb" }
  watch(%r{^app/resources/v1/(.+).rb$}) { 'spec/services/format_response_document_service_spec.rb' }
  watch(%r{^app/controllers/concerns/.+.rb$}) { 'spec/controllers/v1/' }
  watch(%r{^app/lib/(.+).rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
end
