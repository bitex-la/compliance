class QuotaSeedSerializer
  include FastJsonapi::ObjectSerializer
  attributes :weight, :amount, :kind
  belongs_to :issue
  belongs_to :quota
end