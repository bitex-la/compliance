class LegalEntityDocket < ApplicationRecord
  include Garden::Fruit

  def name
    [id, commercial_name, legal_name].join(',')    
  end
end
