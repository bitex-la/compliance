class CountryValidator < ActiveModel::Validator
  def validate(record)
    if ISO3166::Country.find_country_by_alpha2(record.country).nil?
      record.errors.add(:country, "country not found")
    end
  end
end
