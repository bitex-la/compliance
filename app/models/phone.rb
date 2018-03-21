class Phone < ApplicationRecord
  include Garden::Fruit
  validates :country, country: true

  def name
    [id, number, kind, country].join(',')
  end
end
