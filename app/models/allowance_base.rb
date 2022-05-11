class AllowanceBase < ApplicationRecord
  self.abstract_class = true
  ransackable_static_belongs_to :kind, class_name: "Currency"

  def name_body
    "#{amount} #{kind}"
  end
  enum tpi: Person::TPI_VALUES
end
