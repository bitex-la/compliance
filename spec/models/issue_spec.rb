require 'rails_helper'

RSpec.describe Issue, type: :model do
  let(:empty_issue) { described_class.new }
  let(:basic_issue) { create(:basic_issue) }

  it 'is not valid without a person' do
    expect(empty_issue).to_not be_valid
  end

  it 'is valid with a person' do
    expect(basic_issue).to be_valid
  end

  it 'has empty seeds by default' do
    expect(basic_issue.get_seeds).to be_empty
  end
end
