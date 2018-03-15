class Identification < ApplicationRecord
  include Garden::Fruit

  def name
    [id, number, kind, issuer].join(',')    
  end
end
