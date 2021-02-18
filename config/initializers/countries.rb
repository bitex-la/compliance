
ISO3166::Data.register(
  alpha2: 'AN',
  alpha3: 'ANT',
  name: 'Netherlands Antilles',
  translations: {
    'en' => 'Netherlands Antilles',
    'es' => 'Antillas Holandesas'
  }
)

module ISO3166
  class Country
    class << self
      def all_names_with_sym_codes(locale)
        Hash[ISO3166::Country.all_names_with_codes(locale).collect { |item| [item[0], item[1].to_sym] } ]
      end
    end
  end
end
