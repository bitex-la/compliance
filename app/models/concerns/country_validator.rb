class CountryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if ISO3166::Country.find_country_by_alpha2(value.upcase).nil?
      record.errors.add(:country, "country not found")
    end
  end
end
