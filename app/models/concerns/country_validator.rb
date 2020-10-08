class CountryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless ISO3166::Country.find_country_by_alpha2(value.try(:upcase))
      .nil?

    record.errors.add(attribute.to_sym, 'not found')
  end
end
