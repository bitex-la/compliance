require 'spec_helper'
module Api::PeopleHelper
  def self.basic_person
    {
      data: {
        type: "person",
        attributes: {
        },
        relationships: {
        }
      },
      included: [
      ]
    }
  end
end