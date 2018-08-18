require 'spec_helper'
class Api::EntitiesHelper

  def self.person_with_fund_deposit(person_id = nil)
    {
      data: {
        type: "fund_deposits", 
        relationships: {
          person: {
          data: {type: "person", "id": person_id}
          }
        }, 
        attributes: {
          type: "fund_deposits", 
          amount: 65.76, 
          currency_code: "usd", 
          deposit_method_code: "bank",
          external_id: "1234"
        }
      }
    }
  end

end