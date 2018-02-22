class AllowanceSeedsSerializer
  include FastJsonapi::ObjectSerializer
  set_type :allowance_seeds
  attributes :weight, :amount, :kind
  belongs_to :issue
  belongs_to :allowance
end
