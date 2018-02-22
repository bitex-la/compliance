class DomicileSeedsSerializer
  include FastJsonapi::ObjectSerializer
  set_type :domicile_seeds
  attributes :country, :state, :city, :street_address, :street_number, :postal_code, :floor, :apartment
  belongs_to :issue
  belongs_to :domicile
  has_many :attachments
end