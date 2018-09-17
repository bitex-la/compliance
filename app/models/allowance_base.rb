class AllowanceBase < ApplicationRecord
  self.abstract_class = true
  ransackable_static_belongs_to :kind, class_name: "Currency"
end
