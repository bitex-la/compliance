class ApplicationRecord < ActiveRecord::Base
  include StaticModels::BelongsTo
  include RansackForStaticModel

  self.abstract_class = true
end
