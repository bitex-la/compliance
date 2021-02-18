require 'rails_helper'

RSpec.describe 'Countries', type: :model do
  describe 'Translations' do
    it 'do not show false as country' do
      expect(ISO3166::Country.all_names_with_sym_codes(:es).all? { |_, v| v != false }).to be_truthy
    end

    it 'get Norway correctly' do
      expect(ISO3166::Country.all_names_with_sym_codes(:es)['Norway']).to eq(:NO)
    end
  end
end
