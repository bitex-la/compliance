class DomicileSeedSerializer
  include FastJsonapi::ObjectSerializer
  attributes :country, :state, :city, :street_address, :street_number, :postal_code, :floor, :apartment
  belongs_to :issue
  belongs_to :domicile
  has_many :attachments
end