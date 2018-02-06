require 'rails_helper'

RSpec.describe Person, type: :model do
  it 'is valid without issues' do
    expect(Person.new).to be_valid
  end
end
