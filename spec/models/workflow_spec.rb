require 'rails_helper'

RSpec.describe Workflow, type: :model do 
  let(:invalid_workflow) { described_class.new }
  let(:basic_workflow) { create(:basic_workflow) }

  it 'is not valid without an issue' do
    expect(invalid_workflow).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(basic_workflow).to be_valid
  end

  describe 'when transitioning' do 
    it 'defaults to new' do
      expect(basic_workflow).to have_state(:new)
    end

    it 'goes from new to started on start' do
      expect(basic_workflow)
        .to transition_from(:new).to(:started).on_event(:start)
    end

    it 'goes from started to failed on fail' do
      expect(basic_workflow)
        .to transition_from(:started).to(:failed).on_event(:fail)
    end

    %i(new started).each do |state|
      it "goes from #{state} to dismissed on dismiss" do
        expect(basic_workflow)
          .to transition_from(state).to(:dismissed).on_event(:dismiss)
      end
    end

    it 'goes from started to performed only if related task are done' do
      3.times do 
        create(:basic_task, workflow: basic_workflow)
      end
      expect { basic_workflow.finish! }.to raise_error AASM::InvalidTransition
      
      basic_workflow.reload.tasks.first.start!
      expect(basic_workflow).to have_state(:started)
      basic_workflow.tasks.first.update!(output: 'all ok!')
      basic_workflow.tasks.first.finish!
      expect(basic_workflow).to have_state(:started)

      expect { basic_workflow.finish! }.to raise_error AASM::InvalidTransition

      basic_workflow.tasks[1..-1]
        .each {|task| task.start!; task.update!(output: 'all clear!') ; task.finish!}
      expect(basic_workflow).to have_state(:performed)
    end

    it 'goes to failed if any of tasks fails and has zero retries available' do
      3.times do 
        create(:basic_task, workflow: basic_workflow)
      end
      basic_workflow.reload.tasks.each {|task| task.start!; task.fail!}
      expect(basic_workflow).to have_state(:started)

      basic_workflow.tasks.each do |task|
        expect(task.can_retry?).to be_truthy
      end

      3.times do 
        basic_workflow.tasks.each {|task| task.retry!; task.fail!}
      end

      expect(basic_workflow).to have_state(:failed)
    end
  end
end