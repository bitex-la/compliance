require 'rails_helper'

RSpec.describe Attachment, type: :model do
  let(:invalid_attachment) { described_class.new }
  let(:valid_attachment)   { create(:attachment) }

  it 'is valid without a person who owns it' do
    expect(invalid_attachment).to be_valid
  end

  it 'is valid with an issue' do
    expect(valid_attachment).to be_valid
  end
end
