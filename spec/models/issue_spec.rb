require 'rails_helper'

RSpec.describe Issue, type: :model do
  let(:invalid_issue) { described_class.new } 
  let(:empty_issue) { create(:basic_issue) }
  let(:basic_issue) { create(:basic_issue) }

  it 'is not valid without a person' do
    expect(invalid_issue).to_not be_valid
  end

  it 'is valid with a person' do
    expect(basic_issue).to be_valid
  end

  describe 'when transitioning' do
    it 'defaults to new' do
      expect(empty_issue).to have_state(:new)
    end

    %i(new answered).each do |state|
      it "goes from #{state} to observed on observe" do
        expect(empty_issue).to transition_from(state).to(:observed).on_event(:observe)
      end
    end

    %i(observed).each do |state|
      it "goes from #{state} to answered on answer" do
        expect(empty_issue).to transition_from(state).to(:answered).on_event(:answer)
      end
    end

    %i(new answered observed).each do |state|
      it "goes from #{state} to dismissed on dismiss" do
        expect(empty_issue).to transition_from(state).to(:dismissed).on_event(:dismiss)
      end
    end

    %i(new observed answered).each do |state|
      it "goes from #{state} to rejected on reject" do
        expect(empty_issue).to transition_from(state).to(:rejected).on_event(:reject)
      end
    end

    %i(new answered).each do |state|
      it "goes from #{state} to approved on approve" do
        expect(empty_issue).to transition_from(state).to(:approved).on_event(:approve) 
      end
    end

    %i(new observed answered).each do |state|
      it "goes from #{state} to abandoned on abandon" do
        expect(empty_issue).to transition_from(state).to(:abandoned).on_event(:abandon)
      end
    end

    it 'disables person on reject' do
      person = create :full_natural_person
      issue = create(:basic_issue, person: person)
      
      expect do
        issue.reject!
      end.to change{ person.enabled }.to(false)
    end

    it 'does nothing on dismiss' do
      person = create :full_natural_person
      issue = create(:basic_issue, person: person)
      
      expect do
        issue.dismiss!
      end.not_to change{ person.enabled }
    end

    it 'enables person on approve' do
      person = create :new_natural_person
      
      expect do
        person.issues.last.approve!
      end.to change{ person.enabled }.to(true)
    end
  end

  describe "when transitioning" do
    it 'creates new fruits for new person' do
      person = create :new_natural_person
      issue = person.issues.last
      %i(domiciles natural_dockets allowances identifications).each do |assoc|
        person.send(assoc).should be_empty
      end
      issue.approve!
      person.reload
      issue.reload

      %w(domicile natural_docket allowance identification).each do |assoc|
        person.send(assoc.pluralize).should_not be_empty
      end

      %w(domicile allowance identification).each do |assoc|
        person.send(assoc.pluralize).first.seed.should ==
          issue.send("#{assoc}_seeds").first
        issue.send("#{assoc}_seeds").first.fruit.should == 
          person.send(assoc.pluralize).first
      end

      person.natural_dockets.first.seed.should == issue.natural_docket_seed
      issue.natural_docket_seed.fruit.should == person.natural_dockets.first

      # Allowance
      fruit = person.allowances.first
      %i(weight amount kind attachments).each do |attr|
        fruit.send(attr).should == fruit.seed.send(attr)
      end
    end

    it 'adds some new fruits and replace others on existing person' do
      person = create :full_natural_person
      issue = create :basic_issue, person: person

      create :full_domicile_seed, issue: issue, replaces: person.domiciles.last
      create :salary_allowance_seed, issue: issue
      create :full_natural_docket_seed, issue: issue

      issue.should be_new
      issue.approve!
      issue.should be_approved
      person.reload
      person.domiciles.count.should == 2
      person.domiciles.current.count.should == 1
      person.natural_dockets.count.should == 2
      person.natural_dockets.current.count.should == 1
      person.allowances.count.should == 3
      person.allowances.current.count.should == 3

      %w(domiciles natural_dockets).each do |assoc|
        person.send(assoc).first.replaced_by.should == person.send(assoc).last
        person.send(assoc).last.replaces.should == person.send(assoc).first
      end

      person.natural_docket.tap do |d|
        d.should == person.natural_dockets.current.last
        d.replaces.should == person.natural_dockets.first
      end
    end
  end  
end
