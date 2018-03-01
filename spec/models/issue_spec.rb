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

  describe 'has transitions' do
    it 'new as default' do
      expect(empty_issue).to have_state(:new)
    end

    %i(new replicated).each do |state|
      it "from #{state} to observed on observe" do
        expect(empty_issue).to transition_from(state).to(:observed).on_event(:observe)
      end
    end

    %i(observed).each do |state|
      it "from #{state} to replicated on replicate" do
        expect(empty_issue).to transition_from(state).to(:replicated).on_event(:replicate)
      end
    end

    %i(new replicated observed).each do |state|
      it "from #{state} to dismissed on dismiss" do
        expect(empty_issue).to transition_from(state).to(:dismissed).on_event(:dismiss)
      end
    end

    %i(new observed replicated).each do |state|
      it "from #{state} to rejected on reject" do
        expect(empty_issue).to transition_from(state).to(:rejected).on_event(:reject)
      end
    end

    %i(new replicated).each do |state|
      it "from #{state} to accepted on accept" do
        expect(empty_issue).to transition_from(state).to(:accepted).on_event(:accept) 
      end
    end

    %i(new observed replicated).each do |state|
      it "from #{state} to abandoned on abandon" do
        expect(empty_issue).to transition_from(state).to(:abandoned).on_event(:abandon)
      end
    end
  end  
end
