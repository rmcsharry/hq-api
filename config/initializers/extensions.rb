# frozen_string_literal: true

Dir[Rails.root.join('lib', 'core_ext', '*.rb')].each do |file|
  require file
end
