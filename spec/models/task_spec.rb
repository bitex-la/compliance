require 'rails_helper'

RSpec.describe Task, type: :model do 
  let(:invalid_task) { described_class.new }
  let(:basic_task) { create(:basic_task) }

  it 'is not valid without a workflow' do
    expect(invalid_task).to_not be_valid
  end

  it 'is valid with a workflow' do
    expect(basic_task).to be_valid
  end

  describe 'when transitioning' do 
    it 'defaults to new' do
      expect(basic_task).to have_state(:new)
    end

    it 'goes from new to started on start' do
      expect(basic_task)
        .to transition_from(:new).to(:started).on_event(:start)
    end

    %i(started retried).each do |state|
      it "goes from #{state} to performed on fail" do
        basic_task.start!
        expect(basic_task)
          .to transition_from(state).to(:failed).on_event(:fail)
      end
    end

    it "goes from started to performed on finish" do
      basic_task.start!
      expect do
        basic_task.finish!
      end.to raise_error AASM::InvalidTransition
      basic_task.update!(output: "Task performed at #{DateTime.now}")
      expect(basic_task.reload)
        .to transition_from(:started).to(:performed).on_event(:finish)
    end

    it "goes from retried to performed on finish" do
      expect(basic_task).to be_can_execute
      basic_task.start!
      basic_task.failure!
      expect do
        basic_task.finish!
      end.to raise_error AASM::InvalidTransition
      basic_task.update!(output: "Task performed at #{DateTime.now}")
      expect(basic_task.reload)
        .to transition_from(:retried).to(:performed).on_event(:finish)
    end

    it 'goes from failed to retried on retry' do
      expect do
        expect(basic_task)
        .to transition_from(:failed).to(:retried).on_event(:retry)
      end.to raise_error AASM::InvalidTransition
    end

    it 'goes to retry while do not reach max_retries' do
      basic_task.start!
      basic_task.failure!
      expect(basic_task.reload.current_retries).to eq 1

      2.times do |i|
        expect(basic_task.can_execute?).to be true
        basic_task.failure!
        expect(basic_task.reload.current_retries).to eq i + 2
      end

      basic_task.failure!
      expect(basic_task.can_execute?).to be false
      expect(basic_task.state).to eq("failed")
    end
  end
end
