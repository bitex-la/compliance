require 'rails_helper'

RSpec.describe Observation, type: :model do
  %i(abandon dismiss).each do |event|
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

  it 'create an observation with long accented text' do
    issue = create(:basic_issue)
    create(:strange_observation, issue: issue)
  end
end
