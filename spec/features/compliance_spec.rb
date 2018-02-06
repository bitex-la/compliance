require 'rails_helper'

describe '' do
  it 'creates a new natural person' do
    # Creates issue via API: Includes seeds for domicile, identification, docket, quota.
    # Admin does not see it as pending
    # Admin sees issue in dashboard.
    # Admin sends comments to customer about their identification (it was blurry)
       # The issue goes away from the dashboard.
    # Customer re-submits identification (we get it via API)
    # Admin accepts the customer data, the issue goes away from the to-do list | Admin dismisses the issue, the person is rejected
    # Worldcheck is run on the customer, customer is accepted when there are no hits, issue is closed. | Customer had hits, admin needs to check manually.
  end

  it 'keeps track of usage quotas' do
    # A funding event is received via API that overruns the customer quota
    # A quota issue is created,
    # An admin reviews the issue, decides to require more information, the person is now 'invalid' | An admin dismisses the issue, customer remains valid
    # The customer sends further data (via API) (along with a comment)
    # An admin reviews the data and decides it's not enough. (and places further comments)
    # The customer finally attaches all the required documents
    # The admin accepts the documents, assigns a value and periodicity to the new quotas backed by the documents. 
  end

  it 'registers associated accounts and bitcoin addresses' do
  end

  it 'performs periodic checks using third party databases' do
  end

  it 'exports the customer data signed by bitex' do
  end
end