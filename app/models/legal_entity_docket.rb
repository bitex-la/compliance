class LegalEntityDocket < LegalEntityDocketBase
  include Garden::Fruit

  def self.name_body(i)
    i.commercial_name || i.legal_name
  end
end
