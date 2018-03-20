class Phone < ApplicationRecord
  include Garden::Fruit
  validates_with CountryValidator

  def name
    [id, number, kind, country].join(',')
  end
end
