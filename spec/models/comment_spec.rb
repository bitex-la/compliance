require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:invalid_comment) { described_class.new }
  let(:comment)         { create(:comment) }

  it 'is not valid without a commentable' do
    expect(invalid_comment).to_not be_valid
  end

  it 'is valid with a commentable' do
    expect(comment).to be_valid
  end
end
