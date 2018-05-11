require 'rails_helper'
require 'helpers/api/issues_helper'
require 'json'

%w(
  DomicileSeed
).each do |seed|
  describe seed.constantize do
    let(:person) { create(:empty_person) }

    describe "Creating a new #{seed}" do
      true.should == true
    end
  end
end


