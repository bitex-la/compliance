require 'rails_helper'

RSpec.describe 'Countries', type: :model do
  describe 'Translations' do
    it 'do not show false as country' do
      expect(ISO3166::Country.translations.invert.all? { |_, v| v != false }).to be_truthy
    end

    it 'get Norway correctly' do
      expect(ISO3166::Country.translations.invert['Norway']).to eq(:NO)
    end
  end
end
