require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe Observation, type: :model do
  %i(abandon dismiss reject).each do |event|
    it "scoped by admin return only observations who belongs to active issues, skip observations for issues in #{event} state" do
      issue = create(:basic_issue)
      another_issue = create(:basic_issue)
      worldcheck_observation = create(:admin_world_check_observation, issue: issue)
      risk_observation = create(:chainalysis_observation, issue: another_issue)
      
      Observation.admin_pending.count.should == 2
      another_issue.send("#{event}!")
      Observation.admin_pending.count.should == 1
      Observation.admin_pending.first.note.should == worldcheck_observation.note
    end
  end

  %i(note reply).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    note: '  The note',
    reply: 'The reply  '
  }

  it 'create an observation with long accented text' do
    issue = create(:basic_issue)
    create(:strange_observation, issue: issue)
  end

  it 'preserve previous reply value if new value is nil' do
    obv = described_class.create(
      note: 'The note',
      reply: nil,
      issue: create(:basic_issue)
    )
  
    obv.update(reply: 'Reply from a backround process')
    expect(obv).to have_state(:answered)
    obv.update(reply: nil)
    expect(obv).to have_state(:answered)

    expect(obv.reload.reply).to eq 'Reply from a backround process'
    expect(obv).to have_state(:answered)
    assert_logging(obv, :update_entity, 2)

    obv.update(reply: 'Reply UPDATED from a backround process')

    expect(obv.reload.reply).to eq 'Reply UPDATED from a backround process'
    expect(obv).to have_state(:answered)
    assert_logging(obv, :update_entity, 3)
  end

  it "prevents save an observation if seed's issue do not match observation issue" do
    issue = create(:basic_issue)
    issue2 = create(:basic_issue)
    seed = issue.allowance_seeds.build
    seed.amount = 1000.50
    seed.kind_id = Currency.all.first.id
    obs = seed.observations.build
    obs.issue = issue2
    
    expect { issue.save! }.to raise_error(ActiveRecord::RecordInvalid,
      "Validation failed: Allowance seeds observations observable Issue and observable issue must match")
  end
end
