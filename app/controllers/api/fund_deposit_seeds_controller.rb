class Api::FundDepositSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.fund_deposit_seeds }
  end

  def get_resource(scope)
    scope.fund_deposit_seeds.find(params[:id])
  end
end