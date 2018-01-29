# Base class for Application Records
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
