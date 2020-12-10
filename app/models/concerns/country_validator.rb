class CountryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    alpha2 = value.try(:upcase)
    return unless ISO3166::Country.find_country_by_alpha2(alpha2)
      .nil?

    record.errors.add(attribute.to_sym, "#{alpha2} not found")
  end
end
